import 'dart:convert';

import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';

class QDoneBackup {
  const QDoneBackup._();

  static const schemaVersion = 1;

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
    if (decoded is! Map) {
      throw const FormatException('Файл должен содержать JSON-объект QDone.');
    }
    final map = Map<String, dynamic>.from(decoded);
    final tasksRaw = map['tasks'];
    final settingsRaw = map['settings'];
    if (tasksRaw is! List || settingsRaw is! Map) {
      throw const FormatException(
        'В JSON должны быть разделы settings и tasks.',
      );
    }
    return QDoneBackupPayload(
      settings: UserSettings.fromJson(Map<String, dynamic>.from(settingsRaw)),
      tasks: tasksRaw
          .map((item) => Task.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class QDoneBackupPayload {
  const QDoneBackupPayload({required this.settings, required this.tasks});

  final UserSettings settings;
  final List<Task> tasks;
}
