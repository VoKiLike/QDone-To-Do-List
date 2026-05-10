import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/services/recurrence_service.dart';

void main() {
  const service = RecurrenceService();
  const category = TaskCategory(
    id: 'health',
    name: 'Health',
    colorValue: 0xFF2DD4BF,
  );

  Task taskWithRule(RecurrenceRule rule) {
    return Task(
      id: 'task',
      title: 'Take medicine',
      createdAt: DateTime(2026, 5, 10),
      dueDate: DateTime(2026, 5, 10),
      dueTime: const TimeOfDay(hour: 8, minute: 0),
      category: category,
      recurrenceRule: rule,
    );
  }

  test('generates multiple medicine reminder times in one day', () {
    final task = taskWithRule(
      RecurrenceRule(
        type: RecurrenceType.custom,
        interval: 1,
        intervalUnit: RecurrenceIntervalUnit.days,
        startDate: DateTime(2026, 5, 10),
        timesOfDay: const <TimeOfDay>[
          TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 20, minute: 0),
        ],
        isEnabled: true,
      ),
    );

    final occurrences = service.occurrencesForRange(
      task: task,
      from: DateTime(2026, 5, 10),
      to: DateTime(2026, 5, 10, 23, 59),
    );

    expect(occurrences, <DateTime>[
      DateTime(2026, 5, 10, 8),
      DateTime(2026, 5, 10, 20),
    ]);
  });

  test('finds next same-day occurrence for recurring task completion', () {
    final task = taskWithRule(
      RecurrenceRule(
        type: RecurrenceType.custom,
        interval: 1,
        intervalUnit: RecurrenceIntervalUnit.days,
        startDate: DateTime(2026, 5, 10),
        timesOfDay: const <TimeOfDay>[
          TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 20, minute: 0),
        ],
        isEnabled: true,
      ),
    );

    final next = service.nextOccurrenceAfter(
      task: task,
      after: DateTime(2026, 5, 10, 8),
    );

    expect(next, DateTime(2026, 5, 10, 20));
  });

  test('does not emit past times after a recurring task moves forward', () {
    final task = taskWithRule(
      RecurrenceRule(
        type: RecurrenceType.custom,
        interval: 1,
        intervalUnit: RecurrenceIntervalUnit.days,
        startDate: DateTime(2026, 5, 10),
        timesOfDay: const <TimeOfDay>[
          TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 20, minute: 0),
        ],
        isEnabled: true,
      ),
    ).copyWith(dueTime: const TimeOfDay(hour: 20, minute: 0));

    final occurrences = service.occurrencesForRange(
      task: task,
      from: DateTime(2026, 5, 10),
      to: DateTime(2026, 5, 10, 23, 59),
    );

    expect(occurrences, <DateTime>[DateTime(2026, 5, 10, 20)]);
  });

  test('filters custom weekly recurrence by selected weekdays', () {
    final task = taskWithRule(
      RecurrenceRule(
        type: RecurrenceType.custom,
        interval: 1,
        intervalUnit: RecurrenceIntervalUnit.days,
        selectedWeekdays: const <int>[DateTime.monday, DateTime.thursday],
        startDate: DateTime(2026, 5, 11),
        isEnabled: true,
      ),
    );

    final occurrences = service.occurrencesForRange(
      task: task,
      from: DateTime(2026, 5, 11),
      to: DateTime(2026, 5, 17, 23, 59),
    );

    expect(occurrences.map((date) => date.weekday), <int>[
      DateTime.monday,
      DateTime.thursday,
    ]);
  });
}
