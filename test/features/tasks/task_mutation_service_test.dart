import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/core/notifications/notification_scheduler.dart';
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
    final scheduler = _FakeScheduler();
    final service = _service(repository, scheduler);

    await service.reschedule(
      repository.tasks.single,
      DateTime(2026, 5, 12, 14, 30),
    );

    final task = repository.tasks.single;
    expect(task.status, TaskStatus.active);
    expect(task.isArchived, isFalse);
    expect(task.completedAt, isNull);
    expect(task.dueTime, const TimeOfDay(hour: 14, minute: 30));
    expect(scheduler.reconciliations, 1);
  });

  test('widget toggle restores completed task', () async {
    final repository = _MemoryTaskRepository(<Task>[
      _task(
        id: 'done',
        status: TaskStatus.completed,
        completedAt: DateTime(2026, 5, 10),
      ),
    ]);
    final scheduler = _FakeScheduler();

    final changed = await _service(
      repository,
      scheduler,
    ).toggleFromWidget('done');

    expect(changed, isTrue);
    expect(repository.tasks.single.status, TaskStatus.active);
    expect(repository.tasks.single.completedAt, isNull);
    expect(scheduler.reconciliations, 1);
  });

  test('complete preserves reminder intent', () async {
    final repository = _MemoryTaskRepository(<Task>[
      _taskWithReminder(id: 'reminded'),
    ]);
    final scheduler = _FakeScheduler();

    await _service(repository, scheduler).complete(repository.tasks.single);

    final task = repository.tasks.single;
    expect(task.status, TaskStatus.completed);
    expect(task.reminders, hasLength(1));
    expect(task.reminders.single.isEnabled, isTrue);
    expect(scheduler.reconciliations, 1);
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

    await _service(
      repository,
      _FakeScheduler(),
    ).complete(repository.tasks.single);

    final task = repository.tasks.single;
    expect(task.status, TaskStatus.active);
    expect(task.completedAt, isNotNull);
    expect(task.dueDate, DateTime(2026, 5, 11));
  });

  test('delete removes latest task and reconciles schedule', () async {
    final repository = _MemoryTaskRepository(<Task>[
      _taskWithReminder(id: 'delete-me'),
    ]);
    final scheduler = _FakeScheduler();

    await _service(repository, scheduler).delete(_task(id: 'delete-me'));

    expect(repository.tasks, isEmpty);
    expect(scheduler.reconciliations, 1);
  });

  test('cancel all clears schedule through coordinator', () async {
    final scheduler = _FakeScheduler();

    await _service(
      _MemoryTaskRepository(const <Task>[]),
      scheduler,
    ).cancelAllNotifications();

    expect(scheduler.clears, 1);
  });
}

TaskMutationService _service(
  _MemoryTaskRepository repository,
  _FakeScheduler scheduler,
) {
  return TaskMutationService(
    repository: repository,
    notificationScheduler: scheduler,
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

Task _taskWithReminder({required String id}) {
  return _task(id: id).copyWith(
    dueDate: DateTime(2099, 5, 10),
    reminders: <Reminder>[
      Reminder(
        id: 'reminder-$id',
        taskId: id,
        dateTime: DateTime(2099, 5, 10, 8, 45),
      ),
    ],
  );
}

class _MemoryTaskRepository implements TaskRepository {
  _MemoryTaskRepository(List<Task> tasks) : tasks = List<Task>.of(tasks);

  final List<Task> tasks;

  @override
  Future<void> initialize() async {}

  @override
  Future<Task?> getById(String taskId) async {
    for (final task in tasks) {
      if (task.id == taskId) {
        return task;
      }
    }
    return null;
  }

  @override
  Future<List<Task>> readAll() async => List<Task>.of(tasks);

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
  Future<TaskCounts> readCounts() async => TaskCounts(
    current: tasks.where((task) => !task.isCompleted).length,
    completed: tasks.where((task) => task.isCompleted).length,
  );

  @override
  Future<TaskDailySummary> readDailySummary() async => const TaskDailySummary();

  @override
  Future<TaskPage> readSectionPage(
    TaskSectionKind section, {
    TaskPageCursor? cursor,
    int limit = TaskRepository.defaultPageSize,
  }) async => TaskPage(tasks: tasks.take(limit).toList());

  @override
  Future<List<Task>> readForDay(DateTime day) async => List<Task>.of(tasks);

  @override
  Future<List<Task>> readForRange(DateTime from, DateTime to) async =>
      List<Task>.of(tasks);

  @override
  Future<List<Task>> readNotificationCandidates(
    DateTime from,
    DateTime to,
  ) async => List<Task>.of(tasks);

  @override
  Future<List<Task>> readCompletedPage({
    int limit = 50,
    int offset = 0,
  }) async =>
      tasks.where((task) => task.isCompleted).skip(offset).take(limit).toList();

  @override
  Future<void> reloadExternal() async {}
}

class _FakeScheduler implements NotificationScheduleCoordinator {
  int reconciliations = 0;
  int clears = 0;

  @override
  Future<NotificationSchedulerStatus> reconcile({
    bool forceReset = false,
  }) async {
    reconciliations++;
    return status();
  }

  @override
  Future<NotificationSchedulerStatus> clear() async {
    clears++;
    return status();
  }

  @override
  Future<NotificationSchedulerStatus> status() async {
    return const NotificationSchedulerStatus(
      scheduledCount: 0,
      maxScheduledCount: 48,
      lastSyncedAt: null,
    );
  }
}
