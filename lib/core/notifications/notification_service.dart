import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/reminder.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._plugin);

  static const AndroidNotificationChannel taskChannel =
      AndroidNotificationChannel(
        'qdone_tasks',
        'Задачи QDone',
        description: 'Напоминания о задачах и умное откладывание.',
        importance: Importance.high,
      );

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    timezone_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
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
    final android = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return android ?? ios ?? true;
  }

  Future<List<int>> scheduleTask(Task task) async {
    final ids = <int>[];
    for (final reminder in task.reminders.where((item) => item.isEnabled)) {
      if (reminder.dateTime.isBefore(DateTime.now())) {
        continue;
      }
      final id = reminder.notificationId ?? _stableNotificationId(reminder);
      await _plugin.zonedSchedule(
        id,
        task.title,
        task.description ?? 'Напоминание QDone',
        tz.TZDateTime.from(reminder.dateTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'qdone_tasks',
            'Задачи QDone',
            channelDescription: 'Напоминания о задачах и умное откладывание.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      ids.add(id);
    }
    return ids;
  }

  Future<void> cancelTask(Task task) async {
    for (final id in task.notificationIds) {
      await _plugin.cancel(id);
    }
    for (final reminder in task.reminders) {
      final id = reminder.notificationId;
      if (id != null) {
        await _plugin.cancel(id);
      }
    }
  }

  int _stableNotificationId(Reminder reminder) {
    return reminder.id.codeUnits
            .fold<int>(17, (hash, code) => 37 * hash + code)
            .abs() %
        2147483647;
  }
}
