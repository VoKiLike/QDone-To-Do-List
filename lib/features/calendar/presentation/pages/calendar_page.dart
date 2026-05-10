import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_to_do_list_app/core/localization/qdone_localizations.dart';
import 'package:flutter_to_do_list_app/core/theme/app_colors.dart';
import 'package:flutter_to_do_list_app/core/widgets/glass_panel.dart';
import 'package:flutter_to_do_list_app/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task_enums.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/services/recurrence_service.dart';
import 'package:flutter_to_do_list_app/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:flutter_to_do_list_app/features/tasks/presentation/widgets/task_form_sheet.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedCalendarDayProvider);
    final tasks =
        ref.watch(tasksControllerProvider).valueOrNull ?? const <Task>[];
    final selectedTasks = _tasksForDay(tasks, selectedDay)
      ..sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(context, ref, selectedDay: selectedDay),
        backgroundColor: AppColors.violet,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Задача'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 112),
        children: <Widget>[
          _CalendarHeader(
            onToday: () {
              final now = DateTime.now();
              ref.read(selectedCalendarDayProvider.notifier).state = DateTime(
                now.year,
                now.month,
                now.day,
              );
            },
          ),
          const SizedBox(height: 16),
          GlassPanel(
            borderRadius: 30,
            child: TableCalendar<Task>(
              locale: 'ru_RU',
              startingDayOfWeek: StartingDayOfWeek.monday,
              focusedDay: selectedDay,
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365 * 3)),
              selectedDayPredicate: (day) => isSameDay(day, selectedDay),
              eventLoader: (day) => _tasksForDay(tasks, day),
              onDaySelected: (selected, focused) {
                ref.read(selectedCalendarDayProvider.notifier).state = DateTime(
                  selected.year,
                  selected.month,
                  selected.day,
                );
              },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon: Icon(Icons.chevron_left_rounded),
                rightChevronIcon: Icon(Icons.chevron_right_rounded),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  gradient: AppColors.liquidGradient,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.turquoise,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders<Task>(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) {
                    return null;
                  }
                  return Positioned(
                    bottom: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.take(4).map((task) {
                        return Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _indicatorColor(task),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SelectedDayPanel(
            day: selectedDay,
            tasks: selectedTasks,
            onAdd: () => _openTaskForm(context, ref, selectedDay: selectedDay),
            onDone: (task) =>
                ref.read(tasksControllerProvider.notifier).complete(task),
            onDelete: (task) =>
                ref.read(tasksControllerProvider.notifier).delete(task),
            onSnooze: (task) => ref
                .read(tasksControllerProvider.notifier)
                .snooze(task, const Duration(minutes: 15)),
            onEdit: (task) => _openTaskForm(
              context,
              ref,
              selectedDay: selectedDay,
              task: task,
            ),
          ),
        ],
      ),
    );
  }

  Color _indicatorColor(Task task) {
    if (task.status == TaskStatus.completed) {
      return AppColors.success;
    }
    if (task.status == TaskStatus.overdue) {
      return AppColors.warning;
    }
    if (task.recurrenceRule.isEnabled) {
      return AppColors.neonPurple;
    }
    return AppColors.cyan;
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({required this.onToday});

  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final strings = QDoneLocalizations.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.text('calendar'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Планирование по датам, задачи дня и быстрые действия',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.turquoise),
              ),
            ],
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: onToday,
          icon: const Icon(Icons.today_rounded),
          label: Text(strings.text('today')),
        ),
      ],
    );
  }
}

class _SelectedDayPanel extends StatelessWidget {
  const _SelectedDayPanel({
    required this.day,
    required this.tasks,
    required this.onAdd,
    required this.onDone,
    required this.onDelete,
    required this.onSnooze,
    required this.onEdit,
  });

