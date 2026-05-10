import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';

class SmartTimeline extends StatelessWidget {
  const SmartTimeline({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayTasks =
        tasks
            .where((task) => _sameDay(task.dueDate, today) && !task.isCompleted)
            .toList()
          ..sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));

    return GlassPanel(
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.timeline_rounded, color: AppColors.cyan),
              const SizedBox(width: 8),
              Text(
                'Ритм дня',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final part in _DayPart.values)
            _TimelinePart(
              label: part.label,
              tasks: todayTasks.where(part.matches).toList(),
            ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TimelinePart extends StatelessWidget {
  const _TimelinePart({required this.label, required this.tasks});

  final String label;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.turquoise),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tasks
                  .map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${task.dueTime.format(context)} - ${task.title}',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

enum _DayPart {
  morning,
  afternoon,
  evening,
  night;

  String get label => switch (this) {
    _DayPart.morning => 'Утро',
    _DayPart.afternoon => 'День',
    _DayPart.evening => 'Вечер',
    _DayPart.night => 'Ночь',
  };

  bool matches(Task task) {
    final hour = task.dueTime.hour;
    return switch (this) {
      _DayPart.morning => hour >= 5 && hour < 12,
      _DayPart.afternoon => hour >= 12 && hour < 17,
      _DayPart.evening => hour >= 17 && hour < 22,
      _DayPart.night => hour >= 22 || hour < 5,
    };
  }
}
