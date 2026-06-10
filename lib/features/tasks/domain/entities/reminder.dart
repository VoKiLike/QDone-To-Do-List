class Reminder {
  const Reminder({
    required this.id,
    required this.taskId,
    required this.dateTime,
    this.isEnabled = true,
  });

  final String id;
  final String taskId;
  final DateTime dateTime;
  final bool isEnabled;

  Reminder copyWith({
    String? id,
    String? taskId,
    DateTime? dateTime,
    bool? isEnabled,
  }) {
    return Reminder(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      dateTime: dateTime ?? this.dateTime,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'taskId': taskId,
    'dateTime': dateTime.toIso8601String(),
    'isEnabled': isEnabled,
  };

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id:
          json['id'] as String? ??
          'reminder-${DateTime.now().microsecondsSinceEpoch}',
      taskId: json['taskId'] as String? ?? '',
      dateTime: _parseDateTime(json['dateTime']) ?? DateTime.now(),
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }
}

DateTime? _parseDateTime(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
