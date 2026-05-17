import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/modal_glass_surface.dart';
import 'package:qdone/core/widgets/neon_controls.dart';
import 'package:qdone/core/widgets/qdone_modal_presenter.dart';
import 'package:qdone/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/services/reminder_time_factory.dart';
import 'package:qdone/features/tasks/presentation/utils/task_haptics.dart';
import 'package:qdone/features/tasks/presentation/widgets/task_form_controls.dart';

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({
    super.key,
    this.initialTask,
    this.initialDate,
    this.initialTime,
    this.defaultReminderMinutes = 15,
    this.notificationsEnabled = true,
    required this.onSubmit,
  });

  final Task? initialTask;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final int defaultReminderMinutes;
  final bool notificationsEnabled;
  final Future<void> Function(TaskFormValue value) onSubmit;

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _customCategoryController;
  late DateTime _date;
  late TimeOfDay _time;
  late TaskPriority _priority;
  late EnergyLevel _energy;
  late TaskCategory _category;
  late bool _customCategoryEnabled;
  late bool _reminderEnabled;
  late int _reminderLeadValue;
  late RecurrenceIntervalUnit _reminderLeadUnit;
  late RecurrenceType _recurrenceType;
  late int _recurrenceInterval;
  late RecurrenceIntervalUnit _recurrenceIntervalUnit;
  late final List<TimeOfDay> _timesOfDay;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _date = task?.dueDate ?? widget.initialDate ?? DateTime.now();
    _time = task?.dueTime ?? widget.initialTime ?? TimeOfDay.now();
    _priority = task?.priority ?? TaskPriority.medium;
    _energy = task?.energyLevel ?? EnergyLevel.medium;
    _category = task?.category ?? TaskFormCategories.personal;
    _customCategoryEnabled = !TaskFormCategories.isPreset(_category);
    _customCategoryController = TextEditingController(
      text: _customCategoryEnabled ? _category.name : '',
    );
    _reminderEnabled =
        task?.reminders.isNotEmpty ?? widget.notificationsEnabled;
    final reminderOffset = _initialReminderOffset(task);
    _reminderLeadValue = reminderOffset.$1;
    _reminderLeadUnit = reminderOffset.$2;
    final recurrenceRule = task?.recurrenceRule;
    _recurrenceType = recurrenceRule?.type ?? RecurrenceType.none;
    _recurrenceInterval = (recurrenceRule?.interval ?? 1).clamp(1, 999).toInt();
    _recurrenceIntervalUnit =
        recurrenceRule?.intervalUnit ?? RecurrenceIntervalUnit.days;
    _timesOfDay = <TimeOfDay>[...?recurrenceRule?.timesOfDay];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;
    final title = widget.initialTask == null
        ? 'Новая задача'
        : 'Изменить задачу';
    final isLight = Theme.of(context).brightness == Brightness.light;
    return ModalGlassSurface(
      borderRadius: 34,
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: (isLight ? AppColors.violet : Colors.white).withValues(
                  alpha: isLight ? 0.24 : 0.24,
                ),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: _SheetHeader(
                title: title,
                isSaving: _saving,
                onClose: () async {
                  await TaskHaptics.tap();
                  if (context.mounted) {
                    QDoneModalPresenter.close(context);
                  }
                },
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _FormPanel(
                        icon: Icons.edit_note_rounded,
                        title: 'Содержание',
                        child: Column(
                          children: <Widget>[
                            _TaskTextField(
                              controller: _titleController,
                              label: 'Название',
                              icon: Icons.title_rounded,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            _TaskTextField(
                              controller: _descriptionController,
                              label: 'Описание',
                              icon: Icons.notes_rounded,
                              minLines: 3,
                              maxLines: 5,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FormPanel(
                        icon: Icons.event_available_rounded,
                        title: 'Срок',
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TaskFormPickerButton(
                                icon: Icons.calendar_today_rounded,
                                label:
                                    '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TaskFormPickerButton(
                                icon: Icons.schedule_rounded,
                                label: _time.format(context),
                                onTap: _pickTime,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FormPanel(
                        icon: Icons.tune_rounded,
                        title: 'Параметры',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TaskFormSegment<TaskPriority>(
                              label: 'Приоритет',
                              value: _priority,
                              values: TaskPriority.values,
                              itemLabel: (value) => value.label,
                              onChanged: (value) =>
                                  setState(() => _priority = value),
                            ),
                            const SizedBox(height: 16),
                            TaskFormSegment<EnergyLevel>(
                              label: 'Энергия',
                              value: _energy,
                              values: EnergyLevel.values,
                              itemLabel: (value) => value.label,
                              onChanged: (value) =>
                                  setState(() => _energy = value),
                            ),
                            const SizedBox(height: 16),
                            TaskFormCategorySelector(
                              selected: _category,
                              customEnabled: _customCategoryEnabled,
                              customController: _customCategoryController,
                              onPresetSelected: (category) => setState(() {
                                _category = category;
                                _customCategoryEnabled = false;
                              }),
                              onCustomSelected: () => setState(() {
                                _customCategoryEnabled = true;
                                _category = _customCategory();
                              }),
                              onCustomChanged: (_) => setState(() {
                                if (_customCategoryEnabled) {
                                  _category = _customCategory();
                                }
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FormPanel(
                        icon: Icons.notifications_active_rounded,
                        title: 'Автоматизация',
                        child: Column(
                          children: <Widget>[
                            NeonSwitchTile(
                              icon: Icons.notifications_active_rounded,
                              title: 'Напоминание',
                              subtitle:
                                  'Локальное уведомление для этой задачи',
                              value: _reminderEnabled,
                              onChanged: (value) async {
                                await TaskHaptics.tap();
                                if (mounted) {
                                  setState(() => _reminderEnabled = value);
                                }
                              },
                            ),
                            if (_reminderEnabled) ...<Widget>[
                              const SizedBox(height: 14),
                              TaskFormReminderTimingEditor(
                                value: _reminderLeadValue,
                                unit: _reminderLeadUnit,
                                onValueChanged: (value) =>
                                    setState(() => _reminderLeadValue = value),
                                onUnitChanged: (unit) =>
                                    setState(() => _reminderLeadUnit = unit),
                              ),
                            ],
                            const SizedBox(height: 16),
                            TaskFormSegment<RecurrenceType>(
                              label: 'Повтор',
                              value: _recurrenceType,
                              values: RecurrenceType.values,
                              itemLabel: (value) => value == RecurrenceType.none
                                  ? 'Выкл.'
                                  : value.label,
                              onChanged: (value) =>
                                  setState(() => _recurrenceType = value),
                            ),
                            if (_recurrenceType ==
                                RecurrenceType.custom) ...<Widget>[
                              const SizedBox(height: 14),
                              TaskFormIntervalEditor(
                                value: _recurrenceInterval,
                                unit: _recurrenceIntervalUnit,
                                onValueChanged: (value) =>
                                    setState(() => _recurrenceInterval = value),
                                onUnitChanged: (unit) => setState(
                                  () => _recurrenceIntervalUnit = unit,
                                ),
                              ),
                            ],
                            if (_recurrenceType !=
                                RecurrenceType.none) ...<Widget>[
                              const SizedBox(height: 14),
                              TaskFormMultipleTimesEditor(
                                times: _timesOfDay,
                                onAdd: _addRepeatTime,
                                onRemove: (time) =>
                                    setState(() => _timesOfDay.remove(time)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: NeonActionButton(
                          onPressed: _saving ? null : _handleSubmitTap,
                          isLoading: _saving,
                          style: NeonControlStyle.primary,
                          fullWidth: true,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.done_rounded),
                          label: Text(
                            widget.initialTask == null
                                ? 'Создать задачу'
                                : 'Сохранить изменения',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      useRootNavigator: false,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 4)),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      useRootNavigator: false,
      initialTime: _time,
    );
    if (picked != null && mounted) {
      setState(() => _time = picked);
    }
  }

  Future<void> _addRepeatTime() async {
    final picked = await showTimePicker(
      context: context,
      useRootNavigator: false,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() => _timesOfDay.add(picked));
    }
  }

  Future<void> _handleSubmitTap() async {
    await TaskHaptics.tap();
    FocusManager.instance.primaryFocus?.unfocus();
    await _submit();
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название задачи')));
      return;
    }
    setState(() => _saving = true);
    try {
      final dueDateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _effectiveDueTime.hour,
        _effectiveDueTime.minute,
      );
      await widget.onSubmit(
        TaskFormValue(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _date,
          dueTime: _effectiveDueTime,
          priority: _priority,
          category: _customCategoryEnabled ? _customCategory() : _category,
          energyLevel: _energy,
          recurrenceRule: RecurrenceRule(
            type: _recurrenceType,
            interval: _effectiveRecurrenceInterval,
            intervalUnit: _effectiveRecurrenceIntervalUnit,
            timesOfDay: _effectiveRecurrenceTimes,
            startDate: _date,
            isEnabled: _recurrenceType != RecurrenceType.none,
          ),
          reminderTimes: buildDefaultReminderTimes(
            dueDateTime: dueDateTime,
            enabled: _reminderEnabled,
            defaultReminderMinutes: _reminderOffsetMinutes,
          ),
        ),
      );
      if (mounted) {
        QDoneModalPresenter.close(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить задачу')),
        );
      }
    }
  }

  TaskCategory _customCategory() {
    final name = _customCategoryController.text.trim();
    final safeName = name.isEmpty ? 'Своя' : name;
    final slug = safeName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zа-яё0-9]+', unicode: true), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return TaskCategory(
      id: 'custom-${slug.isEmpty ? safeName.hashCode.abs() : slug}',
      name: safeName,
      colorValue: 0xFF2DD4BF,
    );
  }

  int get _effectiveRecurrenceInterval {
    return _recurrenceType == RecurrenceType.custom
        ? _recurrenceInterval.clamp(1, 999).toInt()
        : 1;
  }

  RecurrenceIntervalUnit get _effectiveRecurrenceIntervalUnit {
    return _recurrenceType == RecurrenceType.custom
        ? _recurrenceIntervalUnit
        : RecurrenceIntervalUnit.days;
  }

  TimeOfDay get _effectiveDueTime {
    final times = _effectiveRecurrenceTimes;
    return times.isEmpty ? _time : times.first;
  }

  List<TimeOfDay> get _effectiveRecurrenceTimes {
    if (_recurrenceType == RecurrenceType.none) {
      return const <TimeOfDay>[];
    }
    final source = _timesOfDay.isEmpty ? <TimeOfDay>[_time] : _timesOfDay;
    final unique = <String, TimeOfDay>{};
    for (final time in source) {
      unique['${time.hour}:${time.minute}'] = time;
    }
    final times = unique.values.toList()
      ..sort((a, b) {
        final left = a.hour * 60 + a.minute;
        final right = b.hour * 60 + b.minute;
        return left.compareTo(right);
      });
    return List<TimeOfDay>.unmodifiable(times);
  }

  int get _reminderOffsetMinutes {
    final value = _reminderLeadValue.clamp(0, 999).toInt();
    return switch (_reminderLeadUnit) {
      RecurrenceIntervalUnit.minutes => value,
      RecurrenceIntervalUnit.hours => value * 60,
      RecurrenceIntervalUnit.days => value * 1440,
      RecurrenceIntervalUnit.weeks => value * 10080,
      RecurrenceIntervalUnit.months => value * 43200,
    };
  }

  (int, RecurrenceIntervalUnit) _initialReminderOffset(Task? task) {
    if (task == null || task.reminders.isEmpty) {
      return _splitReminderOffset(widget.defaultReminderMinutes);
    }
    final minutes = task.dueDateTime
        .difference(task.reminders.first.dateTime)
        .inMinutes;
    return _splitReminderOffset(minutes < 0 ? 0 : minutes);
  }

  (int, RecurrenceIntervalUnit) _splitReminderOffset(int minutes) {
    final safeMinutes = minutes.clamp(0, 525600).toInt();
    if (safeMinutes == 0) {
      return (0, RecurrenceIntervalUnit.minutes);
    }
    if (safeMinutes % 1440 == 0) {
      return (safeMinutes ~/ 1440, RecurrenceIntervalUnit.days);
    }
    if (safeMinutes % 60 == 0) {
      return (safeMinutes ~/ 60, RecurrenceIntervalUnit.hours);
    }
    return (safeMinutes, RecurrenceIntervalUnit.minutes);
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.isSaving,
    required this.onClose,
  });

  final String title;
  final bool isSaving;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.liquidGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.24),
                blurRadius: 22,
              ),
            ],
          ),
          child: const Icon(Icons.task_alt_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        NeonIconButton(
          tooltip: 'Закрыть',
          onPressed: isSaving ? null : onClose,
          icon: const Icon(Icons.close_rounded),
          style: NeonControlStyle.danger,
        ),
      ],
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white.withValues(alpha: 0.70)
            : Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight
              ? Colors.white.withValues(alpha: 0.78)
              : Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 18, color: AppColors.cyan),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.turquoise,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _TaskTextField extends StatelessWidget {
  const _TaskTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.textInputAction,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputAction? textInputAction;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isLight
            ? Colors.white.withValues(alpha: 0.82)
            : Colors.white.withValues(alpha: 0.075),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1.4),
        ),
      ),
    );
  }
}

// Kept as a fallback for the previous reminder switch layout.
// ignore: unused_element
class _ReminderSwitch extends StatelessWidget {
  const _ReminderSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isLight
            ? AppColors.violet.withValues(alpha: 0.08)
            : AppColors.violet.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.violet.withValues(alpha: 0.16)),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        contentPadding: const EdgeInsets.only(left: 12, right: 8),
        secondary: const Icon(
          Icons.notifications_active_rounded,
          color: AppColors.neonPurple,
        ),
        title: const Text(
          'Напоминание',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: const Text('Локальное уведомление для этой задачи'),
        onChanged: onChanged,
      ),
    );
  }
}

class TaskFormValue {
  const TaskFormValue({
    required this.title,
    this.description,
    required this.dueDate,
    required this.dueTime,
    required this.priority,
    required this.category,
    required this.energyLevel,
    required this.recurrenceRule,
    required this.reminderTimes,
  });

  final String title;
  final String? description;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final TaskPriority priority;
  final TaskCategory category;
  final EnergyLevel energyLevel;
  final RecurrenceRule recurrenceRule;
  final List<DateTime> reminderTimes;
}
