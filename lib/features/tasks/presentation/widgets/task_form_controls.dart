import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/neon_controls.dart';
import 'package:qdone/core/widgets/qdone_tap_feedback.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/presentation/utils/task_haptics.dart';

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
    final primary = AppColors.primaryFor(context);
    final secondary = AppColors.secondaryFor(context);
    void handleTap() {
      TaskHaptics.tap();
      onTap();
    }

    final radius = BorderRadius.circular(20);
    return QDoneTapFeedback(
      onTap: handleTap,
      borderRadius: radius,
      builder: (context, tapped) {
        final fill = isLight
            ? Color.alphaBlend(
                primary.withValues(alpha: tapped ? 0.12 : 0),
                AppColors.lightElevatedSurface,
              )
            : Color.alphaBlend(
                primary.withValues(alpha: tapped ? 0.16 : 0),
                AppColors.surface(context),
              );
        return AnimatedScale(
          scale: tapped ? 0.98 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            height: 54,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: radius,
              border: Border.all(
                color: (tapped ? primary : secondary).withValues(
                  alpha: tapped ? 0.72 : 0.34,
                ),
                width: isLight ? 1.2 : 1,
              ),
              boxShadow: tapped
                  ? <BoxShadow>[
                      BoxShadow(
                        color: primary.withValues(alpha: 0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 18, color: tapped ? primary : secondary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: tapped ? primary : secondary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            color: AppColors.primaryFor(context),
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
            color: AppColors.primaryFor(context),
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
              fillColor: AppColors.elevatedSurface(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: AppColors.line(context),
                  width: isLight ? 1.2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: AppColors.primaryFor(context),
                  width: 1.5,
                ),
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
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.line(context),
          width: isLight ? 1.1 : 1,
        ),
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
                      color: AppColors.primaryFor(context),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                NeonIconButton(
                  tooltip: 'Добавить время',
                  onPressed: () async {
                    await TaskHaptics.tap();
                    onAdd();
                  },
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            if (times.isEmpty)
              Text(
                'Добавьте одно или несколько времен повтора',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.subdued(context),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: times.map((time) {
                  return InputChip(
                    label: Text(time.format(context)),
                    onDeleted: () async {
                      await TaskHaptics.tap();
                      onRemove(time);
                    },
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

class TaskFormIntervalEditor extends StatelessWidget {
  const TaskFormIntervalEditor({
    super.key,
    required this.value,
    required this.unit,
    required this.onValueChanged,
    required this.onUnitChanged,
  });

  final int value;
  final RecurrenceIntervalUnit unit;
  final ValueChanged<int> onValueChanged;
  final ValueChanged<RecurrenceIntervalUnit> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return _IntervalPanel(
      title: 'Каждые',
      value: value,
      min: 1,
      unit: unit,
      units: RecurrenceIntervalUnit.values,
      onValueChanged: onValueChanged,
      onUnitChanged: onUnitChanged,
    );
  }
}

class TaskFormReminderTimingEditor extends StatelessWidget {
  const TaskFormReminderTimingEditor({
    super.key,
    required this.value,
    required this.unit,
    required this.onValueChanged,
    required this.onUnitChanged,
  });

  final int value;
  final RecurrenceIntervalUnit unit;
  final ValueChanged<int> onValueChanged;
  final ValueChanged<RecurrenceIntervalUnit> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return _IntervalPanel(
      title: 'Уведомить за',
      value: value,
      min: 0,
      unit: unit,
      units: const <RecurrenceIntervalUnit>[
        RecurrenceIntervalUnit.minutes,
        RecurrenceIntervalUnit.hours,
        RecurrenceIntervalUnit.days,
      ],
      zeroLabel: 'в срок',
      onValueChanged: onValueChanged,
      onUnitChanged: onUnitChanged,
    );
  }
}

class _IntervalPanel extends StatelessWidget {
  const _IntervalPanel({
    required this.title,
    required this.value,
    required this.min,
    required this.unit,
    required this.units,
    required this.onValueChanged,
    required this.onUnitChanged,
    this.zeroLabel,
  });

  final String title;
  final int value;
  final int min;
  final RecurrenceIntervalUnit unit;
  final List<RecurrenceIntervalUnit> units;
  final ValueChanged<int> onValueChanged;
  final ValueChanged<RecurrenceIntervalUnit> onUnitChanged;
  final String? zeroLabel;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = AppColors.primaryFor(context);
    final normalizedValue = value.clamp(min, 999).toInt();
    final isAtMinimum = normalizedValue <= min;
    final label = zeroLabel != null && normalizedValue == 0
        ? zeroLabel!
        : '$normalizedValue ${_unitLabel(unit, normalizedValue)}';
    Future<void> changeValue(int nextValue) async {
      await TaskHaptics.tap();
      onValueChanged(nextValue);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.line(context),
          width: isLight ? 1.1 : 1,
        ),
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
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                NeonIconButton(
                  tooltip: 'Уменьшить',
                  onPressed: isAtMinimum
                      ? null
                      : () => changeValue(normalizedValue - 1),
                  icon: const Icon(Icons.remove_rounded),
                ),
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: isLight ? 0.12 : 0.16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primary.withValues(alpha: isLight ? 0.48 : 0.28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                NeonIconButton(
                  tooltip: 'Увеличить',
                  onPressed: normalizedValue >= 999
                      ? null
                      : () => changeValue(normalizedValue + 1),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: units.map((item) {
                return _TaskFormChip(
                  selected: item == unit,
                  label: _unitLabel(item, normalizedValue),
                  onTap: () => onUnitChanged(item),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

String _unitLabel(RecurrenceIntervalUnit unit, int value) {
  return switch (unit) {
    RecurrenceIntervalUnit.minutes => 'мин.',
    RecurrenceIntervalUnit.hours => 'ч.',
    RecurrenceIntervalUnit.days => 'дн.',
    RecurrenceIntervalUnit.weeks => 'нед.',
    RecurrenceIntervalUnit.months => 'мес.',
  };
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
    final primary = AppColors.primaryFor(context);
    final secondary = AppColors.secondaryFor(context);
    final foreground = selected
        ? Theme.of(context).colorScheme.onPrimary
        : isLight
        ? AppColors.lightText
        : AppColors.foreground(context);
    void handleTap() {
      TaskHaptics.tap();
      onTap();
    }

    final radius = BorderRadius.circular(16);
    return QDoneTapFeedback(
      onTap: handleTap,
      borderRadius: radius,
      builder: (context, tapped) {
        final baseFill = selected
            ? primary
            : AppColors.elevatedSurface(context);
        final fill = tapped
            ? Color.alphaBlend(secondary.withValues(alpha: 0.26), baseFill)
            : baseFill;
        return AnimatedScale(
          scale: tapped
              ? 0.98
              : selected
              ? 1.02
              : 1,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: radius,
              border: Border.all(
                color: tapped
                    ? secondary
                    : selected
                    ? primary
                    : AppColors.line(context),
                width: isLight ? 1.1 : 1,
              ),
              boxShadow: selected || tapped
                  ? <BoxShadow>[
                      BoxShadow(
                        color: (tapped ? secondary : primary).withValues(
                          alpha: 0.28,
                        ),
                        blurRadius: tapped ? 22 : 18,
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
        );
      },
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
