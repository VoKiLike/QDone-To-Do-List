import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/home_widget/data/widget_storage_contract.dart';
import 'package:qdone/features/tasks/data/database/qdone_database.dart';
import 'package:qdone/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:qdone/features/tasks/data/repositories/local_task_repository.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/repositories/task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late QDoneDatabase database;

  setUp(() {
    database = QDoneDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('clearCompleted keeps active tasks', () async {
    final repository = await _repository(database);
    final active = _task(id: 'active', status: TaskStatus.active);
    final completed = _task(id: 'completed', status: TaskStatus.completed);
    final archived = _task(id: 'archived', status: TaskStatus.archived);

    await repository.saveAll(<Task>[active, completed, archived]);
    await repository.clearCompleted();

    final tasks = await repository.readAll();
    expect(tasks.map((task) => task.id), <String>['active']);
  });

  test('empty installation stays empty without demo tasks', () async {
    final repository = await _repository(database);

    await repository.initialize();

    expect(await repository.readAll(), isEmpty);
  });

  test('imports legacy SharedPreferences once and removes source', () async {
    final legacyTasks = List<Task>.generate(
      40,
      (index) => _task(id: 'legacy-$index', status: TaskStatus.active),
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      WidgetStorageContract.tasksKey: jsonEncode(
        legacyTasks.map((task) => task.toJson()).toList(),
      ),
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalTaskRepository(
      database,
      TaskLocalDataSource(preferences),
    );

    await repository.initialize();
    await repository.initialize();

    expect(await repository.readAll(), hasLength(40));
    expect(preferences.containsKey(WidgetStorageContract.tasksKey), isFalse);
  });

  test('damaged legacy JSON rolls back and keeps source', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      WidgetStorageContract.tasksKey: '[{"id":',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalTaskRepository(
      database,
      TaskLocalDataSource(preferences),
    );

    await expectLater(repository.initialize(), throwsFormatException);

    expect(await database.taskCount(), 0);
    expect(preferences.containsKey(WidgetStorageContract.tasksKey), isTrue);
  });

  test('stores 10000 tasks while section query returns one page', () async {
    final repository = await _repository(database);
    final tasks = List<Task>.generate(
      10000,
      (index) => _task(id: 'task-$index', status: TaskStatus.active),
    );

    await repository.saveAll(tasks);
    final page = await repository.readSectionPage(TaskSectionKind.overdue);
    final counts = await repository.readCounts();

    expect(await database.taskCount(), 10000);
    expect(page.tasks, hasLength(TaskRepository.defaultPageSize));
    expect(page.nextCursor, isNotNull);
    expect(counts.total, 10000);
  });
}

Future<LocalTaskRepository> _repository(QDoneDatabase database) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final preferences = await SharedPreferences.getInstance();
  return LocalTaskRepository(database, TaskLocalDataSource(preferences));
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
