import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdone/app/app_providers.dart';
import 'package:qdone/core/notifications/notification_service.dart';
import 'package:qdone/features/settings/domain/settings_repository.dart';
import 'package:qdone/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:qdone/features/tasks/domain/entities/reminder.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/repositories/task_repository.dart';
import 'package:qdone/features/tasks/domain/services/task_calendar_service.dart';
import 'package:qdone/features/tasks/domain/services/task_mutation_service.dart';

final tasksControllerProvider =
    StateNotifierProvider<TasksController, AsyncValue<List<Task>>>((ref) {
      return TasksController(
        ref.watch(taskRepositoryProvider),
        ref.watch(notificationServiceProvider),
        ref.watch(settingsRepositoryProvider),
      )..load();
    });

final tasksBySelectedDateProvider = Provider.family<List<Task>, DateTime>((
  ref,
  date,
) {
  final tasks =
      ref.watch(tasksControllerProvider).valueOrNull ?? const <Task>[];
  return const TaskCalendarService().tasksForDay(tasks, date);
});

class TasksController extends StateNotifier<AsyncValue<List<Task>>> {
  TasksController(
    TaskRepository repository,
    NotificationService notificationService,
    SettingsRepository settingsRepository,
  ) : _repository = repository,
      _mutations = TaskMutationService(
        repository: repository,
        notificationService: notificationService,
        settingsRepository: settingsRepository,
      ),
      super(const AsyncValue.loading());

  final TaskRepository _repository;
  final TaskMutationService _mutations;
  bool _notificationRefreshQueued = false;

  Future<void> load() async {
    await _reload(showLoading: true);
    _refreshNotificationsInBackground();
  }

