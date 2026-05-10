import 'package:flutter_to_do_list_app/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task_enums.dart';

class RecurrenceService {
  const RecurrenceService();

  List<DateTime> occurrencesForRange({
    required Task task,
    required DateTime from,
    required DateTime to,
  }) {
    final rule = task.recurrenceRule;
    if (!rule.isEnabled || rule.type == RecurrenceType.none) {
      final due = task.dueDateTime;
      return due.isAfter(from.subtract(const Duration(seconds: 1))) &&
              due.isBefore(to.add(const Duration(seconds: 1)))
          ? <DateTime>[due]
          : const <DateTime>[];
    }

    final configuredStart = rule.startDate ?? task.dueDateTime;
    final start = task.dueDateTime.isAfter(configuredStart)
        ? task.dueDateTime
        : configuredStart;
    final end = rule.endDate ?? to;
    if (end.isBefore(from)) {
      return const <DateTime>[];
    }

    final occurrences = <DateTime>[];
    var cursor = DateTime(
      start.year,
      start.month,
      start.day,
      task.dueTime.hour,
      task.dueTime.minute,
    );
    var guard = 0;
    while (!cursor.isAfter(to) && guard < 1200) {
      guard++;
      if (!cursor.isAfter(end) && _matchesRule(cursor, rule)) {
        if (rule.timesOfDay.isEmpty) {
          if (!cursor.isBefore(from)) {
            occurrences.add(cursor);
          }
        } else {
          for (final time in rule.timesOfDay) {
            final occurrence = DateTime(
              cursor.year,
              cursor.month,
              cursor.day,
              time.hour,
              time.minute,
            );
            if (!occurrence.isBefore(task.dueDateTime) &&
                !occurrence.isBefore(from) &&
                !occurrence.isAfter(to) &&
                !occurrence.isAfter(end)) {
              occurrences.add(occurrence);
            }
          }
        }
      }
      cursor = _advance(cursor, rule);
    }

    occurrences.sort();
    return occurrences;
  }

  DateTime? nextOccurrenceAfter({required Task task, required DateTime after}) {
    final rule = task.recurrenceRule;
    if (!rule.isEnabled || rule.type == RecurrenceType.none) {
      return null;
    }

    final searchFrom = after.add(const Duration(minutes: 1));
    final occurrences = occurrencesForRange(
      task: task,
      from: searchFrom,
      to: searchFrom.add(const Duration(days: 370)),
    );
    return occurrences.isEmpty ? null : occurrences.first;
  }

  bool _matchesRule(DateTime date, RecurrenceRule rule) {
    if (rule.selectedWeekdays.isNotEmpty &&
        !rule.selectedWeekdays.contains(date.weekday)) {
      return false;
    }
    if (rule.selectedMonthDays.isNotEmpty &&
        !rule.selectedMonthDays.contains(date.day)) {
      return false;
    }
    return true;
  }

  DateTime _advance(DateTime date, RecurrenceRule rule) {
    final interval = rule.interval <= 0 ? 1 : rule.interval;
    return switch (rule.type) {
      RecurrenceType.daily => date.add(Duration(days: interval)),
      RecurrenceType.weekly => date.add(Duration(days: interval * 7)),
      RecurrenceType.monthly => DateTime(
        date.year,
        date.month + interval,
        date.day,
        date.hour,
        date.minute,
      ),
      RecurrenceType.yearly => DateTime(
        date.year + interval,
        date.month,
        date.day,
        date.hour,
        date.minute,
      ),
      RecurrenceType.custom => _advanceCustom(
        date,
        interval,
        rule.intervalUnit,
      ),
      RecurrenceType.none => date.add(const Duration(days: 1)),
    };
  }

  DateTime _advanceCustom(
    DateTime date,
    int interval,
    RecurrenceIntervalUnit unit,
  ) {
    return switch (unit) {
      RecurrenceIntervalUnit.minutes => date.add(Duration(minutes: interval)),
      RecurrenceIntervalUnit.hours => date.add(Duration(hours: interval)),
      RecurrenceIntervalUnit.days => date.add(Duration(days: interval)),
      RecurrenceIntervalUnit.weeks => date.add(Duration(days: interval * 7)),
      RecurrenceIntervalUnit.months => DateTime(
        date.year,
        date.month + interval,
        date.day,
        date.hour,
        date.minute,
      ),
    };
  }
}
