import 'dart:convert';

import 'package:qdone/features/home_widget/data/widget_storage_contract.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskLocalDataSource {
  const TaskLocalDataSource(this._preferences);

  static const _tasksKey = WidgetStorageContract.tasksKey;

  final SharedPreferences _preferences;

  Future<List<Task>> readTasks() async {
    await _preferences.reload();
    final raw = _preferences.getString(_tasksKey);
    if (raw == null || raw.isEmpty) {
      return const <Task>[];
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return const <Task>[];
    }
    if (decoded is! List) {
      return const <Task>[];
    }
    final tasks = <Task>[];
    for (final item in decoded) {
      if (item is! Map) {
        continue;
      }
      try {
        tasks.add(Task.fromJson(Map<String, dynamic>.from(item)));
      } catch (_) {
        continue;
      }
    }
    return tasks;
  }

  Future<void> writeTasks(List<Task> tasks) {
    final raw = jsonEncode(tasks.map((task) => task.toJson()).toList());
    return _preferences.setString(_tasksKey, raw);
  }
}
