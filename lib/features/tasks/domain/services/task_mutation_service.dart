import 'package:flutter/material.dart';
import 'package:qdone/core/notifications/notification_service.dart';
import 'package:qdone/features/settings/domain/settings_repository.dart';
import 'package:qdone/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:qdone/features/tasks/domain/entities/reminder.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/repositories/task_repository.dart';
import 'package:qdone/features/tasks/domain/services/recurrence_service.dart';
import 'package:uuid/uuid.dart';

class TaskMutationService {
  TaskMutationService({
    required this.repository,
    required this.notificationService,
    required this.settingsRepository,
    Uuid uuid = const Uuid(),
    RecurrenceService recurrenceService = const RecurrenceService(),
  }) : _uuid = uuid,
       _recurrenceService = recurrenceService;

  final TaskRepository repository;
  final NotificationService notificationService;
  final SettingsRepository settingsRepository;
  final Uuid _uuid;
  final RecurrenceService _recurrenceService;

  Future<void> addTask({
    required String title,
    String? description,
    required DateTime dueDate,
    required TimeOfDay dueTime,
    TaskPriority priority = TaskPriority.medium,
    EnergyLevel energyLevel = EnergyLevel.medium,
    TaskCategory? category,
    RecurrenceRule recurrenceRule = const RecurrenceRule(),
    List<DateTime> reminderTimes = const <DateTime>[],
  }) async {
    final id = _uuid.v4();
    final task = Task(
      id: id,
      title: title.trim(),
      description: description?.trim().isEmpty ?? true
          ? null
          : description?.trim(),
      createdAt: DateTime.now(),
      dueDate: dueDate,
      dueTime: dueTime,
      priority: priority,
      category:
          category ??
          const TaskCategory(
            id: 'personal',
            name: 'Личное',
            colorValue: 0xFF8B5CF6,
          ),
      recurrenceRule: recurrenceRule,
      reminders: reminderTimes
          .map(
            (dateTime) =>
                Reminder(id: _uuid.v4(), taskId: id, dateTime: dateTime),
          )
          .toList(),
      energyLevel: energyLevel,
    );
    await repository.upsert(await _scheduleIfAllowed(task));
  }

  Future<void> updateTask(Task task) async {
    await repository.upsert(await _scheduleIfAllowed(task));
  }

  Future<void> refreshScheduledNotifications() async {
    final tasks = await repository.watchAll();
    for (final task in tasks.where(_needsNotificationRefresh)) {
      final latest = await _latestTask(task.id);
      if (latest == null || !_needsNotificationRefresh(latest)) {
        continue;
      }
      await notificationService.cancelTask(latest);
      final rescheduled = await _scheduleIfAllowed(
        _withoutScheduledNotifications(latest),
      );
      final current = await _latestTask(task.id);
      if (current != null && _sameSchedulingInputs(latest, current)) {
        await repository.upsert(rescheduled);
      }
    }
  }

  Future<void> editTask({
    required Task task,
    required String title,
    String? description,
    required DateTime dueDate,
    required TimeOfDay dueTime,
    required TaskPriority priority,
    required EnergyLevel energyLevel,
    required TaskCategory category,
    required RecurrenceRule recurrenceRule,
    required List<DateTime> reminderTimes,
  }) async {
    await notificationService.cancelTask(task);
    await updateTask(
      task.copyWith(
        title: title.trim(),
        description: description?.trim().isEmpty ?? true
            ? null
            : description?.trim(),
        dueDate: dueDate,
        dueTime: dueTime,
        priority: priority,
        energyLevel: energyLevel,
        category: category,
        recurrenceRule: recurrenceRule,
        reminders: reminderTimes
            .map(
              (dateTime) =>
                  Reminder(id: _uuid.v4(), taskId: task.id, dateTime: dateTime),
            )
            .toList(),
        notificationIds: const <int>[],
      ),
    );
  }

  Future<void> complete(Task task) async {
    await notificationService.cancelTask(task);
    if (task.recurrenceRule.isEnabled &&
        task.recurrenceRule.type != RecurrenceType.none) {
      final nextOccurrence = _recurrenceService.nextOccurrenceAfter(
        task: task,
        after: task.dueDateTime,
      );
      if (nextOccurrence != null) {
        final nextTask = _moveTaskSchedule(task, nextOccurrence).copyWith(
          status: TaskStatus.active,
          clearCompletedAt: true,
          isArchived: false,
        );
        await repository.upsert(await _scheduleIfAllowed(nextTask));
        return;
      }
    }

    await repository.upsert(
      _withoutScheduledNotifications(
        task.copyWith(
          status: TaskStatus.completed,
          completedAt: DateTime.now(),
          isArchived: false,
        ),
      ),
    );
  }

