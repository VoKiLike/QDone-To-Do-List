import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:qdone/features/tasks/data/repositories/local_task_repository.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('clearCompleted keeps active tasks', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalTaskRepository(TaskLocalDataSource(preferences));
    final active = _task(id: 'active', status: TaskStatus.active);
    final completed = _task(id: 'completed', status: TaskStatus.completed);
    final archived = _task(id: 'archived', status: TaskStatus.archived);

    await repository.saveAll(<Task>[active, completed, archived]);
    await repository.clearCompleted();

    final tasks = await repository.watchAll();
    expect(tasks.map((task) => task.id), <String>['active']);
  });

  test('hasSavedTasks distinguishes empty store from deleted tasks', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalTaskRepository(TaskLocalDataSource(preferences));

    expect(await repository.hasSavedTasks(), isFalse);

    await repository.saveAll(const <Task>[]);

    expect(await repository.hasSavedTasks(), isTrue);
  });
}

Task _task({required String id, required TaskStatus status}) {
  return Task(
    id: id,
    title: id,
    createdAt: DateTime(2026, 1, 1),
    dueDate: DateTime(2026, 1, 2),
    dueTime: const TimeOfDay(hour: 9, minute: 0),
    status: status,
    category: const TaskCategory(
      id: 'personal',
      name: 'Личное',
      colorValue: 0xFF8B5CF6,
    ),
  );
}
