import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdone/core/localization/qdone_localizations.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
import 'package:qdone/core/widgets/neon_controls.dart';
import 'package:qdone/core/widgets/qdone_brand_text.dart';
import 'package:qdone/core/widgets/qdone_tap_feedback.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/repositories/task_repository.dart';
import 'package:qdone/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:qdone/features/tasks/presentation/widgets/daily_pulse_card.dart';
import 'package:qdone/features/tasks/presentation/widgets/task_form_modal.dart';
import 'package:qdone/features/tasks/presentation/widgets/task_section.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksControllerProvider);
    final strings = QDoneLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: tasksState.when(
        loading: () => const _TasksLoadingState(),
        error: (error, stackTrace) => _ErrorState(
          error: error,
          onRetry: () => ref.read(tasksControllerProvider.notifier).load(),
        ),
        data: (feed) {
          final controller = ref.read(tasksControllerProvider.notifier);
          return RefreshIndicator(
            onRefresh: controller.load,
            child: CustomScrollView(
              key: const PageStorageKey<String>('tasks-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 112),
                  sliver: SliverMainAxisGroup(
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: _Header(
                          onAdd: () => TaskFormModal.show(context, ref),
                        ),
                      ),
                      _gap(16),
                      SliverToBoxAdapter(
                        child: DailyPulseCard(summary: feed.dailySummary),
                      ),
                      _gap(14),
                      _section(
                        context,
                        ref,
                        kind: TaskSectionKind.overdue,
                        feed: feed,
                        title: strings.text('overdue'),
                        icon: Icons.warning_amber_rounded,
                        accent: AppColors.warning,
                        initiallyExpanded: true,
                        snoozeDuration: const Duration(minutes: 15),
                      ),
                      _gap(14),
                      _section(
                        context,
                        ref,
                        kind: TaskSectionKind.current,
                        feed: feed,
                        title: strings.text('current'),
                        icon: Icons.bolt_rounded,
                        accent: AppColors.turquoise,
                        initiallyExpanded: true,
                        snoozeDuration: const Duration(hours: 1),
                      ),
                      _gap(14),
                      _section(
                        context,
                        ref,
                        kind: TaskSectionKind.future,
                        feed: feed,
                        title: strings.text('future'),
                        icon: Icons.next_plan_rounded,
                        accent: AppColors.cyan,
                        initiallyExpanded: false,
                        snoozeDuration: const Duration(hours: 1),
                      ),
                      _gap(14),
                      _section(
                        context,
                        ref,
                        kind: TaskSectionKind.completed,
                        feed: feed,
                        title: strings.text('completed'),
                        icon: Icons.inventory_2_rounded,
                        accent: AppColors.muted,
                        initiallyExpanded: false,
                        snoozeDuration: const Duration(hours: 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section(
    BuildContext context,
    WidgetRef ref, {
    required TaskSectionKind kind,
    required TasksFeedState feed,
    required String title,
    required IconData icon,
    required Color accent,
    required bool initiallyExpanded,
    required Duration snoozeDuration,
  }) {
    final section = feed.section(kind);
    final controller = ref.read(tasksControllerProvider.notifier);
    final completed = kind == TaskSectionKind.completed;
    return TaskSection(
      key: ValueKey<TaskSectionKind>(kind),
      title: title,
      tasks: section.tasks,
      totalCount: section.totalCount,
      icon: icon,
      accent: accent,
      initiallyExpanded: initiallyExpanded,
      hasMore: section.hasMore,
      isLoadingMore: section.isLoadingMore,
      onLoadMore: () => controller.loadMore(kind),
      onDone: completed ? controller.restore : controller.complete,
      onRestore: controller.restore,
      onDelete: completed ? controller.delete : controller.archive,
      onSnooze: (task) => controller.snooze(task, snoozeDuration),
      onReschedule: (task) => _rescheduleTask(context, ref, task: task),
      onEdit: (task) => TaskFormModal.show(context, ref, task: task),
    );
  }
}

SliverToBoxAdapter _gap(double height) {
  return SliverToBoxAdapter(child: SizedBox(height: height));
}

class _Header extends StatelessWidget {
  const _Header({this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: QDoneBrandText(fontSize: 28, letterSpacing: 4.8)),
        NeonActionButton(
          onPressed: onAdd,
          label: const Text('+', style: TextStyle(fontSize: 22, height: 1)),
          height: 48,
          attentionGlow: true,
        ),
      ],
    );
  }
}

class _TasksLoadingState extends StatelessWidget {
  const _TasksLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 112),
      children: <Widget>[
        const _Header(),
        const SizedBox(height: 16),
        GlassPanel(
          borderRadius: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 72,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Готовим задачи',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Загружаем только ближайшие страницы списка.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.subdued(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.warning,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            QDoneMaterialTapFeedback(
              onTap: onRetry,
              semanticLabel: 'Повторить',
              child: FilledButton(
                onPressed: () {},
                child: const Text('Повторить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _rescheduleTask(
  BuildContext context,
  WidgetRef ref, {
  required Task task,
}) async {
  final date = await showDatePicker(
    context: context,
    useRootNavigator: true,
    initialDate: task.dueDate,
    firstDate: DateTime.now().subtract(const Duration(days: 365)),
    lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
  );
  if (date == null || !context.mounted) {
    return;
  }
  final time = await showTimePicker(
    context: context,
    useRootNavigator: true,
    initialTime: task.dueTime,
  );
  if (time == null || !context.mounted) {
    return;
  }
  await ref
      .read(tasksControllerProvider.notifier)
      .reschedule(
        task,
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      );
}
