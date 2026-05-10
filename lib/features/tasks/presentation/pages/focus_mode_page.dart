import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_to_do_list_app/core/theme/app_colors.dart';
import 'package:flutter_to_do_list_app/core/widgets/glass_panel.dart';
import 'package:flutter_to_do_list_app/core/widgets/liquid_background.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task.dart';
import 'package:flutter_to_do_list_app/features/tasks/presentation/controllers/tasks_controller.dart';

class FocusModePage extends ConsumerWidget {
  const FocusModePage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref
        .watch(tasksControllerProvider)
        .valueOrNull
        ?.where((item) => item.id == taskId)
        .firstOrNull;
    return LiquidBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: task == null
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
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton.filledTonal(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
            const Spacer(),
            Text(
              'Режим фокуса',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.turquoise),
            ),
          ],
        ),
        const Spacer(),
        GlassPanel(
          borderRadius: 36,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  gradient: AppColors.liquidGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.violet.withValues(alpha: 0.35),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.center_focus_strong_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                task.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (task.description?.isNotEmpty ?? false) ...<Widget>[
                const SizedBox(height: 10),
                Text(task.description!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  Chip(
                    label: Text(
                      '${task.dueTime.format(context)} - ${task.category.name}',
                    ),
                  ),
                  Chip(label: Text(task.energyLevel.label)),
                  Chip(label: Text(task.recurrenceRule.summary)),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(tasksControllerProvider.notifier)
                      .complete(task);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.done_rounded),
                label: const Text('Готово'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => ref
                    .read(tasksControllerProvider.notifier)
                    .snooze(task, const Duration(minutes: 15)),
                icon: const Icon(Icons.snooze_rounded),
                label: const Text('15 мин.'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => ref
                .read(tasksControllerProvider.notifier)
                .snooze(task, const Duration(days: 1)),
            icon: const Icon(Icons.wb_sunny_rounded),
            label: const Text('Завтра утром'),
          ),
        ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
