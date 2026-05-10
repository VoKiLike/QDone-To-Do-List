import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';

class DailyPulseCard extends StatelessWidget {
  const DailyPulseCard({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayTasks = tasks
        .where((task) => _sameDay(task.dueDate, now))
        .toList();
    final done = todayTasks
        .where((task) => task.status == TaskStatus.completed)
        .length;
    final left = todayTasks.where((task) => !task.isCompleted).length;
    final overdue = tasks
        .where((task) => task.status == TaskStatus.overdue)
        .length;
    final next =
        tasks
            .where((task) => !task.isCompleted && task.dueDateTime.isAfter(now))
            .toList()
          ..sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
    final nextLabel = next.isEmpty
        ? 'все спокойно'
        : 'следующее в ${next.first.dueTime.hour.toString().padLeft(2, '0')}:${next.first.dueTime.minute.toString().padLeft(2, '0')}';

    return GlassPanel(
      borderRadius: 30,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: AppColors.liquidGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.28),
                  blurRadius: 22,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Пульс дня',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$done выполнено · $left осталось · $overdue просрочено · $nextLabel',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 5),
                Text(
                  left == 0
                      ? 'День закрыт. Можно выдохнуть.'
                      : 'Выберите следующее спокойное действие.',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.turquoise),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
