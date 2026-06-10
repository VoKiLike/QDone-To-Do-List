import 'package:flutter/material.dart';
import 'package:qdone/core/notifications/notification_scheduler.dart';
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
    required this.notificationScheduler,
    Uuid uuid = const Uuid(),
    RecurrenceService recurrenceService = const RecurrenceService(),
  }) : _uuid = uuid,
       _recurrenceService = recurrenceService;

  final TaskRepository repository;
  final NotificationScheduleCoordinator notificationScheduler;
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
    await _save(
      Task(
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
      ),
    );
  }

  Future<void> updateTask(Task task) => _save(task);

  Future<void> refreshScheduledNotifications() {
    return notificationScheduler.reconcile();
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
    final latest = await _latestTask(task.id) ?? task;
    await _save(
      latest.copyWith(
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
              (dateTime) => Reminder(
                id: _uuid.v4(),
                taskId: latest.id,
                dateTime: dateTime,
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> complete(Task task) async {
    final latest = await _latestTask(task.id) ?? task;
    if (latest.recurrenceRule.isEnabled &&
        latest.recurrenceRule.type != RecurrenceType.none) {
      final nextOccurrence = _recurrenceService.nextOccurrenceAfter(
        task: latest,
        after: latest.dueDateTime,
      );
      if (nextOccurrence != null) {
        await _save(
          _moveTaskSchedule(latest, nextOccurrence).copyWith(
            status: TaskStatus.active,
            completedAt: DateTime.now(),
            isArchived: false,
          ),
        );
        return;
      }
    }

    await _save(
      latest.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
        isArchived: false,
      ),
    );
  }

  Future<void> restore(Task task) async {
    final latest = await _latestTask(task.id) ?? task;
    await _save(
      latest.copyWith(
        status: TaskStatus.active,
        clearCompletedAt: true,
        isArchived: false,
      ),
    );
  }

  Future<void> archive(Task task) async {
    final latest = await _latestTask(task.id) ?? task;
    await _save(
      latest.copyWith(
        status: TaskStatus.archived,
        completedAt: latest.completedAt ?? DateTime.now(),
        isArchived: true,
      ),
    );
  }

  Future<void> delete(Task task) async {
    await repository.delete(task.id);
    await notificationScheduler.reconcile();
  }

  Future<void> clearCompleted() async {
    await repository.clearCompleted();
    await notificationScheduler.reconcile();
  }

  Future<void> cancelAllNotifications() async {
    await notificationScheduler.clear();
  }

  Future<void> snooze(Task task, Duration duration) async {
    final latest = await _latestTask(task.id) ?? task;
    final next = DateTime.now().add(duration);
    await _save(
      latest.copyWith(
        dueDate: DateTime(next.year, next.month, next.day),
        dueTime: TimeOfDay(hour: next.hour, minute: next.minute),
        status: TaskStatus.active,
        clearCompletedAt: true,
        isArchived: false,
        reminders: <Reminder>[
          Reminder(id: _uuid.v4(), taskId: task.id, dateTime: next),
        ],
      ),
    );
  }

  Future<void> reschedule(Task task, DateTime dateTime) async {
    final latest = await _latestTask(task.id) ?? task;
    await _save(
      _moveTaskSchedule(latest, dateTime).copyWith(
        status: TaskStatus.active,
        clearCompletedAt: true,
        isArchived: false,
      ),
    );
  }

  Future<bool> toggleFromWidget(String taskId) async {
    final task = await repository.getById(taskId);
    if (task == null) {
      return false;
    }
    if (task.isCompleted) {
      await restore(task);
    } else {
      await complete(task);
    }
    return true;
  }

  Future<void> _save(Task task) async {
    await repository.upsert(task);
    await notificationScheduler.reconcile();
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
    return task.copyWith(
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
    );
  }

  Future<Task?> _latestTask(String taskId) => repository.getById(taskId);
}