  final DateTime day;
  final List<Task> tasks;
  final VoidCallback onAdd;
  final ValueChanged<Task> onDone;
  final ValueChanged<Task> onDelete;
  final ValueChanged<Task> onSnooze;
  final ValueChanged<Task> onEdit;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'День ${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Добавить'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            _EmptyDay(onAdd: onAdd)
          else
            ...tasks.map(
              (task) => _CalendarTaskTile(
                task: task,
                onDone: () => onDone(task),
                onDelete: () => onDelete(task),
                onSnooze: () => onSnooze(task),
                onEdit: () => onEdit(task),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'На этот день задач нет',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Запланировать задачу'),
        ),
      ],
    );
  }
}

class _CalendarTaskTile extends StatelessWidget {
  const _CalendarTaskTile({
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
    final color = _colorFor(task);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(_iconFor(task), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${task.dueTime.format(context)} - ${task.category.name} - ${task.recurrenceRule.summary}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                tooltip: 'Выполнено',
                onPressed: task.isCompleted ? null : onDone,
                icon: const Icon(Icons.done_rounded),
              ),
              IconButton(
                tooltip: 'Отложить на 15 минут',
                onPressed: onSnooze,
                icon: const Icon(Icons.snooze_rounded),
              ),
              IconButton(
                tooltip: 'Изменить',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                tooltip: 'Удалить',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(Task task) {
    if (task.status == TaskStatus.completed) {
      return Icons.done_all_rounded;
    }
    if (task.status == TaskStatus.overdue) {
      return Icons.warning_rounded;
    }
    if (task.recurrenceRule.isEnabled) {
      return Icons.repeat_rounded;
    }
    return Icons.circle_rounded;
  }

  Color _colorFor(Task task) {
    if (task.status == TaskStatus.completed) {
      return AppColors.success;
    }
    if (task.status == TaskStatus.overdue) {
      return AppColors.warning;
    }
    if (task.recurrenceRule.isEnabled) {
      return AppColors.neonPurple;
    }
    return AppColors.cyan;
  }
}

Future<void> _openTaskForm(
  BuildContext context,
  WidgetRef ref, {
  required DateTime selectedDay,
  Task? task,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return TaskFormSheet(
        initialTask: task,
        initialDate: selectedDay,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
        onSubmit: (value) async {
          if (task == null) {
            await ref
                .read(tasksControllerProvider.notifier)
                .addTask(
                  title: value.title,
                  description: value.description,
                  dueDate: value.dueDate,
                  dueTime: value.dueTime,
                  priority: value.priority,
                  energyLevel: value.energyLevel,
                  recurrenceRule: value.recurrenceRule,
                  reminderTimes: value.reminderTimes,
                );
          } else {
            await ref
                .read(tasksControllerProvider.notifier)
                .updateTask(
                  task.copyWith(
                    title: value.title,
                    description: value.description,
                    dueDate: value.dueDate,
                    dueTime: value.dueTime,
                    priority: value.priority,
                    energyLevel: value.energyLevel,
                    recurrenceRule: value.recurrenceRule,
                  ),
                );
          }
        },
      );
    },
  );
}

List<Task> _tasksForDay(List<Task> tasks, DateTime day) {
  final recurrenceService = const RecurrenceService();
  final start = DateTime(day.year, day.month, day.day);
  final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
  final result = <Task>[];

  for (final task in tasks) {
    if (task.recurrenceRule.isEnabled &&
        task.recurrenceRule.type != RecurrenceType.none &&
        !task.isArchived) {
      final occurrences = recurrenceService.occurrencesForRange(
        task: task,
        from: start,
        to: end,
      );
      result.addAll(
        occurrences.map(
          (occurrence) => task
              .copyWith(
                dueDate: DateTime(
                  occurrence.year,
                  occurrence.month,
                  occurrence.day,
                ),
                dueTime: TimeOfDay(
                  hour: occurrence.hour,
                  minute: occurrence.minute,
                ),
              )
              .effectiveStatus(),
        ),
      );
      continue;
    }

    if (isSameDay(task.dueDate, day)) {
      result.add(task);
    }
  }

  return result;
}
