import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qdone/core/notifications/notification_service.dart';
import 'package:qdone/features/settings/domain/settings_repository.dart';
import 'package:qdone/features/tasks/data/database/qdone_database.dart';
import 'package:qdone/features/tasks/domain/entities/reminder.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/repositories/task_repository.dart';
import 'package:qdone/features/tasks/domain/services/recurrence_service.dart';

abstract interface class NotificationScheduleCoordinator {
  Future<NotificationSchedulerStatus> reconcile({bool forceReset = false});
  Future<NotificationSchedulerStatus> clear();
  Future<NotificationSchedulerStatus> status();
}

class NotificationScheduler implements NotificationScheduleCoordinator {
  NotificationScheduler({
    required NotificationService notificationService,
    required TaskRepository taskRepository,
    required SettingsRepository settingsRepository,
    required QDoneDatabase database,
    RecurrenceService recurrenceService = const RecurrenceService(),
  }) : _notificationService = notificationService,
       _taskRepository = taskRepository,
       _settingsRepository = settingsRepository,
       _database = database,
       _recurrenceService = recurrenceService;

  static const int maxPendingNotifications = 48;
  static const int maxNotificationsPerTask = 4;
  static const Duration planningHorizon = Duration(days: 30);
  static const String resetMetadataKey = 'notifications.reset.v3';
  static const String lastSyncMetadataKey = 'notifications.last_sync.v2';
  static const String scheduledCountMetadataKey =
      'notifications.scheduled_count.v2';

  final NotificationService _notificationService;
  final TaskRepository _taskRepository;
  final SettingsRepository _settingsRepository;
  final QDoneDatabase _database;
  final RecurrenceService _recurrenceService;
  Future<NotificationSchedulerStatus>? _activeReconciliation;

  @override
  Future<NotificationSchedulerStatus> reconcile({bool forceReset = false}) {
    final active = _activeReconciliation;
    if (active != null) {
      return active;
    }
    final operation = _reconcile(
      forceReset: forceReset,
    ).whenComplete(() => _activeReconciliation = null);
    _activeReconciliation = operation;
    return operation;
  }

  Future<NotificationSchedulerStatus> _reconcile({
    required bool forceReset,
  }) async {
    await _taskRepository.initialize();
    await _notificationService.ensureInitialized();
    final settings = await _settingsRepository.read();
    if (!settings.notificationsEnabled) {
      return clear();
    }

    final mustReset =
        forceReset || await _database.metadata(resetMetadataKey) != 'complete';
    if (mustReset) {
      await _notificationService.cancelAllPendingNotifications();
      await _database.clearSchedule();
      await _database.setMetadata(resetMetadataKey, 'complete');
    }

    final now = DateTime.now();
    final horizon = now.add(planningHorizon);
    final capability = await _notificationService.capabilityStatus();
    if (!capability.notificationsEnabled) {
      await _notificationService.cancelAllPendingNotifications();
      await _database.clearSchedule();
      return _storeStatus(0, now);
    }

    final tasks = await _taskRepository.readNotificationCandidates(
      now,
      horizon,
    );
    final desired =
        tasks
            .expand(
              (task) => _planForTask(
                task,
                from: now,
                to: horizon,
                exactAlarmsEnabled: capability.exactAlarmsEnabled,
              ),
            )
            .toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final bounded = desired.take(maxPendingNotifications).toList();

    final pending = await _notificationService.pendingRequests();
    final pendingById = <int, PendingNotificationRequest>{
      for (final request in pending) request.id: request,
    };
    final stored = await _database.notificationSchedule();
    final storedById = <int, NotificationScheduleRecord>{
      for (final row in stored) row.notificationId: row,
    };
    final desiredById = <int, _PlannedNotification>{
      for (final item in bounded) item.id: item,
    };

    final staleIds = <int>{
      ...pendingById.keys.where((id) => !desiredById.containsKey(id)),
      ...storedById.keys.where((id) => !desiredById.containsKey(id)),
    };
    for (final id in staleIds) {
      await _notificationService.cancel(id);
    }

    final scheduled = <_PlannedNotification>[];
    for (final item in bounded) {
      final previous = storedById[item.id];
      final unchanged =
          previous?.fingerprint == item.fingerprint &&
          pendingById.containsKey(item.id);
      if (!unchanged) {
        if (pendingById.containsKey(item.id)) {
          await _notificationService.cancel(item.id);
        }
        try {
          await _notificationService.schedule(item.delivery);
        } catch (_) {
          continue;
        }
      }
      scheduled.add(item);
    }

    await _database.replaceNotificationSchedule(
      scheduled
          .map(
            (item) => NotificationScheduleRecordsCompanion.insert(
              notificationId: Value<int>(item.id),
              taskId: item.taskId,
              reminderId: Value<String?>(item.reminderId),
              scheduledAt: item.scheduledAt,
              fingerprint: item.fingerprint,
              scheduleMode: item.androidScheduleMode.name,
            ),
          )
          .toList(),
    );
    return _storeStatus(scheduled.length, now);
  }

