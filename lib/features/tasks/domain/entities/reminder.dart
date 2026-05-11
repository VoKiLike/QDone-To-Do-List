class Reminder {
  const Reminder({
    required this.id,
    required this.taskId,
    required this.dateTime,
    this.notificationId,
    this.isEnabled = true,
  });

  final String id;
  final String taskId;
  final DateTime dateTime;
  final int? notificationId;
  final bool isEnabled;

  Reminder copyWith({
    String? id,
    String? taskId,
    DateTime? dateTime,
    int? notificationId,
    bool? isEnabled,
  }) {
    return Reminder(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      dateTime: dateTime ?? this.dateTime,
      notificationId: notificationId ?? this.notificationId,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'taskId': taskId,
    'dateTime': dateTime.toIso8601String(),
    'notificationId': notificationId,
    'isEnabled': isEnabled,
  };

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id:
          json['id'] as String? ??
          'reminder-${DateTime.now().microsecondsSinceEpoch}',
      taskId: json['taskId'] as String? ?? '',
      dateTime: _parseDateTime(json['dateTime']) ?? DateTime.now(),
      notificationId: json['notificationId'] is int
          ? json['notificationId'] as int
          : null,
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
