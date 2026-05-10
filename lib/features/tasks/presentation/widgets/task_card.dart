import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_to_do_list_app/core/theme/app_colors.dart';
import 'package:flutter_to_do_list_app/core/widgets/glass_panel.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task_enums.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onDone,
    required this.onDelete,
    required this.onSnooze,
    required this.onEdit,
  });

  final Task task;
  final VoidCallback onDone;
  final VoidCallback onDelete;
  final VoidCallback onSnooze;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(task.status);
    final muted =
        task.status == TaskStatus.completed ||
        task.status == TaskStatus.archived;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: muted ? 0.68 : 1,
      child: GlassPanel(
        borderRadius: 24,
        opacity:
            task.dueDateTime.isAfter(
              DateTime.now().add(const Duration(days: 1)),
            )
            ? 0.08
            : 0.13,
        padding: const EdgeInsets.all(14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accent.withValues(alpha: muted ? 0.06 : 0.18),
                blurRadius: 22,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _StatusControl(task: task, accent: accent, onDone: onDone),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                decoration: muted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),
                        if (task.description?.isNotEmpty ?? false) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Режим фокуса',
                    onPressed: () => context.push('/focus/${task.id}'),
                    icon: const Icon(Icons.center_focus_strong_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _Chip(
                    icon: Icons.schedule_rounded,
                    label: _dateLabel(task),
                    color: accent,
                  ),
                  _Chip(
                    icon: Icons.flag_rounded,
                    label: task.priority.label,
                    color: _priorityColor(task.priority),
                  ),
                  _Chip(
                    icon: Icons.category_rounded,
                    label: task.category.name,
                    color: Color(task.category.colorValue),
                  ),
                  _Chip(
                    icon: Icons.battery_charging_full_rounded,
                    label: task.energyLevel.label,
                    color: _energyColor(task.energyLevel),
                  ),
                  _Chip(
                    icon: Icons.repeat_rounded,
                    label: task.recurrenceRule.summary,
                    color: AppColors.neonPurple,
                  ),
                  _Chip(
                    icon: task.reminders.isEmpty
                        ? Icons.notifications_off_rounded
                        : Icons.notifications_active_rounded,
                    label: task.reminders.isEmpty
                        ? 'Без напоминаний'
                        : 'Напоминаний: ${task.reminders.length}',
                    color: AppColors.cyan,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    label: 'Изменить',
                    onTap: onEdit,
                  ),
                  _ActionButton(
                    icon: Icons.snooze_rounded,
                    label: 'Отложить',
                    onTap: onSnooze,
                  ),
                  _ActionButton(
                    icon: Icons.event_repeat_rounded,
                    label: 'Перенести',
                    onTap: onEdit,
                  ),
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Удалить',
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _accentFor(TaskStatus status) {
    return switch (status) {
      TaskStatus.overdue => AppColors.warning,
      TaskStatus.completed || TaskStatus.archived => AppColors.muted,
      TaskStatus.active => AppColors.turquoise,
    };
  }
}

class _StatusControl extends StatelessWidget {
  const _StatusControl({
    required this.task,
    required this.accent,
    required this.onDone,
  });

  final Task task;
  final Color accent;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final completed = task.isCompleted;
    return Semantics(
      button: true,
      checked: completed,
      label: completed ? 'Выполнено' : 'Отметить выполненной',
      child: InkWell(
        onTap: completed ? null : onDone,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          width: 44,
          height: 44,
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed
                ? accent.withValues(alpha: 0.24)
                : accent.withValues(alpha: 0.12),
            border: Border.all(
              color: accent.withValues(alpha: 0.8),
              width: 1.5,
            ),
          ),
          child: Icon(
            completed ? Icons.done_all_rounded : Icons.done_rounded,
            color: accent,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: IconButton(
        tooltip: label,
        onPressed: onTap,
        icon: Icon(icon, size: 20),
      ),
    );
  }
}

String _dateLabel(Task task) {
  final date = task.dueDateTime;
  final hh = task.dueTime.hour.toString().padLeft(2, '0');
  final mm = task.dueTime.minute.toString().padLeft(2, '0');
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')} $hh:$mm';
}

Color _priorityColor(TaskPriority priority) {
  return switch (priority) {
    TaskPriority.low => AppColors.turquoise,
    TaskPriority.medium => AppColors.cyan,
    TaskPriority.high => AppColors.warning,
  };
}

Color _energyColor(EnergyLevel energy) {
  return switch (energy) {
    EnergyLevel.low => AppColors.softBlueGreen,
    EnergyLevel.medium => AppColors.violet,
    EnergyLevel.high => AppColors.neonPurple,
  };
}
