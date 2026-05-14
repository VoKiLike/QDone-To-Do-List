import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/home_widget/data/home_widget_sync_service.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/tasks/domain/entities/recurrence_rule.dart';
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

  test(
    'widget payload includes overdue tasks completed today when enabled',
    () {
      const service = HomeWidgetSyncService();
      final today = _today();
      final tasks = <Task>[
        _task(
          id: 'overdue-done-today',
          title: 'Overdue done today',
          date: today.subtract(const Duration(days: 6)),
          status: TaskStatus.completed,
          completedAt: today,
        ),
        _task(
          id: 'done-yesterday',
          title: 'Done yesterday',
          date: today.subtract(const Duration(days: 6)),
          status: TaskStatus.completed,
          completedAt: today.subtract(const Duration(days: 1)),
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

      expect(payload.tasks.map((task) => task.id), <String>[
        'active',
        'overdue-done-today',
      ]);
    },
  );

  test('widget payload includes recurring completion marker for today', () {
    const service = HomeWidgetSyncService();
    final today = _today();
    final tasks = <Task>[
      _task(
        id: 'recurring',
        title: 'Recurring',
        date: today.add(const Duration(days: 1)),
        completedAt: today,
        recurrenceRule: RecurrenceRule(
          type: RecurrenceType.daily,
          interval: 1,
          isEnabled: true,
        ),
      ),
    ];

    final payload = service.buildWidgetPayload(
      tasks: tasks,
      settings: const UserSettings(
        widgetTaskLimit: 5,
        widgetShowsCompleted: true,
      ),
    );

    expect(payload.tasks, hasLength(1));
    expect(payload.tasks.single.id, 'recurring');
    expect(payload.tasks.single.isCompleted, isTrue);
    expect(payload.tasks.single.canToggle, isFalse);
  });
}

Task _task({
  required String id,
  required String title,
  DateTime? date,
  DateTime? completedAt,
  TaskStatus status = TaskStatus.active,
  RecurrenceRule recurrenceRule = const RecurrenceRule(),
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
    recurrenceRule: recurrenceRule,
  );
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
