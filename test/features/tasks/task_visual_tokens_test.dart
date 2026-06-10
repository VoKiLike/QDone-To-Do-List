import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/presentation/utils/task_visual_tokens.dart';

void main() {
  test('resolves active, overdue, completed and archived visuals', () {
    final now = DateTime(2026, 6, 10, 12);

    expect(
      TaskVisualTokens.statusOf(_task(DateTime(2026, 6, 11)), now),
      TaskStatus.active,
    );
    expect(
      TaskVisualTokens.statusOf(_task(DateTime(2026, 6, 9)), now),
      TaskStatus.overdue,
    );
    expect(
      TaskVisualTokens.statusOf(
        _task(DateTime(2026, 6, 9), status: TaskStatus.completed),
        now,
      ),
      TaskStatus.completed,
    );
    expect(
      TaskVisualTokens.statusOf(
        _task(
          DateTime(2026, 6, 9),
          status: TaskStatus.archived,
          isArchived: true,
        ),
        now,
      ),
      TaskStatus.archived,
    );

    expect(TaskVisualTokens.statusIcon(TaskStatus.active), isNull);
    expect(
      TaskVisualTokens.statusIcon(TaskStatus.completed),
      Icons.check_rounded,
    );
    expect(
      TaskVisualTokens.statusIcon(TaskStatus.archived),
      Icons.unarchive_rounded,
    );
  });

  test('uses dedicated semantic colors in light theme', () {
    expect(
      TaskVisualTokens.colorForStatus(
        TaskStatus.active,
        brightness: Brightness.light,
      ),
      AppColors.lightBlue,
    );
    expect(
      TaskVisualTokens.colorForStatus(
        TaskStatus.overdue,
        brightness: Brightness.light,
      ),
      AppColors.lightWarning,
    );
    expect(
      TaskVisualTokens.colorForStatus(
        TaskStatus.completed,
        brightness: Brightness.light,
      ),
      AppColors.lightSuccess,
    );
    expect(
      TaskVisualTokens.colorForStatus(
        TaskStatus.archived,
        brightness: Brightness.light,
      ),
      AppColors.lightViolet,
    );
  });
}

Task _task(
  DateTime dueDate, {
  TaskStatus status = TaskStatus.active,
  bool isArchived = false,
}) {
  return Task(
    id: 'task-${status.name}',
    title: status.label,
    createdAt: DateTime(2026, 6, 1),
    dueDate: dueDate,
    dueTime: const TimeOfDay(hour: 9, minute: 0),
    status: status,
    isArchived: isArchived,
    category: const TaskCategory(
      id: 'personal',
      name: 'Личное',
      colorValue: 0xFF8B5CF6,
    ),
  );
}
