import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdone/core/localization/qdone_localizations.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
import 'package:qdone/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/settings/presentation/controllers/settings_controller.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/services/task_calendar_service.dart';
import 'package:qdone/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:qdone/features/tasks/presentation/widgets/task_form_modal.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedCalendarDayProvider);
    final tasks =
        ref.watch(tasksControllerProvider).valueOrNull ?? const <Task>[];
    final settings =
        ref.watch(settingsControllerProvider).valueOrNull ??
        const UserSettings();
    final calendarService = const TaskCalendarService();
    final selectedTasks = calendarService.tasksForDay(tasks, selectedDay)
      ..sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => TaskFormModal.show(
          context,
          ref,
          initialDate: selectedDay,
          initialTime: const TimeOfDay(hour: 9, minute: 0),
        ),
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
              availableGestures: AvailableGestures.horizontalSwipe,
              focusedDay: selectedDay,
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365 * 3)),
              selectedDayPredicate: (day) => isSameDay(day, selectedDay),
              eventLoader: (day) => _indicatorTasks(
                calendarService.tasksForDay(tasks, day),
                settings,
              ),
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
                  final markers = _calendarMarkers(events);
                  if (markers.isEmpty) {
                    return null;
                  }
                  return Positioned(
                    bottom: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: markers.map((marker) {
                        return Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: marker.color,
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
            onAdd: () => TaskFormModal.show(
              context,
              ref,
              initialDate: selectedDay,
              initialTime: const TimeOfDay(hour: 9, minute: 0),
            ),
            onDone: (task) =>
                ref.read(tasksControllerProvider.notifier).complete(task),
            onDelete: (task) =>
                ref.read(tasksControllerProvider.notifier).delete(task),
            onSnooze: (task) => ref
                .read(tasksControllerProvider.notifier)
                .snooze(task, const Duration(minutes: 15)),
            onEdit: (task) => TaskFormModal.show(
              context,
              ref,
              task: task,
              initialDate: selectedDay,
              initialTime: const TimeOfDay(hour: 9, minute: 0),
            ),
          ),
        ],
      ),
    );
  }

  List<_CalendarMarker> _calendarMarkers(List<Task> events) {
    final buckets = <_CalendarMarkerType, List<Task>>{
      _CalendarMarkerType.overdue: <Task>[],
      _CalendarMarkerType.completed: <Task>[],
      _CalendarMarkerType.active: <Task>[],
      _CalendarMarkerType.recurring: <Task>[],
    };
    for (final task in events) {
      buckets[_markerTypeFor(task)]!.add(task);
    }

    final markers = <_CalendarMarker>[];
    for (final type in _CalendarMarkerType.priorityOrder) {
      final tasks = buckets[type]!;
      if (tasks.isEmpty) {
        continue;
      }
      markers.add(_CalendarMarker(type: type));
      if (markers.length == 4) {
        break;
      }
    }
    return markers;
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
          child: Text(
            strings.text('calendar'),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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

List<Task> _indicatorTasks(List<Task> tasks, UserSettings settings) {
  return tasks.where((task) {
    if (task.status == TaskStatus.completed) {
      return settings.calendarShowCompleted;
    }
    if (task.status == TaskStatus.overdue) {
      return settings.calendarShowOverdue;
    }
    if (task.recurrenceRule.isEnabled) {
      return settings.calendarShowRecurring;
    }
    return true;
  }).toList();
}

_CalendarMarkerType _markerTypeFor(Task task) {
  if (task.status == TaskStatus.overdue) {
    return _CalendarMarkerType.overdue;
  }
  if (task.status == TaskStatus.completed) {
    return _CalendarMarkerType.completed;
  }
  if (task.recurrenceRule.isEnabled) {
    return _CalendarMarkerType.recurring;
  }
  return _CalendarMarkerType.active;
}

enum _CalendarMarkerType {
  overdue,
  completed,
  active,
  recurring;

  static const priorityOrder = <_CalendarMarkerType>[
    _CalendarMarkerType.overdue,
    _CalendarMarkerType.active,
    _CalendarMarkerType.completed,
    _CalendarMarkerType.recurring,
  ];

  Color get color => switch (this) {
    _CalendarMarkerType.overdue => AppColors.warning,
    _CalendarMarkerType.completed => AppColors.success,
    _CalendarMarkerType.active => AppColors.cyan,
    _CalendarMarkerType.recurring => AppColors.neonPurple,
  };
}

class _CalendarMarker {
  const _CalendarMarker({required this.type});

  final _CalendarMarkerType type;

  Color get color => type.color;
}
