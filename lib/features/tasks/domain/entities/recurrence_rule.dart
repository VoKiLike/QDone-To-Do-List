import 'package:flutter/material.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task_enums.dart';

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
      type: RecurrenceType.values.byName(
        json['type'] as String? ?? RecurrenceType.none.name,
      ),
      interval: json['interval'] as int? ?? 1,
      intervalUnit: RecurrenceIntervalUnit.values.byName(
        json['intervalUnit'] as String? ?? RecurrenceIntervalUnit.days.name,
      ),
      selectedWeekdays: List<int>.from(
        json['selectedWeekdays'] as List? ?? const <int>[],
      ),
      selectedMonthDays: List<int>.from(
        json['selectedMonthDays'] as List? ?? const <int>[],
      ),
      timesOfDay: (json['timesOfDay'] as List? ?? const <Object?>[])
          .whereType<String>()
          .map((value) {
            final parts = value.split(':');
            return TimeOfDay(
              hour: int.parse(parts.first),
              minute: int.parse(parts.last),
            );
          })
          .toList(),
      startDate: DateTime.tryParse(json['startDate'] as String? ?? ''),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? ''),
      isEnabled: json['isEnabled'] as bool? ?? false,
    );
  }
}

extension TimeOfDayFormatting on TimeOfDay {
  String get format24 {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
