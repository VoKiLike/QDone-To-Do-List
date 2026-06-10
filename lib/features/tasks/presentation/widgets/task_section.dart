import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/presentation/utils/task_haptics.dart';
import 'package:qdone/features/tasks/presentation/widgets/task_card.dart';

class TaskSection extends StatefulWidget {
  const TaskSection({
    super.key,
    required this.title,
    required this.tasks,
    required this.totalCount,
    required this.icon,
    required this.accent,
    required this.initiallyExpanded,
    required this.onDone,
    required this.onRestore,
    required this.onDelete,
    required this.onSnooze,
    required this.onReschedule,
    required this.onEdit,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final String title;
  final List<Task> tasks;
  final int totalCount;
  final IconData icon;
  final Color accent;
  final bool initiallyExpanded;
  final ValueChanged<Task> onDone;
  final ValueChanged<Task> onRestore;
  final ValueChanged<Task> onDelete;
  final ValueChanged<Task> onSnooze;
  final ValueChanged<Task> onReschedule;
  final ValueChanged<Task> onEdit;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  State<TaskSection> createState() => _TaskSectionState();
}

class _TaskSectionState extends State<TaskSection>
    with AutomaticKeepAliveClientMixin {
  late bool _expanded = widget.initiallyExpanded;
  bool _loadQueued = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: GlassPanel(
              padding: EdgeInsets.zero,
              borderRadius: 22,
              opacity: 0.09,
              blurSigma: 0,
              shadowBlurRadius: 6,
              onTap: () {
                TaskHaptics.tap();
                if (mounted) {
                  setState(() => _expanded = !_expanded);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: widget.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: widget.accent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      '${widget.totalCount}',
                      style: Theme.of(context).textTheme.labelLarge,
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
          ),
        ),
        if (_expanded && widget.tasks.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(
                'Здесь пока пусто',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.subdued(context),
                ),
              ),
            ),
          ),
        if (_expanded && widget.tasks.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            sliver: SliverList.builder(
              itemCount: widget.tasks.length,
              itemBuilder: (context, index) {
                if (widget.hasMore &&
                    !widget.isLoadingMore &&
                    index >= widget.tasks.length - 5) {
                  _queueLoadMore();
                }
                final task = widget.tasks[index];
                return RepaintBoundary(
                  key: ValueKey<String>(task.id),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: TaskCard(
                      task: task,
                      onDone: () => widget.onDone(task),
                      onRestore: () => widget.onRestore(task),
                      onDelete: () => widget.onDelete(task),
                      onSnooze: () => widget.onSnooze(task),
                      onReschedule: () => widget.onReschedule(task),
                      onEdit: () => widget.onEdit(task),
                    ),
                  ),
                );
              },
            ),
          ),
        if (_expanded && widget.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _queueLoadMore() {
    if (_loadQueued) {
      return;
    }
    _loadQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQueued = false;
      if (mounted) {
        widget.onLoadMore();
      }
    });
  }
}
