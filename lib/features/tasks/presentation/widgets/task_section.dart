import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/presentation/widgets/task_card.dart';

class TaskSection extends StatefulWidget {
  const TaskSection({
    super.key,
    required this.title,
    required this.tasks,
    required this.icon,
    required this.accent,
    required this.initiallyExpanded,
    required this.onDone,
    required this.onRestore,
    required this.onDelete,
    required this.onSnooze,
    required this.onReschedule,
    required this.onEdit,
  });

  final String title;
  final List<Task> tasks;
  final IconData icon;
  final Color accent;
  final bool initiallyExpanded;
  final ValueChanged<Task> onDone;
  final ValueChanged<Task> onRestore;
  final ValueChanged<Task> onDelete;
  final ValueChanged<Task> onSnooze;
  final ValueChanged<Task> onReschedule;
  final ValueChanged<Task> onEdit;

  @override
  State<TaskSection> createState() => _TaskSectionState();
}

class _TaskSectionState extends State<TaskSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: 26,
      opacity: 0.09,
      child: Column(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.icon, color: widget.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      '${widget.tasks.length}',
                      key: ValueKey<int>(widget.tasks.length),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1,
                      child: child,
                    ),
                  );
                },
                child: widget.tasks.isEmpty
                    ? Padding(
                        key: const ValueKey<String>('empty-tasks'),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Здесь пока пусто',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.muted),
                        ),
                      )
                    : Column(
                        key: ValueKey<String>(_taskListKey(widget.tasks)),
                        children: widget.tasks
                            .map(
                              (task) => Padding(
                                key: ValueKey<String>(task.id),
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TaskCard(
                                  task: task,
                                  onDone: () => widget.onDone(task),
                                  onRestore: () => widget.onRestore(task),
                                  onDelete: () => widget.onDelete(task),
                                  onSnooze: () => widget.onSnooze(task),
                                  onReschedule: () =>
                                      widget.onReschedule(task),
                                  onEdit: () => widget.onEdit(task),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

String _taskListKey(List<Task> tasks) {
  return tasks.map((task) => '${task.id}:${task.status.name}').join('|');
}
