import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:qdone/features/home_widget/data/widget_storage_contract.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';

class HomeWidgetSyncService {
  const HomeWidgetSyncService();

  Future<void> sync({
    required List<Task> tasks,
    required UserSettings settings,
  }) async {
    final payload = buildWidgetPayload(tasks: tasks, settings: settings);
    final lines = payload.tasks
        .map((task) => '${task.time} - ${task.title}')
        .join('\n');

    await HomeWidget.saveWidgetData<String>(
      WidgetStorageContract.widgetTitleKey,
      'QDone',
    );
    await HomeWidget.saveWidgetData<String>(
      WidgetStorageContract.widgetTasksTextKey,
      lines.isEmpty ? 'Нет ближайших задач' : lines,
    );
    await HomeWidget.saveWidgetData<String>(
      WidgetStorageContract.widgetTasksJsonKey,
      jsonEncode(payload.tasks.map((task) => task.toJson()).toList()),
    );
    await HomeWidget.saveWidgetData<double>(
      WidgetStorageContract.widgetTransparencyKey,
      settings.widgetTransparency,
    );
    await HomeWidget.saveWidgetData<bool>(
      WidgetStorageContract.widgetCompactKey,
      settings.compactWidget,
    );
    await HomeWidget.saveWidgetData<bool>(
      WidgetStorageContract.widgetShowCompletedKey,
      settings.widgetShowsCompleted,
    );
    await HomeWidget.saveWidgetData<int>(
      WidgetStorageContract.widgetTaskLimitKey,
      settings.widgetTaskLimit,
    );
    await HomeWidget.saveWidgetData<String>(
      WidgetStorageContract.widgetThemeKey,
      settings.themeMode.name,
    );
    await HomeWidget.updateWidget(
      androidName: 'QDoneWidgetProvider',
      iOSName: 'QDoneWidget',
    );
  }

  WidgetPayload buildWidgetPayload({
    required List<Task> tasks,
    required UserSettings settings,
  }) {
    final visibleTasks =
        tasks
            .where((task) => settings.widgetShowsCompleted || !task.isCompleted)
            .map((task) => task.effectiveStatus())
            .toList()
          ..sort(_compareForWidget);

    return WidgetPayload(
      tasks: visibleTasks
          .take(settings.widgetTaskLimit)
          .map(WidgetTask.fromTask)
          .toList(),
    );
  }

  int _compareForWidget(Task a, Task b) {
    final aWeight = a.isCompleted ? 1 : 0;
    final bWeight = b.isCompleted ? 1 : 0;
    final weight = aWeight.compareTo(bWeight);
    return weight == 0 ? a.dueDateTime.compareTo(b.dueDateTime) : weight;
  }
}

class WidgetPayload {
  const WidgetPayload({required this.tasks});

  final List<WidgetTask> tasks;
}

class WidgetTask {
  const WidgetTask({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    required this.status,
    required this.priority,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final String time;
  final String category;
  final String status;
  final String priority;
  final bool isCompleted;

  factory WidgetTask.fromTask(Task task) {
    return WidgetTask(
      id: task.id,
      title: task.title,
      time: task.status == TaskStatus.overdue ? 'Проср.' : task.dueTime.format24,
      category: task.category.name,
      status: task.status.name,
      priority: task.priority.name,
      isCompleted: task.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'time': time,
    'category': category,
    'status': status,
    'priority': priority,
    'isCompleted': isCompleted,
  };
}

extension _TaskTimeFormat on TimeOfDay {
  String get format24 =>
      '${'$hour'.padLeft(2, '0')}:${'$minute'.padLeft(2, '0')}';
}
