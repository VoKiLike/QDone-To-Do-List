import 'dart:convert';

import 'package:qdone/features/home_widget/data/widget_storage_contract.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskLocalDataSource {
  TaskLocalDataSource(this._preferences);

  static const _tasksKey = WidgetStorageContract.tasksKey;

  final SharedPreferences _preferences;

  Future<bool> hasSavedTasks() async {
    return _preferences.containsKey(_tasksKey);
  }

  List<Task> readTasksForMigration() {
    final raw = _preferences.getString(_tasksKey);
    if (raw == null || raw.isEmpty) {
      return const <Task>[];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Legacy task store is not a JSON list.');
    }
    return decoded.map((item) {
      if (item is! Map) {
        throw const FormatException('Legacy task entry is not an object.');
      }
      return Task.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<void> removeLegacyStore() async {
    await _preferences.remove(_tasksKey);
  }
}