  Future<void> _reload({required bool showLoading}) async {
    if (showLoading) {
      state = const AsyncValue.loading();
    }
    final previous = state.valueOrNull;
    if (!showLoading && previous != null) {
      state = AsyncValue.data(previous);
    }
    try {
      final stored = await _repository.watchAll();
      final hasSavedTasks = await _repository.hasSavedTasks();
      final tasks = stored.isEmpty && !hasSavedTasks ? _seedTasks() : stored;
      if (stored.isEmpty && !hasSavedTasks) {
        await _repository.saveAll(tasks);
      }
      state = AsyncValue.data(_withEffectiveStatus(tasks));
    } catch (error, stackTrace) {
      if (!showLoading && previous != null) {
        state = AsyncValue.data(previous);
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> _refreshAfterMutation() => _reload(showLoading: false);

  void _refreshNotificationsInBackground() {
    if (_notificationRefreshQueued) {
      return;
    }
    _notificationRefreshQueued = true;
    unawaited(_mutations.refreshScheduledNotifications().catchError((_) {}));
  }

  Future<void> _mutate(Future<void> Function() action) async {
    try {
      await action();
      await _refreshAfterMutation();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

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
    await _mutate(
      () => _mutations.addTask(
        title: title,
        description: description,
        dueDate: dueDate,
        dueTime: dueTime,
        priority: priority,
        energyLevel: energyLevel,
        category: category ?? QDoneCategories.personal,
        recurrenceRule: recurrenceRule,
        reminderTimes: reminderTimes,
      ),
    );
  }

  Future<void> updateTask(Task task) async {
    await _mutate(() => _mutations.updateTask(task));
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
    await _mutate(
      () => _mutations.editTask(
        task: task,
        title: title,
        description: description,
        dueDate: dueDate,
        dueTime: dueTime,
        priority: priority,
        energyLevel: energyLevel,
        category: category,
        recurrenceRule: recurrenceRule,
        reminderTimes: reminderTimes,
      ),
    );
  }

  Future<void> complete(Task task) async {
    await _mutate(() => _mutations.complete(task));
  }

  Future<void> restore(Task task) async {
    await _mutate(() => _mutations.restore(task));
  }

  Future<void> archive(Task task) async {
    await _mutate(() => _mutations.archive(task));
  }

  Future<void> delete(Task task) async {
    await _mutate(() => _mutations.delete(task));
  }

  Future<void> clearCompleted() async {
    await _mutate(_mutations.clearCompleted);
  }

  Future<void> snooze(Task task, Duration duration) async {
    await _mutate(() => _mutations.snooze(task, duration));
  }

  Future<void> reschedule(Task task, DateTime dateTime) async {
    await _mutate(() => _mutations.reschedule(task, dateTime));
  }

  List<Task> _withEffectiveStatus(List<Task> tasks) {
    return tasks.map((task) => task.effectiveStatus()).toList()
      ..sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
  }
}

class QDoneCategories {
  const QDoneCategories._();

  static const personal = TaskCategory(
    id: 'personal',
    name: 'Личное',
    colorValue: 0xFF8B5CF6,
  );
  static const health = TaskCategory(
    id: 'health',
    name: 'Здоровье',
    colorValue: 0xFF2DD4BF,
  );
  static const work = TaskCategory(
    id: 'work',
    name: 'Работа',
    colorValue: 0xFF38BDF8,
  );
  static const learning = TaskCategory(
    id: 'learning',
    name: 'Учёба',
    colorValue: 0xFFA78BFA,
  );
}

List<Task> _seedTasks() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return <Task>[
    Task(
      id: 'seed-medicine',
      title: 'Принять лекарство',
      description: 'Утренний и вечерний прием таблеток',
      createdAt: now.subtract(const Duration(days: 2)),
      dueDate: today,
      dueTime: const TimeOfDay(hour: 8, minute: 0),
      priority: TaskPriority.high,
      category: QDoneCategories.health,
      energyLevel: EnergyLevel.low,
      recurrenceRule: RecurrenceRule(
        type: RecurrenceType.custom,
        interval: 1,
        intervalUnit: RecurrenceIntervalUnit.days,
        timesOfDay: const <TimeOfDay>[
          TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 20, minute: 0),
        ],
        startDate: today,
        isEnabled: true,
      ),
      reminders: <Reminder>[
        Reminder(
          id: 'seed-reminder-1',
          taskId: 'seed-medicine',
          dateTime: today.add(const Duration(hours: 8)),
        ),
        Reminder(
          id: 'seed-reminder-2',
          taskId: 'seed-medicine',
          dateTime: today.add(const Duration(hours: 20)),
        ),
      ],
    ),
    Task(
      id: 'seed-study',
      title: 'Изучить анимации Flutter',
      description: 'Доработать стеклянные переходы навигации',
      createdAt: now.subtract(const Duration(days: 1)),
      dueDate: today,
      dueTime: const TimeOfDay(hour: 10, minute: 30),
      priority: TaskPriority.medium,
      category: QDoneCategories.learning,
      energyLevel: EnergyLevel.high,
    ),
    Task(
      id: 'seed-overdue',
      title: 'Отправить счет по проекту',
      createdAt: now.subtract(const Duration(days: 5)),
      dueDate: today.subtract(const Duration(days: 1)),
      dueTime: const TimeOfDay(hour: 16, minute: 0),
      priority: TaskPriority.high,
      category: QDoneCategories.work,
      energyLevel: EnergyLevel.medium,
    ),
    Task(
      id: 'seed-future',
      title: 'Запланировать недельный обзор',
      createdAt: now,
      dueDate: today.add(const Duration(days: 3)),
      dueTime: const TimeOfDay(hour: 18, minute: 15),
      priority: TaskPriority.low,
      category: QDoneCategories.personal,
      energyLevel: EnergyLevel.low,
    ),
    Task(
      id: 'seed-completed',
      title: 'Разобрать архив выполненных',
      createdAt: now.subtract(const Duration(days: 4)),
      dueDate: today,
      dueTime: const TimeOfDay(hour: 9, minute: 0),
      completedAt: now.subtract(const Duration(hours: 2)),
      status: TaskStatus.completed,
      priority: TaskPriority.low,
      category: QDoneCategories.personal,
      energyLevel: EnergyLevel.low,
    ),
  ];
}
