import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
import 'package:qdone/features/tasks/domain/repositories/task_repository.dart';

class DailyPulseCard extends StatelessWidget {
  const DailyPulseCard({super.key, required this.summary});

  final TaskDailySummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final next = summary.nextTask;
    final nextLabel = next == null
        ? 'все спокойно'
        : 'следующее в ${next.dueTime.hour.toString().padLeft(2, '0')}:${next.dueTime.minute.toString().padLeft(2, '0')}';

    return GlassPanel(
      borderRadius: 30,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: AppColors.liquidGradientFor(context),
              borderRadius: BorderRadius.circular(22),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primaryFor(context).withValues(alpha: 0.24),
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
                  '${summary.completed} выполнено · '
                  '${summary.remaining} осталось · '
                  '${summary.overdue} просрочено · $nextLabel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  summary.remaining == 0
                      ? 'День закрыт. Можно выдохнуть.'
                      : 'Выберите следующее спокойное действие.',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primaryFor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
