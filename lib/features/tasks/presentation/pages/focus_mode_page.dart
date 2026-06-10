import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
import 'package:qdone/core/widgets/liquid_background.dart';
import 'package:qdone/core/widgets/neon_controls.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:qdone/features/tasks/presentation/utils/task_haptics.dart';
import 'package:qdone/features/tasks/presentation/utils/task_visual_tokens.dart';

class FocusModePage extends ConsumerWidget {
  const FocusModePage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskByIdProvider(taskId));
    return LiquidBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: taskState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('$error')),
            data: (task) => task == null
                ? const Center(child: Text('Задача не найдена'))
                : _FocusContent(task: task),
          ),
        ),
      ),
    );
  }
}

class _FocusContent extends ConsumerWidget {
  const _FocusContent({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = TaskVisualTokens.statusOf(task);
    final accent = TaskVisualTokens.colorForStatusIn(context, status);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
          sliver: SliverList.list(
            children: <Widget>[
              _FocusHeader(onClose: () => _closeFocus(context)),
              const SizedBox(height: 22),
              _TaskStory(task: task, status: status, accent: accent),
              const SizedBox(height: 14),
              _TaskDetails(task: task, status: status, accent: accent),
              const SizedBox(height: 18),
              _FocusActions(task: task, status: status),
            ],
          ),
        ),
      ],
    );
  }

  void _closeFocus(BuildContext context) {
    context.go('/tasks');
  }
}

class _FocusHeader extends StatelessWidget {
  const _FocusHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        NeonIconButton(
          onPressed: onClose,
          tooltip: 'Закрыть',
          icon: const Icon(Icons.close_rounded),
          style: NeonControlStyle.danger,
        ),
        const Spacer(),
        Text(
          'Режим фокуса',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primaryFor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TaskStory extends StatelessWidget {
  const _TaskStory({
    required this.task,
    required this.status,
    required this.accent,
  });

  final Task task;
  final TaskStatus status;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final statusIcon =
        TaskVisualTokens.statusIcon(status) ?? Icons.radio_button_unchecked;
    return GlassPanel(
      borderRadius: 30,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accent.withValues(alpha: 0.32)),
                ),
                child: Icon(statusIcon, color: accent, size: 25),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: accent.withValues(alpha: 0.24)),
                ),
                child: Text(
                  status.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            task.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          if (task.description?.trim().isNotEmpty ?? false) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              task.description!.trim(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.subdued(context),
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskDetails extends StatelessWidget {
  const _TaskDetails({
    required this.task,
    required this.status,
    required this.accent,
  });

  final Task task;
  final TaskStatus status;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final details = <_DetailData>[
      _DetailData(
        icon: Icons.schedule_rounded,
        label: 'Срок',
        value: _dateTimeLabel(task.dueDateTime),
        color: accent,
      ),
      _DetailData(
        icon: Icons.circle_rounded,
        label: 'Состояние',
        value: status.label,
        color: accent,
      ),
      _DetailData(
        icon: Icons.category_rounded,
        label: 'Категория',
        value: task.category.name,
        color: Color(task.category.colorValue),
      ),
      _DetailData(
        icon: Icons.flag_rounded,
        label: 'Приоритет',
        value: task.priority.label,
        color: TaskVisualTokens.priorityColorIn(context, task.priority),
      ),
      _DetailData(
        icon: Icons.battery_charging_full_rounded,
        label: 'Энергия',
        value: task.energyLevel.label,
        color: TaskVisualTokens.energyColorIn(context, task.energyLevel),
      ),
      _DetailData(
        icon: Icons.repeat_rounded,
        label: 'Повтор',
        value: task.recurrenceRule.summary,
        color: AppColors.secondaryFor(context),
      ),
      _DetailData(
        icon: task.reminders.any((reminder) => reminder.isEnabled)
            ? Icons.notifications_active_rounded
            : Icons.notifications_off_rounded,
        label: 'Напоминания',
        value: _reminderSummary(task),
        color: AppColors.primaryFor(context),
      ),
      _DetailData(
        icon: Icons.add_task_rounded,
        label: 'Создана',
        value: _dateTimeLabel(task.createdAt),
        color: AppColors.primaryFor(context),
      ),
      if (task.completedAt != null)
        _DetailData(
          icon: Icons.task_alt_rounded,
          label: 'Завершена',
          value: _dateTimeLabel(task.completedAt!),
          color: AppColors.successFor(context),
        ),
    ];

    return GlassPanel(
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Подробности',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 280;
              final tileWidth = twoColumns
                  ? (constraints.maxWidth - 9) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 9,
                runSpacing: 9,
                children: details
                    .map(
                      (detail) => SizedBox(
                        width: tileWidth,
                        child: _DetailTile(detail),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailData {
  const _DetailData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _DetailTile extends StatelessWidget {
  const _DetailTile(this.detail);

  final _DetailData detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: detail.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: detail.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(detail.icon, size: 18, color: detail.color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  detail.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.subdued(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail.value,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
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

class _FocusActions extends ConsumerWidget {
  const _FocusActions({required this.task, required this.status});

  final Task task;
  final TaskStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finished =
        status == TaskStatus.completed || status == TaskStatus.archived;
    if (finished) {
      return NeonActionButton(
        onPressed: () async {
          await TaskHaptics.tap();
          await ref.read(tasksControllerProvider.notifier).restore(task);
          if (context.mounted) {
            context.go('/tasks');
          }
        },
        icon: const Icon(Icons.restore_rounded),
        style: NeonControlStyle.primary,
        fullWidth: true,
        label: Text(
          status == TaskStatus.archived
              ? 'Вернуть из архива'
              : 'Вернуть в активные',
        ),
      );
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: NeonActionButton(
                onPressed: () async {
                  await TaskHaptics.tap();
                  await ref
                      .read(tasksControllerProvider.notifier)
                      .complete(task);
                  if (context.mounted) {
                    context.go('/tasks');
                  }
                },
                icon: const Icon(Icons.done_rounded),
                style: NeonControlStyle.primary,
                fullWidth: true,
                label: const Text('Готово'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NeonActionButton(
                onPressed: () async {
                  await TaskHaptics.tap();
                  await ref
                      .read(tasksControllerProvider.notifier)
                      .snooze(task, const Duration(minutes: 15));
                },
                icon: const Icon(Icons.snooze_rounded),
                fullWidth: true,
                label: const Text('15 мин.'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        NeonActionButton(
          onPressed: () async {
            await TaskHaptics.tap();
            await ref
                .read(tasksControllerProvider.notifier)
                .snooze(task, const Duration(days: 1));
          },
          icon: const Icon(Icons.wb_sunny_rounded),
          style: NeonControlStyle.quiet,
          fullWidth: true,
          label: const Text('Завтра утром'),
        ),
      ],
    );
  }
}

String _reminderSummary(Task task) {
  final reminders =
      task.reminders.where((reminder) => reminder.isEnabled).toList()
        ..sort((left, right) => left.dateTime.compareTo(right.dateTime));
  if (reminders.isEmpty) {
    return 'Выключены';
  }
  if (reminders.length == 1) {
    return _dateTimeLabel(reminders.single.dateTime);
  }
  return '${reminders.length}, ближайшее ${_dateTimeLabel(reminders.first.dateTime)}';
}

String _dateTimeLabel(DateTime dateTime) {
  return '${_twoDigits(dateTime.day)}.${_twoDigits(dateTime.month)}.'
      '${dateTime.year} · ${_twoDigits(dateTime.hour)}:'
      '${_twoDigits(dateTime.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
