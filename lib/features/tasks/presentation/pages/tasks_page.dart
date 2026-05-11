import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdone/core/localization/qdone_localizations.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(
          error: error,
          onRetry: () => ref.read(tasksControllerProvider.notifier).load(),
        ),
        data: (tasks) {
          final grouped = _GroupedTasks.from(tasks);
          return RefreshIndicator(
            onRefresh: () => ref.read(tasksControllerProvider.notifier).load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 112),
              children: <Widget>[
                const _Header(),
                const SizedBox(height: 16),
                DailyPulseCard(tasks: tasks),
                const SizedBox(height: 14),
                TaskSection(
                  title: strings.text('overdue'),
                  tasks: grouped.overdue,
                  icon: Icons.warning_amber_rounded,
                  accent: AppColors.warning,
                  initiallyExpanded: grouped.overdue.isNotEmpty,
                  onDone: (task) =>
                      ref.read(tasksControllerProvider.notifier).complete(task),
                  onRestore: (task) =>
                      ref.read(tasksControllerProvider.notifier).restore(task),
                  onDelete: (task) =>
                      ref.read(tasksControllerProvider.notifier).archive(task),
                  onSnooze: (task) => ref
                      .read(tasksControllerProvider.notifier)
                      .snooze(task, const Duration(minutes: 15)),
                  onReschedule: (task) =>
                      _rescheduleTask(context, ref, task: task),
                  onEdit: (task) =>
                      TaskFormModal.show(context, ref, task: task),
                ),
                const SizedBox(height: 14),
                TaskSection(
                  title: strings.text('current'),
                  tasks: grouped.current,
                  icon: Icons.bolt_rounded,
                  accent: AppColors.turquoise,
                  initiallyExpanded: true,
                  onDone: (task) =>
                      ref.read(tasksControllerProvider.notifier).complete(task),
                  onRestore: (task) =>
                      ref.read(tasksControllerProvider.notifier).restore(task),
                  onDelete: (task) =>
                      ref.read(tasksControllerProvider.notifier).archive(task),
                  onSnooze: (task) => ref
                      .read(tasksControllerProvider.notifier)
                      .snooze(task, const Duration(hours: 1)),
                  onReschedule: (task) =>
                      _rescheduleTask(context, ref, task: task),
                  onEdit: (task) =>
                      TaskFormModal.show(context, ref, task: task),
                ),
                const SizedBox(height: 14),
                TaskSection(
                  title: strings.text('future'),
                  tasks: grouped.future,
                  icon: Icons.next_plan_rounded,
                  accent: AppColors.cyan,
                  initiallyExpanded: false,
                  onDone: (task) =>
                      ref.read(tasksControllerProvider.notifier).complete(task),
                  onRestore: (task) =>
                      ref.read(tasksControllerProvider.notifier).restore(task),
                  onDelete: (task) =>
                      ref.read(tasksControllerProvider.notifier).archive(task),
                  onSnooze: (task) => ref
                      .read(tasksControllerProvider.notifier)
                      .snooze(task, const Duration(hours: 1)),
                  onReschedule: (task) =>
                      _rescheduleTask(context, ref, task: task),
                  onEdit: (task) =>
                      TaskFormModal.show(context, ref, task: task),
                ),
                const SizedBox(height: 14),
                TaskSection(
                  title: strings.text('completed'),
                  tasks: grouped.completed,
                  icon: Icons.inventory_2_rounded,
                  accent: AppColors.muted,
                  initiallyExpanded: false,
                  onDone: (task) =>
                      ref.read(tasksControllerProvider.notifier).restore(task),
                  onRestore: (task) =>
                      ref.read(tasksControllerProvider.notifier).restore(task),
                  onDelete: (task) =>
                      ref.read(tasksControllerProvider.notifier).delete(task),
                  onSnooze: (task) => ref
                      .read(tasksControllerProvider.notifier)
                      .snooze(task, const Duration(hours: 1)),
                  onReschedule: (task) =>
                      _rescheduleTask(context, ref, task: task),
                  onEdit: (task) =>
                      TaskFormModal.show(context, ref, task: task),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'QDone',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Image.asset('assets/images/qdone_logo.png'),
          ),
        ),
      ],
    );
  }
}

class _GroupedTasks {
  const _GroupedTasks({
    required this.overdue,
    required this.current,
    required this.future,
    required this.completed,
  });

  final List<Task> overdue;
  final List<Task> current;
  final List<Task> future;
  final List<Task> completed;

  factory _GroupedTasks.from(List<Task> tasks) {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return _GroupedTasks(
      overdue: tasks
          .where((task) => task.status == TaskStatus.overdue)
          .toList(),
      current: tasks
          .where(
            (task) =>
                !task.isCompleted &&
                task.status != TaskStatus.overdue &&
                !task.dueDateTime.isAfter(todayEnd),
          )
          .toList(),
      future: tasks
          .where(
            (task) => !task.isCompleted && task.dueDateTime.isAfter(todayEnd),
          )
          .toList(),
      completed: tasks.where((task) => task.isCompleted).toList(),
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
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
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