  @override
  Future<NotificationSchedulerStatus> clear() async {
    await _notificationService.ensureInitialized();
    await _notificationService.cancelAllPendingNotifications();
    await _database.clearSchedule();
    return _storeStatus(0, DateTime.now());
  }

  @override
  Future<NotificationSchedulerStatus> status() async {
    final count =
        int.tryParse(
          await _database.metadata(scheduledCountMetadataKey) ?? '',
        ) ??
        (await _database.notificationSchedule()).length;
    final lastSync = DateTime.tryParse(
      await _database.metadata(lastSyncMetadataKey) ?? '',
    );
    return NotificationSchedulerStatus(
      scheduledCount: count,
      maxScheduledCount: maxPendingNotifications,
      lastSyncedAt: lastSync,
    );
  }

  Future<NotificationSchedulerStatus> _storeStatus(
    int count,
    DateTime syncedAt,
  ) async {
    await _database.setMetadata(scheduledCountMetadataKey, '$count');
    await _database.setMetadata(
      lastSyncMetadataKey,
      syncedAt.toIso8601String(),
    );
    return NotificationSchedulerStatus(
      scheduledCount: count,
      maxScheduledCount: maxPendingNotifications,
      lastSyncedAt: syncedAt,
    );
  }

  Iterable<_PlannedNotification> _planForTask(
    Task task, {
    required DateTime from,
    required DateTime to,
    required bool exactAlarmsEnabled,
  }) sync* {
    final reminders =
        task.reminders.where((reminder) => reminder.isEnabled).toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    if (reminders.isEmpty || task.isCompleted || task.isArchived) {
      return;
    }

    final exact = task.priority == TaskPriority.high && exactAlarmsEnabled;
    final scheduleMode = exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    final recurrence = task.recurrenceRule;
    if (!recurrence.isEnabled || recurrence.type == RecurrenceType.none) {
      var count = 0;
      for (final reminder in reminders) {
        if (reminder.dateTime.isBefore(from) || reminder.dateTime.isAfter(to)) {
          continue;
        }
        yield _planned(
          task,
          reminder: reminder,
          scheduledAt: reminder.dateTime,
          scheduleMode: scheduleMode,
        );
        count++;
        if (count == maxNotificationsPerTask) {
          return;
        }
      }
      return;
    }

    var count = 0;
    final occurrences = _recurrenceService.occurrencesForRange(
      task: task,
      from: from,
      to: to,
    );
    for (final occurrence in occurrences) {
      for (final reminder in reminders) {
        final scheduledAt = occurrence.add(_reminderOffset(task, reminder));
        if (scheduledAt.isBefore(from) || scheduledAt.isAfter(to)) {
          continue;
        }
        yield _planned(
          task,
          reminder: reminder,
          scheduledAt: scheduledAt,
          scheduleMode: scheduleMode,
        );
        count++;
        if (count == maxNotificationsPerTask) {
          return;
        }
      }
    }
  }

  _PlannedNotification _planned(
    Task task, {
    required Reminder reminder,
    required DateTime scheduledAt,
    required AndroidScheduleMode scheduleMode,
  }) {
    final seed = '${task.id}:${reminder.id}:${scheduledAt.toIso8601String()}';
    final id = _stableId(seed);
    final fingerprint = _stableId(
      '$seed:${task.title}:${task.description}:${task.priority.name}:'
      '${scheduleMode.name}',
    ).toString();
    return _PlannedNotification(
      id: id,
      taskId: task.id,
      reminderId: reminder.id,
      scheduledAt: scheduledAt,
      fingerprint: fingerprint,
      androidScheduleMode: scheduleMode,
      delivery: NotificationDelivery(
        id: id,
        title: task.title,
        body: task.description ?? 'Напоминание QDONE',
        scheduledAt: scheduledAt,
        payload: 'qdone:v2:${task.id}:$fingerprint',
        androidScheduleMode: scheduleMode,
      ),
    );
  }

  Duration _reminderOffset(Task task, Reminder reminder) {
    final offset = reminder.dateTime.difference(task.dueDateTime);
    return offset.isNegative ? offset : Duration.zero;
  }

  int _stableId(String value) {
    return value.codeUnits.fold<int>(17, (hash, code) {
          return (37 * hash + code) & 0x7fffffff;
        }) %
        2147483647;
  }
}

class NotificationSchedulerStatus {
  const NotificationSchedulerStatus({
    required this.scheduledCount,
    required this.maxScheduledCount,
    required this.lastSyncedAt,
  });

  final int scheduledCount;
  final int maxScheduledCount;
  final DateTime? lastSyncedAt;
}

class _PlannedNotification {
  const _PlannedNotification({
    required this.id,
    required this.taskId,
    required this.reminderId,
    required this.scheduledAt,
    required this.fingerprint,
    required this.androidScheduleMode,
    required this.delivery,
  });

  final int id;
  final String taskId;
  final String? reminderId;
  final DateTime scheduledAt;
  final String fingerprint;
  final AndroidScheduleMode androidScheduleMode;
  final NotificationDelivery delivery;
}
