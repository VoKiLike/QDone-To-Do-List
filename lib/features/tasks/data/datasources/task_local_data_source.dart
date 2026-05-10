import 'dart:convert';

import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskLocalDataSource {
  const TaskLocalDataSource(this._preferences);

  static const _tasksKey = 'qdone.tasks.v1';

  final SharedPreferences _preferences;

  Future<List<Task>> readTasks() async {
    final raw = _preferences.getString(_tasksKey);
    if (raw == null || raw.isEmpty) {
      return const <Task>[];
    }
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((item) => Task.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> writeTasks(List<Task> tasks) {
    final raw = jsonEncode(tasks.map((task) => task.toJson()).toList());
    return _preferences.setString(_tasksKey, raw);
  }
}
