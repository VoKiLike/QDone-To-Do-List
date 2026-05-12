import 'package:flutter/material.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/services/recurrence_service.dart';

class TaskCalendarService {
  const TaskCalendarService({
    this.recurrenceService = const RecurrenceService(),
  });

  final RecurrenceService recurrenceService;

  List<Task> tasksForDay(List<Task> tasks, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
    final result = <Task>[];

    for (final task in tasks) {
      if (task.isArchived || task.status == TaskStatus.archived) {
        continue;
      }
      if (task.recurrenceRule.isEnabled &&
          task.recurrenceRule.type != RecurrenceType.none &&
          !task.isCompleted) {
        final occurrences = recurrenceService.occurrencesForRange(
          task: task,
          from: start,
          to: end,
        );
        result.addAll(
          occurrences.map(
            (occurrence) => task
                .copyWith(
                  dueDate: DateTime(
                    occurrence.year,
                    occurrence.month,
                    occurrence.day,
                  ),
                  dueTime: TimeOfDay(
                    hour: occurrence.hour,
                    minute: occurrence.minute,
                  ),
                )
                .effectiveStatus(),
          ),
        );
        continue;
      }

      if (_isSameDay(task.dueDate, day)) {
        result.add(task);
      }
    }

    return result;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
