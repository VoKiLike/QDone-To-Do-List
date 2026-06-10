import 'package:qdone/features/tasks/data/database/qdone_database.dart';
import 'package:qdone/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/repositories/task_repository.dart';
import 'package:qdone/features/tasks/domain/services/task_calendar_service.dart';

class LocalTaskRepository implements TaskRepository {
  LocalTaskRepository(this._database, this._legacyDataSource);

  static const _migrationKey = 'tasks.storage.migrated.from.v1';

  final QDoneDatabase _database;
  final TaskLocalDataSource _legacyDataSource;
  final TaskCalendarService _calendarService = const TaskCalendarService();
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    if (await _database.metadata(_migrationKey) == 'complete') {
      _initialized = true;
      return;
    }

    final existingCount = await _database.taskCount();
    if (existingCount > 0) {
      await _database.setMetadata(_migrationKey, 'complete');
      _initialized = true;
      return;
    }

    if (!await _legacyDataSource.hasSavedTasks()) {
      await _database.setMetadata(_migrationKey, 'complete');
      _initialized = true;
      return;
    }

    final legacyTasks = _legacyDataSource.readTasksForMigration();
    await _database.transaction(() async {
      await _database.replaceTasks(legacyTasks);
      final importedCount = await _database.taskCount();
      if (importedCount != legacyTasks.length) {
        throw StateError(
          'Task migration verification failed: '
          '$importedCount/${legacyTasks.length}.',
        );
      }
      await _database.setMetadata(_migrationKey, 'complete');
    });
    await _legacyDataSource.removeLegacyStore();
    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  @override
  Future<TaskPage> readSectionPage(
    TaskSectionKind section, {
    TaskPageCursor? cursor,
    int limit = TaskRepository.defaultPageSize,
  }) async {
    await _ensureInitialized();
    return _database.taskPage(
      section: section,
      now: DateTime.now(),
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<TaskCounts> readCounts() async {
    await _ensureInitialized();
    return _database.counts(DateTime.now());
  }

  @override
  Future<TaskDailySummary> readDailySummary() async {
    await _ensureInitialized();
    return _database.dailySummary(DateTime.now());
  }

  @override
  Future<List<Task>> readForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
    final candidates = await readForRange(start, end);
    return _calendarService.tasksForDay(candidates, day);
  }

  @override
  Future<List<Task>> readForRange(DateTime from, DateTime to) async {
    await _ensureInitialized();
    return _database.tasksForRange(from, to);
  }

  @override
  Future<List<Task>> readNotificationCandidates(
    DateTime from,
    DateTime to,
  ) async {
    await _ensureInitialized();
    return _database.notificationCandidates(from: from, to: to);
  }

  @override
  Future<List<Task>> readCompletedPage({int limit = 50, int offset = 0}) async {
    await _ensureInitialized();
    return _database.completedPage(limit: limit, offset: offset);
  }

  @override
  Future<Task?> getById(String taskId) async {
    await _ensureInitialized();
    return _database.taskById(taskId);
  }

  @override
  Future<List<Task>> readAll() async {
    await _ensureInitialized();
    return _database.allTasks();
  }

  @override
  Future<void> saveAll(List<Task> tasks) async {
    await _ensureInitialized();
    await _database.replaceTasks(tasks);
  }

  @override
  Future<void> upsert(Task task) async {
    await _ensureInitialized();
    await _database.upsertTask(task);
  }

  @override
  Future<void> delete(String taskId) async {
    await _ensureInitialized();
    await _database.deleteTask(taskId);
  }

  @override
  Future<void> clearCompleted() async {
    await _ensureInitialized();
    await _database.deleteCompletedTasks();
  }

  @override
  Future<void> reloadExternal() async {
    await _ensureInitialized();
  }
}
