import 'package:flutter/material.dart';
import 'package:flutter_to_do_list_app/features/settings/domain/user_settings.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task_enums.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetSyncService {
  const HomeWidgetSyncService();

  Future<void> sync({
    required List<Task> tasks,
    required UserSettings settings,
  }) async {
    final visibleTasks =
        tasks
            .where((task) => settings.widgetShowsCompleted || !task.isCompleted)
            .toList()
          ..sort((a, b) {
            final aWeight = a.status == TaskStatus.overdue ? 0 : 1;
            final bWeight = b.status == TaskStatus.overdue ? 0 : 1;
            final weight = aWeight.compareTo(bWeight);
            return weight == 0
                ? a.dueDateTime.compareTo(b.dueDateTime)
                : weight;
          });
    final lines = visibleTasks
        .take(settings.widgetTaskLimit)
        .map((task) {
          final prefix = task.status == TaskStatus.overdue
              ? 'Просрочено'
              : task.dueTime.format24;
          return '$prefix - ${task.title}';
        })
        .join('\n');

    await HomeWidget.saveWidgetData<String>('widget_title', 'QDone');
    await HomeWidget.saveWidgetData<String>(
      'widget_tasks',
      lines.isEmpty ? 'Нет ближайших задач' : lines,
    );
    await HomeWidget.saveWidgetData<double>(
      'widget_transparency',
      settings.widgetTransparency,
    );
    await HomeWidget.updateWidget(
      androidName: 'QDoneWidgetProvider',
      iOSName: 'QDoneWidget',
    );
  }
}

extension _TaskTimeFormat on TimeOfDay {
  String get format24 =>
      '${'$hour'.padLeft(2, '0')}:${'$minute'.padLeft(2, '0')}';
}
