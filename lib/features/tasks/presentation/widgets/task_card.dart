import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/presentation/utils/task_haptics.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onDone,
    required this.onRestore,
    required this.onDelete,
    required this.onSnooze,
    required this.onReschedule,
    required this.onEdit,
  });

  final Task task;
  final VoidCallback onDone;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  final VoidCallback onSnooze;
  final VoidCallback onReschedule;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(task.status);
    final muted = task.isCompleted;
    final isDistant = task.dueDateTime.isAfter(
      DateTime.now().add(const Duration(days: 1)),
    );
    final panelOpacity = muted ? 0.07 : isDistant ? 0.08 : 0.13;
    final accentShadowAlpha = muted ? 0.02 : 0.08;
    return GlassPanel(
      borderRadius: 24,
      opacity: panelOpacity,
      blurSigma: 0,
      shadowBlurRadius: 0,
      padding: const EdgeInsets.all(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: accentShadowAlpha),
              blurRadius: muted ? 4 : 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _StatusControl(
                    task: task,
                    accent: accent,
                    onDone: onDone,
                    onRestore: onRestore,
                  ),
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
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Режим фокуса',
                    onPressed: () async {
                      await TaskHaptics.tap();
                      if (context.mounted) {
                        context.push('/focus/${task.id}');
                      }
                    },
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
                    label: _reminderLabel(task),
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
                    onTap: onReschedule,
                  ),
                  _ActionButton(
                    icon: task.isCompleted
                        ? Icons.delete_outline_rounded
                        : Icons.archive_outlined,
                    label: task.isCompleted ? 'Удалить' : 'В архив',
                    onTap: onDelete,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _accentFor(TaskStatus status) {
    return switch (status) {
      TaskStatus.overdue => AppColors.warning,
      TaskStatus.completed => AppColors.success,
      TaskStatus.archived => AppColors.neonPurple,
      TaskStatus.active => AppColors.turquoise,
    };
  }
}

class _StatusControl extends StatefulWidget {
  const _StatusControl({
    required this.task,
    required this.accent,
    required this.onDone,
    required this.onRestore,
  });

  final Task task;
  final Color accent;
  final VoidCallback onDone;
  final VoidCallback onRestore;

  @override
  State<_StatusControl> createState() => _StatusControlState();
}

class _StatusControlState extends State<_StatusControl> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) {
      return;
    }
    setState(() => _pressed = value);
  }

  void _handleTap() {
    TaskHaptics.tap();
    _setPressed(true);
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      _setPressed(false);
    });
    if (widget.task.isCompleted) {
      widget.onRestore();
    } else {
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.task.isCompleted;
    final archived =
        widget.task.status == TaskStatus.archived || widget.task.isArchived;
    final icon = switch (widget.task.status) {
      TaskStatus.completed => Icons.task_alt_rounded,
      TaskStatus.archived => Icons.unarchive_rounded,
      TaskStatus.overdue => Icons.priority_high_rounded,
      TaskStatus.active => Icons.done_rounded,
    };
    return Semantics(
      button: true,
      checked: completed,
      label: completed
          ? archived
                ? 'Вернуть из архива'
                : 'Вернуть в активные'
          : 'Отметить выполненной',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _handleTap,
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          borderRadius: BorderRadius.circular(22),
          splashColor: widget.accent.withValues(alpha: 0.34),
          highlightColor: widget.accent.withValues(alpha: 0.22),
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              width: 44,
              height: 44,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pressed
                    ? widget.accent.withValues(alpha: 0.34)
                    : completed
                    ? widget.accent.withValues(alpha: 0.24)
                    : widget.accent.withValues(alpha: 0.12),
                border: Border.all(
                  color: widget.accent.withValues(alpha: _pressed ? 1 : 0.8),
                  width: _pressed ? 2.2 : 1.5,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: widget.accent.withValues(
                      alpha: _pressed ? 0.42 : 0.16,
                    ),
                    blurRadius: _pressed ? 20 : 10,
                    spreadRadius: _pressed ? 2 : 0,
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  icon,
                  key: ValueKey<IconData>(icon),
                  color: widget.accent,
                ),
              ),
            ),
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
    Future<void> handlePressed() async {
      await TaskHaptics.tap();
      onTap();
    }

    return Expanded(
      child: IconButton(
        tooltip: label,
        onPressed: handlePressed,
        icon: Icon(icon, size: 20),
      ),
    );
  }
}

String _reminderLabel(Task task) {
  if (task.reminders.isEmpty) {
    return 'Без напоминаний';
  }
  if (task.recurrenceRule.isEnabled || task.reminders.length == 1) {
    return 'Напоминание включено';
  }
  return 'Напоминаний: ${task.reminders.length}';
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
