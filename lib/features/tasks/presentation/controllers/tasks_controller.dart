import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdone/app/app_providers.dart';
import 'package:qdone/core/notifications/notification_scheduler.dart';
import 'package:qdone/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/repositories/task_repository.dart';
import 'package:qdone/features/tasks/domain/services/task_mutation_service.dart';

final tasksControllerProvider =
    StateNotifierProvider<TasksController, AsyncValue<TasksFeedState>>((ref) {
      return TasksController(
        ref.watch(taskRepositoryProvider),
        ref.watch(notificationSchedulerProvider),
      )..load();
    });

final taskByIdProvider = FutureProvider.family<Task?, String>((ref, taskId) {
  ref.watch(tasksControllerProvider);
  return ref.watch(taskRepositoryProvider).getById(taskId);
});

final tasksForDayProvider = FutureProvider.family<List<Task>, DateTime>((
  ref,
  date,
) {
  ref.watch(tasksControllerProvider);
  return ref.watch(taskRepositoryProvider).readForDay(date);
});

final tasksForRangeProvider = FutureProvider.family<List<Task>, TaskDateRange>((
  ref,
  range,
) {
  ref.watch(tasksControllerProvider);
  return ref.watch(taskRepositoryProvider).readForRange(range.from, range.to);
});

final completedTasksPageProvider = FutureProvider<List<Task>>((ref) {
  ref.watch(tasksControllerProvider);
  return ref.watch(taskRepositoryProvider).readCompletedPage();
});

class TasksController extends StateNotifier<AsyncValue<TasksFeedState>> {
  TasksController(
    TaskRepository repository,
    NotificationScheduleCoordinator notificationScheduler,
  ) : _repository = repository,
      _notificationScheduler = notificationScheduler,
      _mutations = TaskMutationService(
        repository: repository,
        notificationScheduler: notificationScheduler,
      ),
      super(const AsyncValue.loading());

  final TaskRepository _repository;
  final NotificationScheduleCoordinator _notificationScheduler;
  final TaskMutationService _mutations;
  bool _notificationRefreshQueued = false;

  Future<void> load() => _reload(showLoading: true);

  Future<void> reloadExternal() async {
    await _repository.reloadExternal();
    await _reload(showLoading: false);
    scheduleNotificationRefresh();
  }

