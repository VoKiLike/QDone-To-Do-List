import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdone/app/app_providers.dart';
import 'package:qdone/core/constants/app_constants.dart';
import 'package:qdone/core/localization/qdone_localizations.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
import 'package:qdone/core/widgets/liquid_background.dart';
import 'package:qdone/core/widgets/modal_glass_surface.dart';
import 'package:qdone/core/widgets/qdone_modal_presenter.dart';
import 'package:qdone/features/settings/domain/qdone_backup.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/settings/presentation/controllers/settings_controller.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/presentation/controllers/tasks_controller.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = QDoneLocalizations.of(context);
    final settings =
        ref.watch(settingsControllerProvider).valueOrNull ??
        const UserSettings();
    final tasks =
        ref.watch(tasksControllerProvider).valueOrNull ?? const <Task>[];
    final completed = tasks.where((task) => task.isCompleted).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 112),
        children: <Widget>[
          Text(
            strings.text('menu'),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            children: <Widget>[
              _ThemeSelector(settings: settings),
              const Divider(height: 28),
              const _LanguageInfo(),
            ],
          ),
          const SizedBox(height: 14),
          _NotificationSettings(settings: settings),
          const SizedBox(height: 14),
          _CalendarSettings(settings: settings),
          const SizedBox(height: 14),
          _WidgetSettings(settings: settings, tasks: tasks),
          const SizedBox(height: 14),
          const _KnowledgeBaseSettings(),
          const SizedBox(height: 14),
          _HistorySettings(completed: completed),
          const SizedBox(height: 14),
          const _DataManagementSettings(),
          const SizedBox(height: 14),
          const _AboutPanel(),
        ],
      ),
    );
  }
}

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector({required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(icon: Icons.contrast_rounded, title: 'Тема'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppThemeMode.values
              .map(
                (mode) => ChoiceChip(
                  selected: settings.themeMode == mode,
                  label: Text(mode.label),
                  onSelected: (_) => ref
                      .read(settingsControllerProvider.notifier)
                      .setThemeMode(mode),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _LanguageInfo extends StatelessWidget {
  const _LanguageInfo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionTitle(icon: Icons.language_rounded, title: 'Язык'),
        SizedBox(height: 10),
        _ReadonlyChip(icon: Icons.translate_rounded, label: 'Русский'),
      ],
    );
  }
}

class _NotificationSettings extends ConsumerWidget {
  const _NotificationSettings({required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsSection(
      children: <Widget>[
        const _SectionTitle(
          icon: Icons.notifications_active_rounded,
          title: 'Уведомления',
        ),
        const SizedBox(height: 8),
        _SwitchRow(
          icon: Icons.notifications_rounded,
          title: 'Локальные уведомления',
          subtitle: settings.notificationsEnabled
              ? 'Новые задачи будут получать напоминания'
              : 'Напоминания не создаются для новых задач',
          value: settings.notificationsEnabled,
          onChanged: (value) => _setNotifications(context, ref, value),
        ),
        const SizedBox(height: 8),
        Text(
          'Напоминание по умолчанию',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <int>[0, 15, 30, 60].map((minutes) {
            return ChoiceChip(
              selected: settings.defaultReminderMinutes == minutes,
              label: Text(minutes == 0 ? 'В срок' : 'За $minutes мин'),
              onSelected: (_) => ref
                  .read(settingsControllerProvider.notifier)
                  .setDefaultReminderMinutes(minutes),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _requestPermission(context, ref),
          icon: const Icon(Icons.verified_user_rounded),
          label: const Text('Запросить разрешение'),
        ),
      ],
    );
  }

  Future<void> _setNotifications(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    if (value) {
      final allowed = await ref
          .read(notificationServiceProvider)
          .requestPermissions();
      if (!context.mounted) {
        return;
      }
      await ref
          .read(settingsControllerProvider.notifier)
          .setNotificationsEnabled(allowed);
      if (!context.mounted) {
        return;
      }
      _showSnack(
        context,
        allowed ? 'Уведомления включены' : 'Разрешение не выдано',
      );
      return;
    }
    await ref
        .read(settingsControllerProvider.notifier)
        .setNotificationsEnabled(false);
  }

  Future<void> _requestPermission(BuildContext context, WidgetRef ref) async {
    final allowed = await ref
        .read(notificationServiceProvider)
        .requestPermissions();
    if (!context.mounted) {
      return;
    }
    await ref
        .read(settingsControllerProvider.notifier)
        .setNotificationsEnabled(allowed);
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      allowed ? 'Разрешение на уведомления получено' : 'Разрешение не выдано',
    );
  }
}

class _CalendarSettings extends ConsumerWidget {
  const _CalendarSettings({required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(settingsControllerProvider.notifier);
    return _SettingsSection(
      children: <Widget>[
        const _SectionTitle(
          icon: Icons.calendar_month_rounded,
          title: 'Календарь',
        ),
        const SizedBox(height: 10),
        _SwitchRow(
          icon: Icons.done_all_rounded,
          title: 'Точки выполненных задач',
          subtitle: 'Показывать выполненные задачи на календаре',
          value: settings.calendarShowCompleted,
          onChanged: controller.setCalendarShowCompleted,
        ),
        _SwitchRow(
          icon: Icons.warning_rounded,
          title: 'Точки просроченных задач',
          subtitle: 'Выделять просроченные задачи на календаре',
          value: settings.calendarShowOverdue,
          onChanged: controller.setCalendarShowOverdue,
        ),
        _SwitchRow(
          icon: Icons.repeat_rounded,
          title: 'Точки повторяющихся задач',
          subtitle: 'Показывать повторы и ежедневные задачи',
          value: settings.calendarShowRecurring,
          onChanged: controller.setCalendarShowRecurring,
        ),
      ],
    );
  }
}

class _WidgetSettings extends ConsumerWidget {
  const _WidgetSettings({required this.settings, required this.tasks});

  final UserSettings settings;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(settingsControllerProvider.notifier);
    return _SettingsSection(
      children: <Widget>[
        const _SectionTitle(
          icon: Icons.widgets_rounded,
          title: 'Android-виджет',
        ),
        const SizedBox(height: 10),
        _NumberStepper(
          title: 'Количество задач',
          value: settings.widgetTaskLimit,
          min: 1,
          max: 10,
          onChanged: (value) =>
              _updateWidgetSetting(context, ref, tasks, () async {
                await controller.setWidgetTaskLimit(value);
              }),
        ),
        _SwitchRow(
          icon: Icons.inventory_2_rounded,
          title: 'Показывать выполненные',
          subtitle: 'Добавлять архивные задачи в список виджета',
          value: settings.widgetShowsCompleted,
          onChanged: (value) =>
              _updateWidgetSetting(context, ref, tasks, () async {
                await controller.setWidgetShowsCompleted(value);
              }),
        ),
        _SwitchRow(
          icon: Icons.compress_rounded,
          title: 'Компактный режим',
          subtitle: 'Меньше воздуха, больше задач на экране',
          value: settings.compactWidget,
          onChanged: (value) =>
              _updateWidgetSetting(context, ref, tasks, () async {
                await controller.setCompactWidget(value);
              }),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: () => _syncWidget(context, ref),
          icon: const Icon(Icons.sync_rounded),
          label: const Text('Обновить виджет'),
        ),
      ],
    );
  }

  Future<void> _syncWidget(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(homeWidgetSyncServiceProvider)
          .sync(tasks: tasks, settings: settings);
      if (context.mounted) {
        _showSnack(context, 'Виджет обновлен');
      }
    } catch (error) {
      if (context.mounted) {
        _showSnack(context, 'Виджет недоступен на этой платформе');
      }
    }
  }

  Future<void> _updateWidgetSetting(
    BuildContext context,
    WidgetRef ref,
    List<Task> tasks,
    Future<void> Function() update,
  ) async {
    await update();
    final settings =
        ref.read(settingsControllerProvider).valueOrNull ??
        const UserSettings();
    try {
      await ref
          .read(homeWidgetSyncServiceProvider)
          .sync(tasks: tasks, settings: settings);
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, 'Виджет недоступен на этой платформе');
      }
    }
  }
}

class _HistorySettings extends ConsumerWidget {
  const _HistorySettings({required this.completed});

  final List<Task> completed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsSection(
      children: <Widget>[
        const _SectionTitle(
          icon: Icons.inventory_2_rounded,
          title: 'История выполненных',
        ),
        const SizedBox(height: 8),
        Text(
          completed.isEmpty
              ? 'Архив выполненных задач пуст'
              : 'В архиве задач: ${completed.length}',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            FilledButton.tonalIcon(
              onPressed: () => _showHistory(context, ref, completed),
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Открыть историю'),
            ),
            OutlinedButton.icon(
              onPressed: completed.isEmpty
                  ? null
                  : () => _clearCompleted(context, ref),
              icon: const Icon(Icons.cleaning_services_rounded),
              label: const Text('Очистить'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _clearCompleted(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: 'Очистить историю?',
      message: 'Выполненные и архивные задачи будут удалены безвозвратно.',
    );
    if (!confirmed) {
      return;
    }
    await ref.read(tasksControllerProvider.notifier).clearCompleted();
    if (context.mounted) {
      _showSnack(context, 'История очищена');
    }
  }

  void _showHistory(BuildContext context, WidgetRef ref, List<Task> tasks) {
    QDoneModalPresenter.showSheet<void>(
      context: context,
      builder: (context) => _CompletedTasksSheet(tasks: tasks),
    );
  }
}

class _KnowledgeBaseSettings extends StatelessWidget {
  const _KnowledgeBaseSettings();

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      children: <Widget>[
        const _SectionTitle(
          icon: Icons.menu_book_rounded,
          title: 'Библиотека знаний',
        ),
        const SizedBox(height: 8),
        const Text(
          'Краткие объяснения значков и состояний QDone, чтобы быстрее разобраться в интерфейсе.',
        ),
        const SizedBox(height: 10),
        FilledButton.tonalIcon(
          onPressed: () => _openKnowledgeBase(context),
          icon: const Icon(Icons.auto_stories_rounded),
          label: const Text('Открыть справочник'),
        ),
      ],
    );
  }

  void _openKnowledgeBase(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => const _KnowledgeBasePage(),
      ),
    );
  }
}

class _KnowledgeBasePage extends StatelessWidget {
  const _KnowledgeBasePage();

  static const _groups = <_KnowledgeGroup>[
    _KnowledgeGroup(
      title: 'Навигация',
      items: <_KnowledgeItem>[
        _KnowledgeItem(
          Icons.calendar_month_rounded,
          'Календарь',
          'Открывает планирование по дням, точки задач и список задач выбранной даты.',
        ),
        _KnowledgeItem(
          Icons.check_circle_rounded,
          'Задачи',
          'Главный обзор: просроченные, текущие, будущие и выполненные задачи.',
        ),
        _KnowledgeItem(
          Icons.tune_rounded,
          'Меню',
          'Настройки, история, виджет, экспорт данных и справочная информация.',
        ),
      ],
    ),
    _KnowledgeGroup(
      title: 'Состояния задач',
      items: <_KnowledgeItem>[
        _KnowledgeItem(
          Icons.warning_rounded,
          'Просрочено',
          'Задача уже должна была быть выполнена. В календаре отмечается предупреждающей точкой.',
        ),
        _KnowledgeItem(
          Icons.done_rounded,
          'Выполнить',
          'Отмечает задачу как завершенную или переносит повторяющуюся задачу на следующий срок.',
        ),
        _KnowledgeItem(
          Icons.done_all_rounded,
          'Выполнено',
          'Задача находится в истории выполненных и не пропадает из приложения.',
        ),
        _KnowledgeItem(
          Icons.inventory_2_rounded,
          'Архив',
          'Раздел для выполненных и архивных задач с восстановлением и очисткой.',
        ),
      ],
    ),
    _KnowledgeGroup(
      title: 'Действия',
      items: <_KnowledgeItem>[
        _KnowledgeItem(
          Icons.add_rounded,
          'Добавить',
          'Создает задачу на выбранную дату или открывает форму новой задачи.',
        ),
        _KnowledgeItem(
          Icons.edit_rounded,
          'Изменить',
          'Открывает форму редактирования названия, даты, повтора и напоминаний.',
        ),
        _KnowledgeItem(
          Icons.snooze_rounded,
          'Отложить',
          'Переносит задачу на ближайшее удобное время, например на 15 минут или 1 час.',
        ),
        _KnowledgeItem(
          Icons.delete_outline_rounded,
          'Удалить',
          'Удаляет задачу из локального хранилища.',
        ),
        _KnowledgeItem(
          Icons.restore_rounded,
          'Восстановить',
          'Возвращает выполненную задачу обратно в активный список.',
        ),
      ],
    ),
    _KnowledgeGroup(
      title: 'Планирование',
      items: <_KnowledgeItem>[
        _KnowledgeItem(
          Icons.notifications_rounded,
          'Напоминание',
          'Локальное уведомление для задачи. В форме задачи можно выбрать, за сколько минут, часов или дней уведомлять.',
        ),
        _KnowledgeItem(
          Icons.repeat_rounded,
          'Повтор',
          'Ежедневные, еженедельные, месячные и пользовательские повторы, включая интервалы вроде раз в 2 недели или раз в 2 месяца.',
        ),
        _KnowledgeItem(
          Icons.bolt_rounded,
          'Текущие',
          'Задачи на сегодня и ближайшее время, которые еще не просрочены.',
        ),
        _KnowledgeItem(
          Icons.next_plan_rounded,
          'Будущие',
          'Задачи, запланированные после сегодняшнего дня.',
        ),
      ],
    ),
    _KnowledgeGroup(
      title: 'Настройки и данные',
      items: <_KnowledgeItem>[
        _KnowledgeItem(
          Icons.contrast_rounded,
          'Тема',
          'Переключает темную, светлую или системную тему приложения.',
        ),
        _KnowledgeItem(
          Icons.widgets_rounded,
          'Android-виджет',
          'Настраивает прозрачность, количество задач и компактность домашнего виджета.',
        ),
        _KnowledgeItem(
          Icons.import_export_rounded,
          'Экспорт и импорт',
          'Сохраняет задачи и настройки в JSON или восстанавливает их из JSON.',
        ),
        _KnowledgeItem(
          Icons.verified_user_rounded,
          'Разрешение',
          'Запрашивает системный доступ к локальным уведомлениям.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 24;
    return LiquidBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(18, 18, 18, bottomPadding),
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.menu_book_rounded, color: AppColors.cyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Библиотека знаний',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Закрыть',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Значки сгруппированы по смыслу. Цвет и контекст могут меняться, но действие остается тем же.',
              ),
              const SizedBox(height: 16),
              ..._groups.map((group) => _KnowledgeGroupView(group: group)),
            ],
          ),
        ),
      ),
    );
  }
}

