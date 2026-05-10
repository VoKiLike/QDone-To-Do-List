import 'package:flutter/material.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/reminder.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task_category.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task_enums.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.dueDate,
    required this.dueTime,
    this.completedAt,
    this.status = TaskStatus.active,
    this.priority = TaskPriority.medium,
    required this.category,
    this.recurrenceRule = const RecurrenceRule(),
    this.reminders = const <Reminder>[],
    this.notificationIds = const <int>[],
    this.energyLevel = EnergyLevel.medium,
    this.isArchived = false,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final DateTime? completedAt;
  final TaskStatus status;
  final TaskPriority priority;
  final TaskCategory category;
  final RecurrenceRule recurrenceRule;
  final List<Reminder> reminders;
  final List<int> notificationIds;
  final EnergyLevel energyLevel;
  final bool isArchived;

  bool get isCompleted =>
      status == TaskStatus.completed || status == TaskStatus.archived;

  DateTime get dueDateTime => DateTime(
    dueDate.year,
    dueDate.month,
    dueDate.day,
    dueTime.hour,
    dueTime.minute,
  );

  bool get isOverdue => !isCompleted && dueDateTime.isBefore(DateTime.now());

  Task effectiveStatus([DateTime? now]) {
    final reference = now ?? DateTime.now();
    if (isArchived) {
      return copyWith(status: TaskStatus.archived);
    }
    if (status == TaskStatus.completed) {
      return this;
    }
    if (dueDateTime.isBefore(reference)) {
      return copyWith(status: TaskStatus.overdue);
    }
    return copyWith(status: TaskStatus.active);
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    TaskStatus? status,
    TaskPriority? priority,
    TaskCategory? category,
    RecurrenceRule? recurrenceRule,
    List<Reminder>? reminders,
    List<int>? notificationIds,
    EnergyLevel? energyLevel,
    bool? isArchived,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      reminders: reminders ?? this.reminders,
      notificationIds: notificationIds ?? this.notificationIds,
      energyLevel: energyLevel ?? this.energyLevel,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'dueTime': '${dueTime.hour}:${dueTime.minute}',
    'completedAt': completedAt?.toIso8601String(),
    'status': status.name,
    'priority': priority.name,
    'category': category.toJson(),
    'recurrenceRule': recurrenceRule.toJson(),
    'reminders': reminders.map((reminder) => reminder.toJson()).toList(),
    'notificationIds': notificationIds,
    'energyLevel': energyLevel.name,
    'isArchived': isArchived,
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    final dueParts = (json['dueTime'] as String? ?? '9:0').split(':');
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      dueTime: TimeOfDay(
        hour: int.parse(dueParts.first),
        minute: int.parse(dueParts.last),
      ),
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
      status: TaskStatus.values.byName(
        json['status'] as String? ?? TaskStatus.active.name,
      ),
      priority: TaskPriority.values.byName(
        json['priority'] as String? ?? TaskPriority.medium.name,
      ),
      category: TaskCategory.fromJson(
        Map<String, dynamic>.from(json['category'] as Map),
      ),
      recurrenceRule: RecurrenceRule.fromJson(
        Map<String, dynamic>.from(
          json['recurrenceRule'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      reminders: (json['reminders'] as List? ?? const <Object?>[])
          .map(
            (item) => Reminder.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      notificationIds: List<int>.from(
        json['notificationIds'] as List? ?? const <int>[],
      ),
      energyLevel: EnergyLevel.values.byName(
        json['energyLevel'] as String? ?? EnergyLevel.medium.name,
      ),
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }
}
