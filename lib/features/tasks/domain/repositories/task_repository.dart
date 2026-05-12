import 'package:qdone/features/tasks/domain/entities/task.dart';

abstract interface class TaskRepository {
  Future<bool> hasSavedTasks();
  Future<List<Task>> watchAll();
  Future<void> saveAll(List<Task> tasks);
  Future<void> upsert(Task task);
  Future<void> delete(String taskId);
  Future<void> clearCompleted();
}
