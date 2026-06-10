import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
import 'package:qdone/core/widgets/qdone_tap_feedback.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/presentation/utils/task_haptics.dart';
import 'package:qdone/features/tasks/presentation/utils/task_visual_tokens.dart';

class TaskCard extends StatefulWidget {
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
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _expanded = false;

  Task get task => widget.task;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = TaskVisualTokens.statusOf(task, now);
    final accent = TaskVisualTokens.colorForStatusIn(context, status);
    final muted =
        status == TaskStatus.completed || status == TaskStatus.archived;

    return GlassPanel(
      borderRadius: 20,
      opacity: muted ? 0.055 : 0.085,
      blurSigma: 0,
      shadowBlurRadius: 0,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 7, 6, 7),
            child: Row(
              children: <Widget>[
                _StatusControl(
                  status: status,
                  accent: accent,
                  onDone: widget.onDone,
                  onRestore: widget.onRestore,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _CompactTaskSummary(
                    task: task,
                    status: status,
                    accent: accent,
                    muted: muted,
                    now: now,
                  ),
                ),
                _CompactIconButton(
                  tooltip: _expanded ? 'Свернуть задачу' : 'Развернуть задачу',
                  semanticLabel: _expanded
                      ? 'Свернуть подробности задачи'
                      : 'Развернуть подробности задачи',
                  icon: Icons.keyboard_arrow_down_rounded,
                  color: accent,
                  turns: _expanded ? 0.5 : 0,
                  onTap: _toggleExpanded,
                ),
                _CompactIconButton(
                  tooltip: 'Режим фокуса',
                  semanticLabel: 'Открыть режим фокуса',
                  icon: Icons.center_focus_strong_rounded,
                  color: AppColors.secondaryFor(context),
                  onTap: () async {
                    await TaskHaptics.tap();
                    if (context.mounted) {
                      context.push('/focus/${task.id}');
                    }
                  },
                ),
              ],
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? _ExpandedTaskDetails(
                      task: task,
                      status: status,
                      accent: accent,
                      onEdit: widget.onEdit,
                      onSnooze: widget.onSnooze,
                      onReschedule: widget.onReschedule,
                      onDelete: widget.onDelete,
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleExpanded() {
    TaskHaptics.tap();
    setState(() => _expanded = !_expanded);
  }
}

class _CompactTaskSummary extends StatelessWidget {
  const _CompactTaskSummary({
    required this.task,
    required this.status,
    required this.accent,
    required this.muted,
    required this.now,
  });

  final Task task;
  final TaskStatus status;
  final Color accent;
  final bool muted;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final categoryColor = Color(task.category.colorValue);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            decoration: muted ? TextDecoration.lineThrough : null,
            color: muted
                ? AppColors.subdued(context)
                : AppColors.foreground(context),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: <Widget>[
            Icon(Icons.schedule_rounded, size: 13, color: accent),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _compactDateLabel(task, now),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: status == TaskStatus.overdue
                      ? accent
                      : AppColors.subdued(context),
                  fontWeight: status == TaskStatus.overdue
                      ? FontWeight.w700
                      : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.subdued(context).withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  task.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExpandedTaskDetails extends StatelessWidget {
  const _ExpandedTaskDetails({
    required this.task,
    required this.status,
    required this.accent,
    required this.onEdit,
    required this.onSnooze,
    required this.onReschedule,
    required this.onDelete,
  });

  final Task task;
  final TaskStatus status;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onSnooze;
  final VoidCallback onReschedule;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.line(context).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (task.description?.trim().isNotEmpty ?? false) ...<Widget>[
              Text(
                task.description!.trim(),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.subdued(context),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: <Widget>[
                _DetailChip(
                  icon: Icons.schedule_rounded,
                  label: _fullDateLabel(task),
                  color: accent,
                ),
                _DetailChip(
                  icon: Icons.circle_rounded,
                  label: status.label,
                  color: accent,
                ),
                _DetailChip(
                  icon: Icons.flag_rounded,
                  label: task.priority.label,
                  color: TaskVisualTokens.priorityColorIn(
                    context,
                    task.priority,
                  ),
                ),
                _DetailChip(
                  icon: Icons.category_rounded,
                  label: task.category.name,
                  color: Color(task.category.colorValue),
                ),
                _DetailChip(
                  icon: Icons.battery_charging_full_rounded,
                  label: task.energyLevel.label,
                  color: TaskVisualTokens.energyColorIn(
                    context,
                    task.energyLevel,
                  ),
                ),
                _DetailChip(
                  icon: Icons.repeat_rounded,
                  label: task.recurrenceRule.summary,
                  color: AppColors.secondaryFor(context),
                ),
                _DetailChip(
                  icon: task.reminders.isEmpty
                      ? Icons.notifications_off_rounded
                      : Icons.notifications_active_rounded,
                  label: _reminderLabel(task),
                  color: AppColors.primaryFor(context),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: <Widget>[
                _ActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Изменить',
                  color: AppColors.primaryFor(context),
                  onTap: onEdit,
                ),
                _ActionButton(
                  icon: Icons.snooze_rounded,
                  label: 'Отложить',
                  color: AppColors.successFor(context),
                  onTap: onSnooze,
                ),
                _ActionButton(
                  icon: Icons.event_repeat_rounded,
                  label: 'Перенести',
                  color: AppColors.secondaryFor(context),
                  onTap: onReschedule,
                ),
                _ActionButton(
                  icon: task.isCompleted
                      ? Icons.delete_outline_rounded
                      : Icons.archive_outlined,
                  label: task.isCompleted ? 'Удалить' : 'В архив',
                  color: task.isCompleted
                      ? AppColors.warningFor(context)
                      : AppColors.subdued(context),
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusControl extends StatelessWidget {
  const _StatusControl({
    required this.status,
    required this.accent,
    required this.onDone,
    required this.onRestore,
  });

  final TaskStatus status;
  final Color accent;
  final VoidCallback onDone;
  final VoidCallback onRestore;

  void _handleTap() {
    TaskHaptics.tap();
    if (status == TaskStatus.completed || status == TaskStatus.archived) {
      onRestore();
    } else {
      onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = TaskVisualTokens.statusIcon(status);
    final selected =
        status == TaskStatus.completed || status == TaskStatus.archived;
    final semanticLabel = switch (status) {
      TaskStatus.completed => 'Вернуть выполненную задачу',
      TaskStatus.archived => 'Вернуть задачу из архива',
      TaskStatus.overdue => 'Отметить просроченную задачу выполненной',
      TaskStatus.active => 'Отметить задачу выполненной',
    };
    return Semantics(
      button: true,
      checked: status == TaskStatus.completed,
      label: semanticLabel,
      child: QDoneTapFeedback(
        onTap: _handleTap,
        customBorder: const CircleBorder(),
        builder: (context, tapped) {
          return SizedBox.square(
            dimension: 44,
            child: Center(
              child: AnimatedScale(
                scale: tapped ? 0.88 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  width: 24,
                  height: 24,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? accent.withValues(
                            alpha: status == TaskStatus.completed ? 0.92 : 0.2,
                          )
                        : tapped
                        ? accent.withValues(alpha: 0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: accent.withValues(alpha: tapped ? 1 : 0.76),
                      width: 1.25,
                    ),
                    boxShadow: tapped
                        ? <BoxShadow>[
                            BoxShadow(
                              color: accent.withValues(alpha: 0.34),
                              blurRadius: 12,
                            ),
                          ]
                        : const <BoxShadow>[],
                  ),
                  child: icon == null
                      ? null
                      : Icon(
                          icon,
                          size: status == TaskStatus.archived ? 13 : 15,
                          color: status == TaskStatus.completed
                              ? Colors.white
                              : accent,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompactIconButton extends StatelessWidget {
  const _CompactIconButton({
    required this.tooltip,
    required this.semanticLabel,
    required this.icon,
    required this.color,
    required this.onTap,
    this.turns = 0,
  });

  final String tooltip;
  final String semanticLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double turns;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: QDoneMaterialTapFeedback(
        onTap: onTap,
        semanticLabel: semanticLabel,
        borderRadius: BorderRadius.circular(14),
        flashColor: color.withValues(alpha: 0.2),
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: AnimatedRotation(
              turns: turns,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: Icon(icon, size: 20, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 96,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: label,
        child: QDoneMaterialTapFeedback(
          onTap: () async {
            await TaskHaptics.tap();
            onTap();
          },
          semanticLabel: label,
          borderRadius: BorderRadius.circular(14),
          flashColor: color.withValues(alpha: 0.18),
          child: SizedBox(
            height: 44,
            child: Icon(icon, size: 19, color: color),
          ),
        ),
      ),
    );
  }
}

String _reminderLabel(Task task) {
  final enabled = task.reminders.where((reminder) => reminder.isEnabled).length;
  if (enabled == 0) {
    return 'Без напоминаний';
  }
  if (task.recurrenceRule.isEnabled || enabled == 1) {
    return 'Напоминание включено';
  }
  return 'Напоминаний: $enabled';
}

String _compactDateLabel(Task task, DateTime now) {
  final due = task.dueDateTime;
  final today = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(due.year, due.month, due.day);
  final difference = dueDay.difference(today).inDays;
  final time = _timeLabel(due);
  return switch (difference) {
    0 => 'Сегодня, $time',
    1 => 'Завтра, $time',
    -1 => 'Вчера, $time',
    _ => '${_twoDigits(due.day)}.${_twoDigits(due.month)}, $time',
  };
}

String _fullDateLabel(Task task) {
  final due = task.dueDateTime;
  return '${_twoDigits(due.day)}.${_twoDigits(due.month)}.${due.year} · '
      '${_timeLabel(due)}';
}

String _timeLabel(DateTime dateTime) {
  return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
