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
import 'package:qdone/features/tasks/domain/services/recurrence_service.dart';
import 'package:uuid/uuid.dart';

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
  return _tasksForDay(tasks, date);
});

class TasksController extends StateNotifier<AsyncValue<List<Task>>> {
  TasksController(
    this._repository,
    this._notificationService,
    this._settingsRepository,
  ) : super(const AsyncValue.loading());

  final TaskRepository _repository;
  final NotificationService _notificationService;
  final SettingsRepository _settingsRepository;
  final _uuid = const Uuid();
  final _recurrenceService = const RecurrenceService();

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final stored = await _repository.watchAll();
      final tasks = stored.isEmpty
          ? _seedTasks()
          : _localizeBuiltInTasks(stored);
      if (stored.isEmpty) {
        await _repository.saveAll(tasks);
      } else {
        await _repository.saveAll(tasks);
      }
      state = AsyncValue.data(_withEffectiveStatus(tasks));
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
      category: category ?? QDoneCategories.personal,
      recurrenceRule: recurrenceRule,
      reminders: reminderTimes
          .map(
            (dateTime) =>
                Reminder(id: _uuid.v4(), taskId: id, dateTime: dateTime),
          )
          .toList(),
      energyLevel: energyLevel,
    );
    await _repository.upsert(await _scheduleIfAllowed(task));
    await load();
  }

  Future<void> updateTask(Task task) async {
    await _repository.upsert(await _scheduleIfAllowed(task));
    await load();
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
    await _notificationService.cancelTask(task);
    await updateTask(
      task.copyWith(
        title: title,
        description: description,
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
    await _notificationService.cancelTask(task);
    if (task.recurrenceRule.isEnabled &&
        task.recurrenceRule.type != RecurrenceType.none) {
      final nextOccurrence = _recurrenceService.nextOccurrenceAfter(
        task: task,
        after: task.dueDateTime,
      );
      if (nextOccurrence != null) {
        final nextTask = await _scheduleIfAllowed(
          task.copyWith(
            dueDate: DateTime(
              nextOccurrence.year,
              nextOccurrence.month,
              nextOccurrence.day,
            ),
            dueTime: TimeOfDay(
              hour: nextOccurrence.hour,
              minute: nextOccurrence.minute,
            ),
            status: TaskStatus.active,
            clearCompletedAt: true,
            notificationIds: const <int>[],
          ),
        );
        await _repository.upsert(nextTask);
        await load();
        return;
      }
    }

    await _repository.upsert(
      task.copyWith(status: TaskStatus.completed, completedAt: DateTime.now()),
    );
    await load();
  }

  Future<void> restore(Task task) async {
    await _repository.upsert(
      await _scheduleIfAllowed(
        task.copyWith(
          status: TaskStatus.active,
          clearCompletedAt: true,
          isArchived: false,
          notificationIds: const <int>[],
        ),
      ),
    );
    await load();
  }

  Future<void> archive(Task task) async {
    await _notificationService.cancelTask(task);
    await _repository.upsert(
      task.copyWith(
        status: TaskStatus.archived,
        completedAt: task.completedAt ?? DateTime.now(),
        isArchived: true,
      ),
    );
    await load();
  }

  Future<void> delete(Task task) async {
    await _notificationService.cancelTask(task);
    await _repository.delete(task.id);
    await load();
  }

  Future<void> clearCompleted() async {
    final tasks = await _repository.watchAll();
    for (final task in tasks.where((task) => task.isCompleted)) {
      await _notificationService.cancelTask(task);
    }
    await _repository.clearCompleted();
    await load();
  }

  Future<void> snooze(Task task, Duration duration) async {
    await _notificationService.cancelTask(task);
    final next = DateTime.now().add(duration);
    await _repository.upsert(
      await _scheduleIfAllowed(
        task.copyWith(
          dueDate: DateTime(next.year, next.month, next.day),
          dueTime: TimeOfDay(hour: next.hour, minute: next.minute),
          status: TaskStatus.active,
          reminders: <Reminder>[
            Reminder(id: _uuid.v4(), taskId: task.id, dateTime: next),
          ],
          notificationIds: const <int>[],
        ),
      ),
    );
    await load();
  }

  Future<void> reschedule(Task task, DateTime dateTime) async {
    await _notificationService.cancelTask(task);
    await _repository.upsert(
      await _scheduleIfAllowed(
        task.copyWith(
          dueDate: DateTime(dateTime.year, dateTime.month, dateTime.day),
          dueTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
          status: TaskStatus.active,
          notificationIds: const <int>[],
        ),
      ),
    );
    await load();
  }

  Future<Task> _scheduleIfAllowed(Task task) async {
    final settings = await _settingsRepository.read();
    if (!settings.notificationsEnabled || task.reminders.isEmpty) {
      return task.copyWith(notificationIds: const <int>[]);
    }
    return _notificationService.scheduleTask(task);
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

List<Task> _localizeBuiltInTasks(List<Task> tasks) {
  return tasks.map((task) {
    return switch (task.id) {
      'seed-medicine' => task.copyWith(
        title: 'Принять лекарство',
        description: 'Утренний и вечерний прием таблеток',
        category: QDoneCategories.health,
      ),
      'seed-study' => task.copyWith(
        title: 'Изучить анимации Flutter',
        description: 'Доработать стеклянные переходы навигации',
        category: QDoneCategories.learning,
      ),
      'seed-overdue' => task.copyWith(
        title: 'Отправить счет по проекту',
        category: QDoneCategories.work,
      ),
      'seed-future' => task.copyWith(
        title: 'Запланировать недельный обзор',
        category: QDoneCategories.personal,
      ),
      'seed-completed' => task.copyWith(
        title: 'Разобрать архив выполненных',
        category: QDoneCategories.personal,
      ),
      _ => task,
    };
  }).toList();
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

List<Task> _tasksForDay(List<Task> tasks, DateTime day) {
  final recurrenceService = const RecurrenceService();
  final start = DateTime(day.year, day.month, day.day);
  final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
  final result = <Task>[];

  for (final task in tasks) {
    if (task.recurrenceRule.isEnabled &&
        task.recurrenceRule.type != RecurrenceType.none &&
        !task.isArchived) {
      final occurrences = recurrenceService.occurrencesForRange(
        task: task,
        from: start,
        to: end,
      );
      result.addAll(
        occurrences.map(
          (occurrence) => task
              .copyWith(
                dueDate: DateTime(
                  occurrence.year,
                  occurrence.month,
                  occurrence.day,
                ),
                dueTime: TimeOfDay(
                  hour: occurrence.hour,
                  minute: occurrence.minute,
                ),
              )
              .effectiveStatus(),
        ),
      );
      continue;
    }

    if (_isSameDay(task.dueDate, day)) {
      result.add(task);
    }
  }

  return result;
}
