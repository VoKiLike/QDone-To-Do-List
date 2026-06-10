import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/settings/domain/qdone_backup.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';

void main() {
  test('decodes version 1 backup with settings and legacy fields', () {
    final task = _task().toJson()
      ..['notificationIds'] = <int>[101, 102]
      ..['reminders'] = <Object>[
        <String, Object>{
          'id': 'legacy-reminder',
          'taskId': 'legacy-task',
          'dateTime': '2025-01-02T09:30:00.000',
          'isEnabled': true,
          'notificationId': 103,
        },
      ];
    final raw = jsonEncode(<String, Object>{
      'schemaVersion': 1,
      'settings': const UserSettings(widgetTaskLimit: 7).toJson(),
      'tasks': <Object>[task],
    });

    final payload = QDoneBackup.decode(raw);

    expect(payload.includesSettings, isTrue);
    expect(payload.settings.widgetTaskLimit, 7);
    expect(payload.tasks.single.toJson(), isNot(contains('notificationIds')));
    expect(
      payload.tasks.single.reminders.single.toJson(),
      isNot(contains('notificationId')),
    );
  });

  test('decodes legacy raw task list without replacing settings', () {
    final payload = QDoneBackup.decode(jsonEncode(<Object>[_task().toJson()]));

    expect(payload.includesSettings, isFalse);
    expect(payload.tasks, hasLength(1));
  });

  test('rejects duplicate ids before import', () {
    final raw = jsonEncode(<String, Object>{
      'schemaVersion': 1,
      'settings': const UserSettings().toJson(),
      'tasks': <Object>[_task().toJson(), _task().toJson()],
    });

    expect(() => QDoneBackup.decode(raw), throwsFormatException);
  });

  test('rejects a backup from a newer unsupported schema', () {
    final raw = jsonEncode(<String, Object>{
      'schemaVersion': 999,
      'settings': const UserSettings().toJson(),
      'tasks': <Object>[],
    });

    expect(() => QDoneBackup.decode(raw), throwsFormatException);
  });
}

Task _task() {
  return Task(
    id: 'legacy-task',
    title: 'Legacy task',
    createdAt: DateTime(2025, 1, 1),
    dueDate: DateTime(2025, 1, 2),
    dueTime: const TimeOfDay(hour: 9, minute: 30),
    category: const TaskCategory(
      id: 'personal',
      name: 'Личное',
      colorValue: 0xFF8B5CF6,
    ),
  );
}
