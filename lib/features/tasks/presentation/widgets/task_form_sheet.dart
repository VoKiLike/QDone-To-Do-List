import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/modal_glass_surface.dart';
import 'package:qdone/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/services/reminder_time_factory.dart';

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
  late RecurrenceType _recurrenceType;
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
    _category = task?.category ?? _TaskFormCategories.personal;
    _customCategoryEnabled = !_TaskFormCategories.isPreset(_category);
    _customCategoryController = TextEditingController(
      text: _customCategoryEnabled ? _category.name : '',
    );
    _reminderEnabled =
        task?.reminders.isNotEmpty ?? widget.notificationsEnabled;
    _recurrenceType = task?.recurrenceRule.type ?? RecurrenceType.none;
    _timesOfDay = <TimeOfDay>[...?task?.recurrenceRule.timesOfDay];
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
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: ModalGlassSurface(
        borderRadius: 32,
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.initialTask == null
                          ? 'Новая задача'
                          : 'Изменить задачу',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: const Text('ОК'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _PickerButton(
                      icon: Icons.calendar_today_rounded,
                      label:
                          '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PickerButton(
                      icon: Icons.schedule_rounded,
                      label: _time.format(context),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _Segment<TaskPriority>(
                label: 'Приоритет',
                value: _priority,
                values: TaskPriority.values,
                itemLabel: (value) => value.label,
                onChanged: (value) => setState(() => _priority = value),
              ),
              const SizedBox(height: 14),
              _Segment<EnergyLevel>(
                label: 'Энергия',
                value: _energy,
                values: EnergyLevel.values,
                itemLabel: (value) => value.label,
                onChanged: (value) => setState(() => _energy = value),
              ),
              const SizedBox(height: 14),
              _CategorySelector(
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
              const SizedBox(height: 14),
              SwitchListTile.adaptive(
                value: _reminderEnabled,
                onChanged: (value) => setState(() => _reminderEnabled = value),
                title: const Text('Напоминание'),
                subtitle: const Text(
                  'Запланировать локальное уведомление для этой задачи',
                ),
              ),
              const SizedBox(height: 8),
              _Segment<RecurrenceType>(
                label: 'Повтор',
                value: _recurrenceType,
                values: RecurrenceType.values,
                itemLabel: (value) =>
                    value == RecurrenceType.none ? 'Выкл.' : value.label,
                onChanged: (value) => setState(() => _recurrenceType = value),
              ),
              if (_recurrenceType != RecurrenceType.none) ...<Widget>[
                const SizedBox(height: 12),
                _MultipleTimesEditor(
                  times: _timesOfDay,
                  onAdd: _addRepeatTime,
                  onRemove: (time) => setState(() => _timesOfDay.remove(time)),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.done_rounded),
                  label: Text(
                    widget.initialTask == null ? 'Создать задачу' : 'Сохранить',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      useRootNavigator: true,
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
      useRootNavigator: true,
      initialTime: _time,
    );
    if (picked != null && mounted) {
      setState(() => _time = picked);
    }
  }

  Future<void> _addRepeatTime() async {
    final picked = await showTimePicker(
      context: context,
      useRootNavigator: true,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() => _timesOfDay.add(picked));
    }
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название задачи')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final dueDateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );
      await widget.onSubmit(
        TaskFormValue(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _date,
          dueTime: _time,
          priority: _priority,
          category: _customCategoryEnabled ? _customCategory() : _category,
          energyLevel: _energy,
          recurrenceRule: RecurrenceRule(
            type: _recurrenceType,
            interval: 1,
            intervalUnit: RecurrenceIntervalUnit.days,
            timesOfDay: List<TimeOfDay>.unmodifiable(_timesOfDay),
            startDate: _date,
            isEnabled: _recurrenceType != RecurrenceType.none,
          ),
          reminderTimes: buildDefaultReminderTimes(
            dueDateTime: dueDateTime,
            enabled: _reminderEnabled,
            defaultReminderMinutes: widget.defaultReminderMinutes,
          ),
        ),
      );
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
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

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
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
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.turquoise),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (item) => ChoiceChip(
                  selected: item == value,
                  label: Text(itemLabel(item)),
                  onSelected: (_) => onChanged(item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Для чего задача',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.turquoise),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final category in _TaskFormCategories.presets)
              ChoiceChip(
                selected: !customEnabled && selected.id == category.id,
                label: Text(category.name),
                onSelected: (_) => onPresetSelected(category),
              ),
            ChoiceChip(
              selected: customEnabled,
              label: const Text('Своя'),
              onSelected: (_) => onCustomSelected(),
            ),
          ],
        ),
        if (customEnabled) ...<Widget>[
          const SizedBox(height: 10),
          TextField(
            controller: customController,
            onChanged: onCustomChanged,
            decoration: const InputDecoration(
              labelText: 'Название категории',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
          ),
        ],
      ],
    );
  }
}

class _MultipleTimesEditor extends StatelessWidget {
  const _MultipleTimesEditor({
    required this.times,
    required this.onAdd,
    required this.onRemove,
  });

  final List<TimeOfDay> times;
  final VoidCallback onAdd;
  final ValueChanged<TimeOfDay> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Время в течение дня',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.turquoise),
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Добавить время'),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: times
              .map(
                (time) => InputChip(
                  label: Text(time.format(context)),
                  onDeleted: () => onRemove(time),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TaskFormCategories {
  const _TaskFormCategories._();

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
