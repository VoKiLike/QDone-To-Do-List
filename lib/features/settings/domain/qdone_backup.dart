import 'dart:convert';

import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';

class QDoneBackup {
  const QDoneBackup._();

  static const schemaVersion = 2;

  static String encode({
    required List<Task> tasks,
    required UserSettings settings,
  }) {
    return const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
      'app': 'QDone',
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings.toJson(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
    });
  }

  static QDoneBackupPayload decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return QDoneBackupPayload(
        settings: const UserSettings(),
        tasks: _decodeTasks(decoded),
        includesSettings: false,
      );
    }
    if (decoded is! Map) {
      throw const FormatException('Файл должен содержать JSON-объект QDone.');
    }
    final map = Map<String, dynamic>.from(decoded);
    final version = map['schemaVersion'];
    if (version is num && version.toInt() > schemaVersion) {
      throw FormatException(
        'Версия JSON ${version.toInt()} новее поддерживаемой '
        '$schemaVersion.',
      );
    }
    final tasksRaw = map['tasks'];
    final settingsRaw = map['settings'];
    if (tasksRaw is! List) {
      throw const FormatException('В JSON должен быть раздел tasks.');
    }
    return QDoneBackupPayload(
      settings: settingsRaw is Map
          ? UserSettings.fromJson(Map<String, dynamic>.from(settingsRaw))
          : const UserSettings(),
      tasks: _decodeTasks(tasksRaw),
      includesSettings: settingsRaw is Map,
    );
  }

  static List<Task> _decodeTasks(List<dynamic> source) {
    final tasks = <Task>[];
    final ids = <String>{};
    for (var index = 0; index < source.length; index++) {
      final item = source[index];
      if (item is! Map) {
        throw FormatException('Задача ${index + 1} имеет неверный формат.');
      }
      final task = Task.fromJson(Map<String, dynamic>.from(item));
      if (!ids.add(task.id)) {
        throw FormatException('Повторяющийся id задачи: ${task.id}.');
      }
      tasks.add(task);
    }
    return tasks;
  }
}

class QDoneBackupPayload {
  const QDoneBackupPayload({
    required this.settings,
    required this.tasks,
    this.includesSettings = true,
  });

  final UserSettings settings;
  final List<Task> tasks;
  final bool includesSettings;
}
