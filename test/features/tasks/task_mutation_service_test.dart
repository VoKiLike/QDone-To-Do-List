import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/core/notifications/notification_service.dart';
import 'package:qdone/features/settings/domain/settings_repository.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:qdone/features/tasks/domain/entities/reminder.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/repositories/task_repository.dart';
import 'package:qdone/features/tasks/domain/services/task_mutation_service.dart';

void main() {
  test('reschedule restores archived task to active tracking', () async {
    final repository = _MemoryTaskRepository(<Task>[
      _task(
        id: 'archived',
        status: TaskStatus.archived,
        isArchived: true,
        completedAt: DateTime(2026, 5, 10),
      ),
    ]);
    final service = _service(repository);

    await service.reschedule(
      repository.tasks.single,
      DateTime(2026, 5, 12, 14, 30),
    );

    final task = repository.tasks.single;
    expect(task.status, TaskStatus.active);
    expect(task.isArchived, isFalse);
    expect(task.completedAt, isNull);
    expect(task.notificationIds, isEmpty);
    expect(task.dueTime, const TimeOfDay(hour: 14, minute: 30));
  });

  test('widget toggle restores completed task', () async {
    final repository = _MemoryTaskRepository(<Task>[
      _task(
        id: 'done',
        status: TaskStatus.completed,
        completedAt: DateTime(2026, 5, 10),
      ),
    ]);
    final service = _service(repository);

    final changed = await service.toggleFromWidget('done');

    expect(changed, isTrue);
    expect(repository.tasks.single.status, TaskStatus.active);
    expect(repository.tasks.single.completedAt, isNull);
  });

  test(
    'complete preserves reminder intent while clearing scheduled ids',
    () async {
      final repository = _MemoryTaskRepository(<Task>[
        _taskWithReminder(
          id: 'reminded',
          notificationIds: const <int>[42],
          reminderNotificationId: 42,
        ),
      ]);
      final service = _service(repository, notificationsEnabled: true);

      await service.complete(repository.tasks.single);

      final task = repository.tasks.single;
      expect(task.status, TaskStatus.completed);
      expect(task.reminders, hasLength(1));
      expect(task.reminders.single.isEnabled, isTrue);
      expect(task.reminders.single.notificationId, isNull);
      expect(task.notificationIds, isEmpty);
    },
  );

  test('restore reschedules preserved reminders', () async {
    final repository = _MemoryTaskRepository(<Task>[
      _taskWithReminder(
        id: 'done-reminded',
        status: TaskStatus.completed,
        completedAt: DateTime(2026, 5, 10),
      ),
    ]);
    final service = _service(repository, notificationsEnabled: true);

    await service.restore(repository.tasks.single);

    final task = repository.tasks.single;
    expect(task.status, TaskStatus.active);
    expect(task.completedAt, isNull);
    expect(task.reminders.single.isEnabled, isTrue);
    expect(task.reminders.single.notificationId, isNotNull);
    expect(task.notificationIds, isNotEmpty);
  });

  test('completing recurring task advances to next occurrence', () async {
    final repository = _MemoryTaskRepository(<Task>[
      _task(
        id: 'daily',
        date: DateTime(2026, 5, 10),
        recurrenceRule: RecurrenceRule(
          type: RecurrenceType.daily,
          interval: 1,
          startDate: DateTime(2026, 5, 10),
          isEnabled: true,
        ),
      ),
    ]);
    final service = _service(repository);

    await service.complete(repository.tasks.single);

    final task = repository.tasks.single;
    expect(task.status, TaskStatus.active);
    expect(task.completedAt, isNotNull);
    expect(task.dueDate, DateTime(2026, 5, 11));
  });
}

TaskMutationService _service(
  _MemoryTaskRepository repository, {
  bool notificationsEnabled = false,
}) {
  return TaskMutationService(
    repository: repository,
    notificationService: _FakeNotificationService(),
    settingsRepository: _FakeSettingsRepository(
      notificationsEnabled: notificationsEnabled,
    ),
  );
}

Task _task({
  required String id,
  DateTime? date,
  TaskStatus status = TaskStatus.active,
  bool isArchived = false,
  DateTime? completedAt,
  RecurrenceRule recurrenceRule = const RecurrenceRule(),
}) {
  return Task(
    id: id,
    title: id,
    createdAt: DateTime(2026, 5, 1),
    dueDate: date ?? DateTime(2026, 5, 10),
    dueTime: const TimeOfDay(hour: 9, minute: 0),
    completedAt: completedAt,
    status: status,
    category: const TaskCategory(
      id: 'personal',
      name: 'Личное',
      colorValue: 0xFF8B5CF6,
    ),
    recurrenceRule: recurrenceRule,
    isArchived: isArchived,
  );
}

Task _taskWithReminder({
  required String id,
  TaskStatus status = TaskStatus.active,
  DateTime? completedAt,
  List<int> notificationIds = const <int>[],
  int? reminderNotificationId,
}) {
  final task = _task(id: id, status: status, completedAt: completedAt);
  return task.copyWith(
    dueDate: DateTime(2099, 5, 10),
    reminders: <Reminder>[
      Reminder(
        id: 'reminder-$id',
        taskId: id,
        dateTime: DateTime(2099, 5, 10, 8, 45),
        notificationId: reminderNotificationId,
      ),
    ],
    notificationIds: notificationIds,
  );
}

class _MemoryTaskRepository implements TaskRepository {
  _MemoryTaskRepository(this.tasks);

  final List<Task> tasks;

  @override
  Future<bool> hasSavedTasks() async => true;

  @override
  Future<void> clearCompleted() async {
    tasks.removeWhere((task) => task.isCompleted);
  }

  @override
  Future<void> delete(String taskId) async {
    tasks.removeWhere((task) => task.id == taskId);
  }

  @override
  Future<void> saveAll(List<Task> tasks) async {
    this.tasks
      ..clear()
      ..addAll(tasks);
  }

  @override
  Future<void> upsert(Task task) async {
    final index = tasks.indexWhere((existing) => existing.id == task.id);
    if (index == -1) {
      tasks.add(task);
    } else {
      tasks[index] = task;
    }
  }

  @override
  Future<List<Task>> watchAll() async => List<Task>.of(tasks);
}

class _FakeSettingsRepository implements SettingsRepository {
  const _FakeSettingsRepository({required this.notificationsEnabled});

  final bool notificationsEnabled;

  @override
  Future<UserSettings> read() async {
    return UserSettings(notificationsEnabled: notificationsEnabled);
  }

  @override
  Future<void> save(UserSettings settings) async {}
}

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService() : super(FlutterLocalNotificationsPlugin());

  @override
  Future<void> cancelTask(Task task) async {}

  @override
  Future<Task> scheduleTask(Task task) async {
    final ids = <int>[];
    final reminders = <Reminder>[];
    for (var index = 0; index < task.reminders.length; index++) {
      final id = 100 + index;
      ids.add(id);
      final reminder = task.reminders[index];
      reminders.add(
        Reminder(
          id: reminder.id,
          taskId: reminder.taskId,
          dateTime: reminder.dateTime,
          notificationId: id,
          isEnabled: reminder.isEnabled,
        ),
      );
    }
    return task.copyWith(reminders: reminders, notificationIds: ids);
  }
}
