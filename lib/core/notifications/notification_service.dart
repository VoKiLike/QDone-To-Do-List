import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:qdone/features/tasks/domain/entities/reminder.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/services/recurrence_service.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._plugin);

  static const int maxPendingNotificationsPerTask = 64;
  static const String _taskChannelId = 'qdone_tasks_v2';
  static final Int64List _taskVibrationPattern = Int64List.fromList(
    <int>[0, 120, 80, 180],
  );

  static final AndroidNotificationChannel taskChannel =
      AndroidNotificationChannel(
        _taskChannelId,
        'Задачи QDone',
        description: 'Напоминания о задачах, повторах и умном откладывании.',
        importance: Importance.high,
        enableVibration: true,
        vibrationPattern: _taskVibrationPattern,
      );

  final FlutterLocalNotificationsPlugin _plugin;
  final _recurrenceService = const RecurrenceService();

  Future<void> initialize() async {
    timezone_data.initializeTimeZones();
    await _configureLocalTimeZone();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(taskChannel);
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final android = await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return android ?? ios ?? true;
  }

  Future<Task> scheduleTask(Task task) async {
    if (task.isCompleted) {
      return task.copyWith(
        reminders: task.reminders
            .map((reminder) => reminder.copyWith(isEnabled: false))
            .toList(),
        notificationIds: const <int>[],
      );
    }

    final scheduledIds = <int>[];
    final scheduledReminders = <Reminder>[];
    final scheduleItems = _scheduleItemsFor(task);
    final scheduleMode = await _androidScheduleMode();

    for (final item in scheduleItems) {
      final dateTime = item.dateTime;
      if (!dateTime.isAfter(DateTime.now())) {
        continue;
      }
      await _plugin.zonedSchedule(
        item.notificationId,
        task.title,
        task.description ?? 'Напоминание QDone',
        tz.TZDateTime.from(dateTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _taskChannelId,
            'Задачи QDone',
            channelDescription:
                'Напоминания о задачах, повторах и умном откладывании.',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            enableVibration: true,
            vibrationPattern: _taskVibrationPattern,
            visibility: NotificationVisibility.public,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: scheduleMode,
        payload: task.id,
      );
      scheduledIds.add(item.notificationId);
      scheduledReminders.add(
        item.reminder.copyWith(
          dateTime: dateTime,
          notificationId: item.notificationId,
        ),
      );
    }

    return task.copyWith(
      reminders: _storedRemindersFor(task, scheduledReminders),
      notificationIds: List<int>.unmodifiable(scheduledIds),
    );
  }

  Future<void> cancelTask(Task task) async {
    final ids = <int>{...task.notificationIds};
    for (final reminder in task.reminders) {
      final id = reminder.notificationId;
      if (id != null) {
        ids.add(id);
      }
    }
    for (final id in ids) {
      await _plugin.cancel(id);
    }
  }

  Future<AndroidScheduleMode> _androidScheduleMode() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canScheduleExact =
        await androidPlugin?.canScheduleExactNotifications() ?? true;
    return canScheduleExact
        ? AndroidScheduleMode.alarmClock
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  List<Reminder> _storedRemindersFor(
    Task task,
    List<Reminder> scheduledReminders,
  ) {
    final recurrence = task.recurrenceRule;
    if (!recurrence.isEnabled || recurrence.type == RecurrenceType.none) {
      return scheduledReminders;
    }
    final enabledReminders = task.reminders
        .where((reminder) => reminder.isEnabled)
        .toList();
    if (enabledReminders.isEmpty) {
      return const <Reminder>[];
    }
    final template = enabledReminders.first;
    return <Reminder>[
      Reminder(
        id: template.id,
        taskId: template.taskId,
        dateTime: task.dueDateTime.add(_reminderOffsetFor(task, template)),
        isEnabled: template.isEnabled,
      ),
    ];
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  List<_NotificationScheduleItem> _scheduleItemsFor(Task task) {
    final enabledReminders = task.reminders
        .where((reminder) => reminder.isEnabled)
        .toList();
    if (enabledReminders.isEmpty) {
      return const <_NotificationScheduleItem>[];
    }

    final recurrence = task.recurrenceRule;
    if (!recurrence.isEnabled || recurrence.type == RecurrenceType.none) {
      return enabledReminders
          .map(
            (reminder) => _NotificationScheduleItem(
              reminder: reminder,
              dateTime: reminder.dateTime,
              notificationId:
                  reminder.notificationId ?? _stableNotificationId(reminder),
            ),
          )
          .toList();
    }

    final now = DateTime.now();
    final occurrences = _recurrenceService
        .occurrencesForRange(
          task: task,
          from: now,
          to: now.add(const Duration(days: 370)),
        )
        .take(maxPendingNotificationsPerTask)
        .toList();

    final items = <_NotificationScheduleItem>[];
    final reminderOffset = _reminderOffsetFor(task, enabledReminders.first);
    for (final occurrence in occurrences) {
      if (items.length >= maxPendingNotificationsPerTask) {
        break;
      }
      final template = _templateReminderFor(task, enabledReminders, occurrence);
      final notificationTime = occurrence.add(reminderOffset);
      items.add(
        _NotificationScheduleItem(
          reminder: template,
          dateTime: notificationTime,
          notificationId: _stableNotificationIdFor(task.id, notificationTime),
        ),
      );
    }
    return items;
  }

  int _stableNotificationId(Reminder reminder) {
    return _stableNotificationIdFor(reminder.id, reminder.dateTime);
  }

  int _stableNotificationIdFor(String seed, DateTime dateTime) {
    final value = '$seed:${dateTime.toIso8601String()}';
    return value.codeUnits.fold<int>(17, (hash, code) {
          return (37 * hash + code) & 0x7fffffff;
        }) %
        2147483647;
  }

  Reminder _templateReminderFor(
    Task task,
    List<Reminder> reminders,
    DateTime occurrence,
  ) {
    return reminders.firstWhere(
      (reminder) =>
          reminder.dateTime.hour == occurrence.hour &&
          reminder.dateTime.minute == occurrence.minute,
      orElse: () => reminders.first,
    );
  }

  Duration _reminderOffsetFor(Task task, Reminder reminder) {
    final offset = reminder.dateTime.difference(task.dueDateTime);
    if (offset.isNegative) {
      return offset;
    }
    final inferredRecurringOffset = _recurringReminderOffsetFor(task, reminder);
    if (inferredRecurringOffset.isNegative) {
      return inferredRecurringOffset;
    }
    return Duration.zero;
  }

  Duration _recurringReminderOffsetFor(Task task, Reminder reminder) {
    final recurrence = task.recurrenceRule;
    if (!recurrence.isEnabled || recurrence.type == RecurrenceType.none) {
      return Duration.zero;
    }
    final times = recurrence.timesOfDay.isEmpty
        ? <TimeOfDay>[task.dueTime]
        : recurrence.timesOfDay;
    Duration? bestOffset;
    for (final time in times) {
      final occurrence = DateTime(
        reminder.dateTime.year,
        reminder.dateTime.month,
        reminder.dateTime.day,
        time.hour,
        time.minute,
      );
      final candidate = reminder.dateTime.difference(occurrence);
      if (candidate > Duration.zero) {
        continue;
      }
      if (bestOffset == null || candidate > bestOffset) {
        bestOffset = candidate;
      }
    }
    return bestOffset ?? Duration.zero;
  }
}

class _NotificationScheduleItem {
  const _NotificationScheduleItem({
    required this.reminder,
    required this.dateTime,
    required this.notificationId,
  });

  final Reminder reminder;
  final DateTime dateTime;
  final int notificationId;
}
