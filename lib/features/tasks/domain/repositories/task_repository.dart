import 'package:qdone/features/tasks/domain/entities/task.dart';

enum TaskSectionKind { overdue, current, future, completed }

class TaskPageCursor {
  const TaskPageCursor({required this.sortAt, required this.id});

  final DateTime sortAt;
  final String id;
}

class TaskPage {
  const TaskPage({required this.tasks, this.nextCursor});

  final List<Task> tasks;
  final TaskPageCursor? nextCursor;
}

class TaskCounts {
  const TaskCounts({
    this.overdue = 0,
    this.current = 0,
    this.future = 0,
    this.completed = 0,
  });

  final int overdue;
  final int current;
  final int future;
  final int completed;

  int forSection(TaskSectionKind section) => switch (section) {
    TaskSectionKind.overdue => overdue,
    TaskSectionKind.current => current,
    TaskSectionKind.future => future,
    TaskSectionKind.completed => completed,
  };

  int get total => overdue + current + future + completed;
}

class TaskDailySummary {
  const TaskDailySummary({
    this.completed = 0,
    this.remaining = 0,
    this.overdue = 0,
    this.nextTask,
  });

  final int completed;
  final int remaining;
  final int overdue;
  final Task? nextTask;
}

abstract interface class TaskRepository {
  static const int defaultPageSize = 50;

  Future<void> initialize();
  Future<TaskPage> readSectionPage(
    TaskSectionKind section, {
    TaskPageCursor? cursor,
    int limit = defaultPageSize,
  });
  Future<TaskCounts> readCounts();
  Future<TaskDailySummary> readDailySummary();
  Future<List<Task>> readForDay(DateTime day);
  Future<List<Task>> readForRange(DateTime from, DateTime to);
  Future<List<Task>> readNotificationCandidates(DateTime from, DateTime to);
  Future<List<Task>> readCompletedPage({int limit = 50, int offset = 0});
  Future<Task?> getById(String taskId);
  Future<List<Task>> readAll();
  Future<void> saveAll(List<Task> tasks);
  Future<void> upsert(Task task);
  Future<void> delete(String taskId);
  Future<void> clearCompleted();
  Future<void> reloadExternal();
}