class _KnowledgeGroupView extends StatelessWidget {
  const _KnowledgeGroupView({required this.group});

  final _KnowledgeGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            group.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...group.items.map((item) => _KnowledgeTile(item: item)),
        ],
      ),
    );
  }
}

class _KnowledgeTile extends StatelessWidget {
  const _KnowledgeTile({required this.item});

  final _KnowledgeItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.violet.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.violet.withValues(alpha: 0.14)),
        ),
        child: ListTile(
          leading: Icon(item.icon, color: AppColors.neonPurple),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(item.description),
        ),
      ),
    );
  }
}

class _KnowledgeGroup {
  const _KnowledgeGroup({required this.title, required this.items});

  final String title;
  final List<_KnowledgeItem> items;
}

class _KnowledgeItem {
  const _KnowledgeItem(this.icon, this.title, this.description);

  final IconData icon;
  final String title;
  final String description;
}

class _DataManagementSettings extends ConsumerWidget {
  const _DataManagementSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsSection(
      children: <Widget>[
        const _SectionTitle(
          icon: Icons.import_export_rounded,
          title: 'Управление данными',
        ),
        const SizedBox(height: 8),
        const Text(
          'Экспортируйте локальные задачи и настройки или восстановите их из JSON QDone.',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            FilledButton.tonalIcon(
              onPressed: () => _exportData(context, ref),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Экспорт'),
            ),
            OutlinedButton.icon(
              onPressed: () => _importData(context, ref),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Импорт'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final tasks = await ref.read(taskRepositoryProvider).watchAll();
    final settings =
        ref.read(settingsControllerProvider).valueOrNull ??
        const UserSettings();
    final backup = QDoneBackup.encode(tasks: tasks, settings: settings);
    await Clipboard.setData(ClipboardData(text: backup));
    if (context.mounted) {
      _showSnack(context, 'JSON экспортирован в буфер обмена');
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final payload = await QDoneModalPresenter.showAppDialog<QDoneBackupPayload>(
      context: context,
      builder: (context) => const _ImportDialog(),
    );
    if (payload == null || !context.mounted) {
      return;
    }
    final confirmed = await _confirm(
      context,
      title: 'Импортировать данные?',
      message:
          'Текущие задачи и настройки будут заменены данными из импортированного JSON.',
    );
    if (!confirmed) {
      return;
    }
    await ref.read(taskRepositoryProvider).saveAll(payload.tasks);
    await ref
        .read(settingsControllerProvider.notifier)
        .update(payload.settings);
    await ref.read(tasksControllerProvider.notifier).load();
    if (context.mounted) {
      _showSnack(context, 'Данные импортированы');
    }
  }
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel();

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      children: <Widget>[
        const _SectionTitle(
          icon: Icons.info_outline_rounded,
          title: 'О приложении',
        ),
        const SizedBox(height: 8),
        const Text(
          'QDone - умный планировщик с календарем, повторяющимися задачами, напоминаниями, локальной историей и поддержкой Android-виджета.',
        ),
        const SizedBox(height: 14),
        Text(
          'Версия ${AppConstants.appVersion}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Создано ${AppConstants.studioName}',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.turquoise),
        ),
      ],
    );
  }
}

class _CompletedTasksSheet extends ConsumerWidget {
  const _CompletedTasksSheet({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ModalGlassSurface(
      padding: EdgeInsets.fromLTRB(
        16,
        18,
        16,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'История выполненных',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            const Text('Выполненных задач пока нет')
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: tasks.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(task.title),
                    subtitle: Text(
                      task.completedAt == null
                          ? task.status.label
                          : 'Выполнено ${task.completedAt!.day.toString().padLeft(2, '0')}.${task.completedAt!.month.toString().padLeft(2, '0')}',
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: <Widget>[
                        IconButton(
                          tooltip: 'Восстановить',
                          onPressed: () async {
                            await ref
                                .read(tasksControllerProvider.notifier)
                                .restore(task);
                            if (context.mounted) {
                              QDoneModalPresenter.close(context);
                            }
                          },
                          icon: const Icon(Icons.restore_rounded),
                        ),
                        IconButton(
                          tooltip: 'Удалить',
                          onPressed: () async {
                            await ref
                                .read(tasksControllerProvider.notifier)
                                .delete(task);
                            if (context.mounted) {
                              QDoneModalPresenter.close(context);
                            }
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ImportDialog extends StatefulWidget {
  const _ImportDialog();

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Импорт JSON'),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: _controller,
          minLines: 6,
          maxLines: 10,
          decoration: InputDecoration(
            labelText: 'Вставьте JSON QDone',
            errorText: _error,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => QDoneModalPresenter.close(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            try {
              QDoneModalPresenter.close(
                context,
                QDoneBackup.decode(_controller.text),
              );
            } on FormatException catch (error) {
              setState(() => _error = error.message);
            } catch (_) {
              setState(() => _error = 'Не удалось прочитать JSON QDone');
            }
          },
          child: const Text('Импортировать'),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 28,
      opacity: 0.24,
      borderOpacity: 0.18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: AppColors.cyan),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: AppColors.neonPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String title;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            '$title: $value',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Уменьшить',
          onPressed: value <= min ? null : () => onChanged(value - 1),
          icon: const Icon(Icons.remove_rounded),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: 'Увеличить',
          onPressed: value >= max ? null : () => onChanged(value + 1),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

class _ReadonlyChip extends StatelessWidget {
  const _ReadonlyChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.cyan),
      label: Text(label),
    );
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  return await QDoneModalPresenter.showAppDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => QDoneModalPresenter.close(context, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => QDoneModalPresenter.close(context, true),
              child: const Text('Продолжить'),
            ),
          ],
        ),
      ) ??
      false;
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
