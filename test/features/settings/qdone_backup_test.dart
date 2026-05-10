import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/settings/domain/qdone_backup.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';

void main() {
  test('exports and imports tasks with settings', () {
    final task = Task(
      id: 'task-1',
      title: 'Проверить экспорт',
      createdAt: DateTime(2026, 1, 1, 9),
      dueDate: DateTime(2026, 1, 2),
      dueTime: const TimeOfDay(hour: 10, minute: 30),
      category: const TaskCategory(
        id: 'personal',
        name: 'Личное',
        colorValue: 0xFF8B5CF6,
      ),
    );
    const settings = UserSettings(defaultReminderMinutes: 30);

    final raw = QDoneBackup.encode(tasks: <Task>[task], settings: settings);
    final payload = QDoneBackup.decode(raw);

    expect(payload.tasks, hasLength(1));
    expect(payload.tasks.single.title, 'Проверить экспорт');
    expect(payload.settings.defaultReminderMinutes, 30);
  });

  test('rejects invalid backup json', () {
    expect(
      () => QDoneBackup.decode('{"tasks": []}'),
      throwsA(isA<FormatException>()),
    );
  });
}