  Future<void> _reload({required bool showLoading}) async {
    if (showLoading) {
      state = const AsyncValue.loading();
    }
    final previous = state.valueOrNull;
    try {
      await _repository.initialize();
      final counts = await _repository.readCounts();
      final summary = await _repository.readDailySummary();
      final sections = <TaskSectionKind, TaskSectionFeed>{};
      for (final section in TaskSectionKind.values) {
        final page = await _repository.readSectionPage(section);
        sections[section] = TaskSectionFeed(
          tasks: _withEffectiveStatus(page.tasks),
          totalCount: counts.forSection(section),
          nextCursor: page.nextCursor,
        );
      }
      state = AsyncValue.data(
        TasksFeedState(
          sections: sections,
          counts: counts,
          dailySummary: summary,
        ),
      );
    } catch (error, stackTrace) {
      if (!showLoading && previous != null) {
        state = AsyncValue.data(previous);
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> loadMore(TaskSectionKind section) async {
    final current = state.valueOrNull;
    final currentSection = current?.sections[section];
    if (current == null ||
        currentSection == null ||
        currentSection.isLoadingMore ||
        currentSection.nextCursor == null) {
      return;
    }
    state = AsyncValue.data(
      current.copyWithSection(
        section,
        currentSection.copyWith(isLoadingMore: true),
      ),
    );
    try {
      final page = await _repository.readSectionPage(
        section,
        cursor: currentSection.nextCursor,
      );
      final latest = state.valueOrNull ?? current;
      final latestSection = latest.sections[section] ?? currentSection;
      state = AsyncValue.data(
        latest.copyWithSection(
          section,
          latestSection.copyWith(
            tasks: <Task>[
              ...latestSection.tasks,
              ..._withEffectiveStatus(page.tasks),
            ],
            nextCursor: page.nextCursor,
            clearNextCursor: page.nextCursor == null,
            isLoadingMore: false,
          ),
        ),
      );
    } catch (_) {
      final latest = state.valueOrNull ?? current;
      state = AsyncValue.data(
        latest.copyWithSection(
          section,
          (latest.sections[section] ?? currentSection).copyWith(
            isLoadingMore: false,
          ),
        ),
      );
    }
  }

  void scheduleNotificationRefresh({bool force = false}) {
    if (_notificationRefreshQueued) {
      return;
    }
    _notificationRefreshQueued = true;
    _trace('notification refresh');
    unawaited(
      _notificationScheduler
          .reconcile(forceReset: force)
          .catchError((_) => _notificationScheduler.status())
          .whenComplete(() => _notificationRefreshQueued = false),
    );
  }

  Future<void> _mutate(Future<void> Function() action) async {
    try {
      await action();
      await _reload(showLoading: false);
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
  }) {
    return _mutate(
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

  Future<void> updateTask(Task task) {
    return _mutate(() => _mutations.updateTask(task));
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
  }) {
    return _mutate(
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

  Future<void> complete(Task task) => _mutate(() => _mutations.complete(task));

  Future<void> restore(Task task) => _mutate(() => _mutations.restore(task));

  Future<void> archive(Task task) => _mutate(() => _mutations.archive(task));

  Future<void> delete(Task task) => _mutate(() => _mutations.delete(task));

  Future<void> clearCompleted() => _mutate(_mutations.clearCompleted);

  Future<void> cancelAllNotifications() async {
    await _mutations.cancelAllNotifications();
  }

  Future<void> snooze(Task task, Duration duration) {
    return _mutate(() => _mutations.snooze(task, duration));
  }

  Future<void> reschedule(Task task, DateTime dateTime) {
    return _mutate(() => _mutations.reschedule(task, dateTime));
  }

  List<Task> _withEffectiveStatus(List<Task> tasks) {
    return tasks.map((task) => task.effectiveStatus()).toList();
  }
}

class TasksFeedState {
  const TasksFeedState({
    required this.sections,
    required this.counts,
    required this.dailySummary,
  });

  final Map<TaskSectionKind, TaskSectionFeed> sections;
  final TaskCounts counts;
  final TaskDailySummary dailySummary;

  TaskSectionFeed section(TaskSectionKind kind) =>
      sections[kind] ?? const TaskSectionFeed();

  TasksFeedState copyWithSection(
    TaskSectionKind kind,
    TaskSectionFeed section,
  ) {
    return TasksFeedState(
      sections: <TaskSectionKind, TaskSectionFeed>{...sections, kind: section},
      counts: counts,
      dailySummary: dailySummary,
    );
  }
}

class TaskSectionFeed {
  const TaskSectionFeed({
    this.tasks = const <Task>[],
    this.totalCount = 0,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  final List<Task> tasks;
  final int totalCount;
  final TaskPageCursor? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null;

  TaskSectionFeed copyWith({
    List<Task>? tasks,
    int? totalCount,
    TaskPageCursor? nextCursor,
    bool clearNextCursor = false,
    bool? isLoadingMore,
  }) {
    return TaskSectionFeed(
      tasks: tasks ?? this.tasks,
      totalCount: totalCount ?? this.totalCount,
      nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class TaskDateRange {
  const TaskDateRange(this.from, this.to);

  final DateTime from;
  final DateTime to;

  @override
  bool operator ==(Object other) {
    return other is TaskDateRange && other.from == from && other.to == to;
  }

  @override
  int get hashCode => Object.hash(from, to);
}

void _trace(String name) {
  if (kDebugMode || kProfileMode) {
    developer.Timeline.instantSync('qdone.$name');
  }
}

class QDoneCategories {
  const QDoneCategories._();

  static const personal = TaskCategory(
    id: 'personal',
    name: 'Личное',
    colorValue: 0xFF8B5CF6,
  );
}
