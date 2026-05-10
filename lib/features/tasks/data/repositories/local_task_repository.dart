import 'package:flutter_to_do_list_app/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task_enums.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/repositories/task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  const LocalTaskRepository(this._dataSource);

  final TaskLocalDataSource _dataSource;

  @override
  Future<List<Task>> watchAll() => _dataSource.readTasks();

  @override
  Future<void> saveAll(List<Task> tasks) => _dataSource.writeTasks(tasks);

  @override
  Future<void> upsert(Task task) async {
    final tasks = await _dataSource.readTasks();
    final index = tasks.indexWhere((existing) => existing.id == task.id);
    if (index == -1) {
      tasks.add(task);
    } else {
      tasks[index] = task;
    }
    tasks.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
    await _dataSource.writeTasks(tasks);
  }

  @override
  Future<void> delete(String taskId) async {
    final tasks = await _dataSource.readTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await _dataSource.writeTasks(tasks);
  }

  @override
  Future<void> clearCompleted() async {
    final tasks = await _dataSource.readTasks();
    tasks.removeWhere(
      (task) =>
          task.status == TaskStatus.completed ||
          task.status == TaskStatus.archived,
    );
    await _dataSource.writeTasks(tasks);
  }
}
