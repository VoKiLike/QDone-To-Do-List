import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';

class TaskFormPickerButton extends StatelessWidget {
  const TaskFormPickerButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.cyan.withValues(alpha: 0.16),
        highlightColor: AppColors.violet.withValues(alpha: 0.12),
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            color: isLight
                ? Colors.white.withValues(alpha: 0.78)
                : AppColors.violet.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.34)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 18, color: AppColors.neonPurple),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.neonPurple,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskFormSegment<T> extends StatelessWidget {
  const TaskFormSegment({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.turquoise,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((item) {
            return _TaskFormChip(
              selected: item == value,
              label: itemLabel(item),
              onTap: () => onChanged(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class TaskFormCategorySelector extends StatelessWidget {
  const TaskFormCategorySelector({
    super.key,
    required this.selected,
    required this.customEnabled,
    required this.customController,
    required this.onPresetSelected,
    required this.onCustomSelected,
    required this.onCustomChanged,
  });

  final TaskCategory selected;
  final bool customEnabled;
  final TextEditingController customController;
  final ValueChanged<TaskCategory> onPresetSelected;
  final VoidCallback onCustomSelected;
  final ValueChanged<String> onCustomChanged;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Для чего задача',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.turquoise,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final category in TaskFormCategories.presets)
              _TaskFormChip(
                selected: !customEnabled && selected.id == category.id,
                label: category.name,
                onTap: () => onPresetSelected(category),
              ),
            _TaskFormChip(
              selected: customEnabled,
              label: 'Своя',
              onTap: onCustomSelected,
            ),
          ],
        ),
        if (customEnabled) ...<Widget>[
          const SizedBox(height: 12),
          TextField(
            controller: customController,
            onChanged: onCustomChanged,
            decoration: InputDecoration(
              labelText: 'Название категории',
              prefixIcon: const Icon(Icons.edit_note_rounded),
              filled: true,
              fillColor: isLight
                  ? Colors.white.withValues(alpha: 0.82)
                  : Colors.white.withValues(alpha: 0.075),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.cyan, width: 1.4),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class TaskFormMultipleTimesEditor extends StatelessWidget {
  const TaskFormMultipleTimesEditor({
    super.key,
    required this.times,
    required this.onAdd,
    required this.onRemove,
  });

  final List<TimeOfDay> times;
  final VoidCallback onAdd;
  final ValueChanged<TimeOfDay> onRemove;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white.withValues(alpha: 0.66)
            : Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Время в течение дня',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.turquoise,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Добавить время',
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            if (times.isEmpty)
              Text(
                'Добавьте одно или несколько времен повтора',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: times.map((time) {
                  return InputChip(
                    label: Text(time.format(context)),
                    onDeleted: () => onRemove(time),
                    avatar: const Icon(Icons.schedule_rounded, size: 16),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _TaskFormChip extends StatelessWidget {
  const _TaskFormChip({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final foreground = selected
        ? AppColors.darkVoid
        : isLight
        ? const Color(0xFF1E1B2E)
        : AppColors.softWhite;
    return AnimatedScale(
      scale: selected ? 1.02 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.cyan
                  : isLight
                  ? Colors.white.withValues(alpha: 0.72)
                  : Colors.white.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? AppColors.cyan
                    : Colors.white.withValues(alpha: 0.38),
              ),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (selected) ...<Widget>[
                  Icon(Icons.check_rounded, size: 17, color: foreground),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskFormCategories {
  const TaskFormCategories._();

  static const personal = TaskCategory(
    id: 'personal',
    name: 'Личное',
    colorValue: 0xFF8B5CF6,
  );
  static const work = TaskCategory(
    id: 'work',
    name: 'Работа',
    colorValue: 0xFF38BDF8,
  );
  static const study = TaskCategory(
    id: 'learning',
    name: 'Учеба',
    colorValue: 0xFFA78BFA,
  );

  static const presets = <TaskCategory>[personal, work, study];

  static bool isPreset(TaskCategory category) {
    return presets.any((preset) => preset.id == category.id);
  }
}