  Future<void> restore(Task task) async {
    await repository.upsert(
      await _scheduleIfAllowed(
        task.copyWith(
          status: TaskStatus.active,
          clearCompletedAt: true,
          isArchived: false,
        ),
      ),
    );
  }

  Future<void> archive(Task task) async {
    await notificationService.cancelTask(task);
    await repository.upsert(
      _withoutScheduledNotifications(
        task.copyWith(
          status: TaskStatus.archived,
          completedAt: task.completedAt ?? DateTime.now(),
          isArchived: true,
        ),
      ),
    );
  }

  Future<void> delete(Task task) async {
    await notificationService.cancelTask(task);
    await repository.delete(task.id);
  }

  Future<void> clearCompleted() async {
    final tasks = await repository.watchAll();
    for (final task in tasks.where((task) => task.isCompleted)) {
      await notificationService.cancelTask(task);
    }
    await repository.clearCompleted();
  }

  Future<void> snooze(Task task, Duration duration) async {
    await notificationService.cancelTask(task);
    final next = DateTime.now().add(duration);
    await repository.upsert(
      await _scheduleIfAllowed(
        task.copyWith(
          dueDate: DateTime(next.year, next.month, next.day),
          dueTime: TimeOfDay(hour: next.hour, minute: next.minute),
          status: TaskStatus.active,
          clearCompletedAt: true,
          isArchived: false,
          reminders: <Reminder>[
            Reminder(id: _uuid.v4(), taskId: task.id, dateTime: next),
          ],
          notificationIds: const <int>[],
        ),
      ),
    );
  }

  Future<void> reschedule(Task task, DateTime dateTime) async {
    await notificationService.cancelTask(task);
    final nextTask = _moveTaskSchedule(task, dateTime).copyWith(
      status: TaskStatus.active,
      clearCompletedAt: true,
      isArchived: false,
    );
    await repository.upsert(await _scheduleIfAllowed(nextTask));
  }

  Future<bool> toggleFromWidget(String taskId) async {
    final tasks = await repository.watchAll();
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      return false;
    }
    final task = tasks[index];
    if (task.isCompleted) {
      await restore(task);
    } else {
      await complete(task);
    }
    return true;
  }

  Future<Task> _scheduleIfAllowed(Task task) async {
    final settings = await settingsRepository.read();
    if (!settings.notificationsEnabled || task.reminders.isEmpty) {
      return _withoutScheduledNotifications(task);
    }
    return notificationService.scheduleTask(task);
  }

  Task _moveTaskSchedule(Task task, DateTime nextDueDateTime) {
    final delta = nextDueDateTime.difference(task.dueDateTime);
    final movedReminders = task.reminders.map((reminder) {
      return Reminder(
        id: reminder.id,
        taskId: reminder.taskId,
        dateTime: reminder.dateTime.add(delta),
        isEnabled: reminder.isEnabled,
      );
    }).toList();
    return _withoutScheduledNotifications(
      task.copyWith(
        dueDate: DateTime(
          nextDueDateTime.year,
          nextDueDateTime.month,
          nextDueDateTime.day,
        ),
        dueTime: TimeOfDay(
          hour: nextDueDateTime.hour,
          minute: nextDueDateTime.minute,
        ),
        reminders: movedReminders,
      ),
    );
  }

  Task _withoutScheduledNotifications(Task task) {
    return task.copyWith(
      notificationIds: const <int>[],
      reminders: task.reminders.map((reminder) {
        return Reminder(
          id: reminder.id,
          taskId: reminder.taskId,
          dateTime: reminder.dateTime,
          isEnabled: reminder.isEnabled,
        );
      }).toList(),
    );
  }

  bool _needsNotificationRefresh(Task task) {
    return !task.isCompleted &&
        task.reminders.any((reminder) => reminder.isEnabled);
  }

  Future<Task?> _latestTask(String taskId) async {
    final tasks = await repository.watchAll();
    for (final task in tasks) {
      if (task.id == taskId) {
        return task;
      }
    }
    return null;
  }

  bool _sameSchedulingInputs(Task a, Task b) {
    return a.title == b.title &&
        a.description == b.description &&
        a.status == b.status &&
        a.isArchived == b.isArchived &&
        a.dueDateTime == b.dueDateTime &&
        a.recurrenceRule.toJson().toString() ==
            b.recurrenceRule.toJson().toString() &&
        _sameReminderTemplates(a.reminders, b.reminders);
  }

  bool _sameReminderTemplates(List<Reminder> a, List<Reminder> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var index = 0; index < a.length; index++) {
      final left = a[index];
      final right = b[index];
      if (left.id != right.id ||
          left.taskId != right.taskId ||
          left.dateTime != right.dateTime ||
          left.isEnabled != right.isEnabled) {
        return false;
      }
    }
    return true;
  }
}
