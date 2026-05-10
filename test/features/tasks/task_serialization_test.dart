import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:qdone/features/tasks/domain/entities/reminder.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';

void main() {
  test('task serializes completed archive data without losing reminders', () {
    final task = Task(
      id: 'id',
      title: 'Archive task',
      description: 'Keep completion history',
      createdAt: DateTime(2026, 5, 10),
      dueDate: DateTime(2026, 5, 11),
      dueTime: const TimeOfDay(hour: 9, minute: 30),
      completedAt: DateTime(2026, 5, 12),
      status: TaskStatus.completed,
      priority: TaskPriority.high,
      category: const TaskCategory(
        id: 'work',
        name: 'Work',
        colorValue: 0xFF38BDF8,
      ),
      recurrenceRule: const RecurrenceRule(
        type: RecurrenceType.daily,
        isEnabled: true,
      ),
      reminders: <Reminder>[
        Reminder(
          id: 'reminder',
          taskId: 'id',
          dateTime: DateTime(2026, 5, 11, 9),
        ),
      ],
      notificationIds: const <int>[42],
      energyLevel: EnergyLevel.low,
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.title, task.title);
    expect(restored.status, TaskStatus.completed);
    expect(restored.completedAt, DateTime(2026, 5, 12));
    expect(restored.reminders.single.id, 'reminder');
    expect(restored.notificationIds, <int>[42]);
  });
}
