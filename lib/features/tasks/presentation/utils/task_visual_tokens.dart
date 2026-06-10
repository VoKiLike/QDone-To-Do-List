import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';

class TaskVisualTokens {
  const TaskVisualTokens._();

  static TaskStatus statusOf(Task task, [DateTime? now]) {
    if (task.isArchived || task.status == TaskStatus.archived) {
      return TaskStatus.archived;
    }
    if (task.status == TaskStatus.completed) {
      return TaskStatus.completed;
    }
    if (task.dueDateTime.isBefore(now ?? DateTime.now())) {
      return TaskStatus.overdue;
    }
    return TaskStatus.active;
  }

  static Color statusColor(Task task, [DateTime? now]) {
    return colorForStatus(statusOf(task, now));
  }

  static Color colorForStatusIn(BuildContext context, TaskStatus status) {
    return switch (status) {
      TaskStatus.active => AppColors.primaryFor(context),
      TaskStatus.overdue => AppColors.warningFor(context),
      TaskStatus.completed => AppColors.successFor(context),
      TaskStatus.archived => AppColors.secondaryFor(context),
    };
  }

  static Color colorForStatus(
    TaskStatus status, {
    Brightness brightness = Brightness.dark,
  }) {
    final light = brightness == Brightness.light;
    return switch (status) {
      TaskStatus.active => light ? AppColors.lightBlue : AppColors.turquoise,
      TaskStatus.overdue => light ? AppColors.lightWarning : AppColors.warning,
      TaskStatus.completed =>
        light ? AppColors.lightSuccess : AppColors.success,
      TaskStatus.archived =>
        light ? AppColors.lightViolet : AppColors.neonPurple,
    };
  }

  static IconData? statusIcon(TaskStatus status) {
    return switch (status) {
      TaskStatus.active => null,
      TaskStatus.overdue => Icons.priority_high_rounded,
      TaskStatus.completed => Icons.check_rounded,
      TaskStatus.archived => Icons.unarchive_rounded,
    };
  }

  static Color priorityColor(
    TaskPriority priority, {
    Brightness brightness = Brightness.dark,
  }) {
    final light = brightness == Brightness.light;
    return switch (priority) {
      TaskPriority.low => light ? AppColors.lightSuccess : AppColors.turquoise,
      TaskPriority.medium => light ? AppColors.lightBlue : AppColors.cyan,
      TaskPriority.high => light ? AppColors.lightWarning : AppColors.warning,
    };
  }

  static Color priorityColorIn(BuildContext context, TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => AppColors.successFor(context),
      TaskPriority.medium => AppColors.primaryFor(context),
      TaskPriority.high => AppColors.warningFor(context),
    };
  }

  static Color energyColor(
    EnergyLevel energy, {
    Brightness brightness = Brightness.dark,
  }) {
    final light = brightness == Brightness.light;
    return switch (energy) {
      EnergyLevel.low => light ? AppColors.lightBlue : AppColors.softBlueGreen,
      EnergyLevel.medium => light ? AppColors.lightViolet : AppColors.violet,
      EnergyLevel.high => light ? AppColors.lightMagenta : AppColors.neonPurple,
    };
  }

  static Color energyColorIn(BuildContext context, EnergyLevel energy) {
    return switch (energy) {
      EnergyLevel.low => AppColors.primaryFor(context),
      EnergyLevel.medium => AppColors.secondaryFor(context),
      EnergyLevel.high => AppColors.tertiaryFor(context),
    };
  }
}
