import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/home_widget/data/home_widget_sync_service.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';

void main() {
  test('widget payload respects task limit and completed visibility', () {
    const service = HomeWidgetSyncService();
    final today = _today();
    final tasks = <Task>[
      _task(id: 'done', title: 'Done', status: TaskStatus.completed),
      _task(id: 'late', title: 'Late', date: today),
      _task(
        id: 'next',
        title: 'Next',
        date: today.add(const Duration(days: 1)),
      ),
    ];

    final payload = service.buildWidgetPayload(
      tasks: tasks,
      settings: const UserSettings(
        widgetTaskLimit: 1,
        widgetShowsCompleted: false,
      ),
    );

    expect(payload.tasks, hasLength(1));
    expect(payload.tasks.single.id, 'late');
    expect(payload.tasks.single.category, 'Личное');
  });

  test('widget payload sorts active tasks before completed tasks', () {
    const service = HomeWidgetSyncService();
    final today = _today();
    final tasks = <Task>[
      _task(
        id: 'done',
        title: 'Done',
        status: TaskStatus.completed,
        completedAt: today,
      ),
      _task(id: 'active', title: 'Active', date: today),
    ];

    final payload = service.buildWidgetPayload(
      tasks: tasks,
      settings: const UserSettings(
        widgetTaskLimit: 5,
        widgetShowsCompleted: true,
      ),
    );

    expect(payload.tasks.map((task) => task.id), <String>['active', 'done']);
  });
}

Task _task({
  required String id,
  required String title,
  DateTime? date,
  DateTime? completedAt,
  TaskStatus status = TaskStatus.active,
}) {
  return Task(
    id: id,
    title: title,
    createdAt: DateTime(2026, 5, 10),
    dueDate: date ?? DateTime(2026, 5, 10),
    dueTime: const TimeOfDay(hour: 9, minute: 0),
    completedAt: completedAt,
    status: status,
    category: const TaskCategory(
      id: 'personal',
      name: 'Личное',
      colorValue: 0xFF8B5CF6,
    ),
  );
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
