import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/settings/presentation/controllers/settings_controller.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:qdone/features/tasks/presentation/widgets/task_form_sheet.dart';

class TaskFormModal {
  const TaskFormModal._();

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    Task? task,
    DateTime? initialDate,
    TimeOfDay? initialTime,
  }) {
    final settings =
        ref.read(settingsControllerProvider).valueOrNull ??
        const UserSettings();
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (_) {
        return TaskFormSheet(
          initialTask: task,
          initialDate: initialDate,
          initialTime: initialTime,
          defaultReminderMinutes: settings.defaultReminderMinutes,
          notificationsEnabled: settings.notificationsEnabled,
          onSubmit: (value) async {
            final controller = ref.read(tasksControllerProvider.notifier);
            if (task == null) {
              await controller.addTask(
                title: value.title,
                description: value.description,
                dueDate: value.dueDate,
                dueTime: value.dueTime,
                priority: value.priority,
                category: value.category,
                energyLevel: value.energyLevel,
                recurrenceRule: value.recurrenceRule,
                reminderTimes: value.reminderTimes,
              );
            } else {
              await controller.editTask(
                task: task,
                title: value.title,
                description: value.description,
                dueDate: value.dueDate,
                dueTime: value.dueTime,
                priority: value.priority,
                category: value.category,
                energyLevel: value.energyLevel,
                recurrenceRule: value.recurrenceRule,
                reminderTimes: value.reminderTimes,
              );
            }
          },
        );
      },
    );
  }
}
