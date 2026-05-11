import 'package:flutter/material.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';

class RecurrenceRule {
  const RecurrenceRule({
    this.type = RecurrenceType.none,
    this.interval = 1,
    this.intervalUnit = RecurrenceIntervalUnit.days,
    this.selectedWeekdays = const <int>[],
    this.selectedMonthDays = const <int>[],
    this.timesOfDay = const <TimeOfDay>[],
    this.startDate,
    this.endDate,
    this.isEnabled = false,
  });

  final RecurrenceType type;
  final int interval;
  final RecurrenceIntervalUnit intervalUnit;
  final List<int> selectedWeekdays;
  final List<int> selectedMonthDays;
  final List<TimeOfDay> timesOfDay;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isEnabled;

  bool get hasMultipleTimes => timesOfDay.length > 1;

  String get summary {
    if (!isEnabled || type == RecurrenceType.none) {
      return 'Без повтора';
    }
    if (type != RecurrenceType.custom) {
      return type.label;
    }
    final unit = intervalUnit.label;
    final times = timesOfDay.isEmpty
        ? ''
        : ' в ${timesOfDay.map((time) => time.format24).join(', ')}';
    return 'Каждые $interval $unit$times';
  }

  RecurrenceRule copyWith({
    RecurrenceType? type,
    int? interval,
    RecurrenceIntervalUnit? intervalUnit,
    List<int>? selectedWeekdays,
    List<int>? selectedMonthDays,
    List<TimeOfDay>? timesOfDay,
    DateTime? startDate,
    DateTime? endDate,
    bool? isEnabled,
  }) {
    return RecurrenceRule(
      type: type ?? this.type,
      interval: interval ?? this.interval,
      intervalUnit: intervalUnit ?? this.intervalUnit,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      selectedMonthDays: selectedMonthDays ?? this.selectedMonthDays,
      timesOfDay: timesOfDay ?? this.timesOfDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type.name,
    'interval': interval,
    'intervalUnit': intervalUnit.name,
    'selectedWeekdays': selectedWeekdays,
    'selectedMonthDays': selectedMonthDays,
    'timesOfDay': timesOfDay
        .map((time) => '${time.hour}:${time.minute}')
        .toList(),
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isEnabled': isEnabled,
  };

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    return RecurrenceRule(
      type: _enumByName(
        RecurrenceType.values,
        json['type'],
        RecurrenceType.none,
      ),
      interval: json['interval'] as int? ?? 1,
      intervalUnit: _enumByName(
        RecurrenceIntervalUnit.values,
        json['intervalUnit'],
        RecurrenceIntervalUnit.days,
      ),
      selectedWeekdays: (json['selectedWeekdays'] as List? ?? const <Object?>[])
          .whereType<int>()
          .toList(),
      selectedMonthDays:
          (json['selectedMonthDays'] as List? ?? const <Object?>[])
              .whereType<int>()
              .toList(),
      timesOfDay: (json['timesOfDay'] as List? ?? const <Object?>[])
          .whereType<String>()
          .map(_parseTimeOfDay)
          .whereType<TimeOfDay>()
          .toList(),
      startDate: _parseDateTime(json['startDate']),
      endDate: _parseDateTime(json['endDate']),
      isEnabled: json['isEnabled'] as bool? ?? false,
    );
  }
}

DateTime? _parseDateTime(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

TimeOfDay? _parseTimeOfDay(String value) {
  final parts = value.split(':');
  if (parts.length != 2) {
    return null;
  }
  final hour = int.tryParse(parts.first);
  final minute = int.tryParse(parts.last);
  if (hour == null ||
      minute == null ||
      hour < 0 ||
      hour > 23 ||
      minute < 0 ||
      minute > 59) {
    return null;
  }
  return TimeOfDay(hour: hour, minute: minute);
}

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  if (name is! String) {
    return fallback;
  }
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return fallback;
}

extension TimeOfDayFormatting on TimeOfDay {
  String get format24 {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
