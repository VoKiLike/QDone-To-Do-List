import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_to_do_list_app/core/constants/app_constants.dart';
import 'package:flutter_to_do_list_app/core/localization/qdone_localizations.dart';
import 'package:flutter_to_do_list_app/core/theme/app_colors.dart';
import 'package:flutter_to_do_list_app/core/widgets/glass_panel.dart';
import 'package:flutter_to_do_list_app/features/settings/domain/user_settings.dart';
import 'package:flutter_to_do_list_app/features/settings/presentation/controllers/settings_controller.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task_enums.dart';
import 'package:flutter_to_do_list_app/features/tasks/presentation/controllers/tasks_controller.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = QDoneLocalizations.of(context);
    final settings =
        ref.watch(settingsControllerProvider).valueOrNull ??
        const UserSettings();
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
          const SizedBox(height: 4),
          Text(
            AppConstants.studioName,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.turquoise),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            borderRadius: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ThemeSelector(settings: settings),
                const Divider(height: 28),
                const _LanguageInfo(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _MenuGroup(
            children: <Widget>[
              const _MenuTile(
                icon: Icons.notifications_active_rounded,
                title: 'Настройки уведомлений',
                subtitle: 'Разрешения, каналы и напоминания по умолчанию',
              ),
              const _MenuTile(
                icon: Icons.calendar_month_rounded,
                title: 'Настройки календаря',
                subtitle: 'Начало недели, индикаторы и выбранный день',
              ),
              const _MenuTile(
                icon: Icons.widgets_rounded,
                title: 'Настройки виджета',
                subtitle: 'Прозрачность, количество задач и компактный режим',
              ),
              _MenuTile(
                icon: Icons.inventory_2_rounded,
                title: 'История выполненных задач',
                subtitle: 'Просмотр, восстановление или очистка архива',
                trailing: TextButton(
                  onPressed: () => ref
                      .read(tasksControllerProvider.notifier)
                      .clearCompleted(),
                  child: const Text('Очистить'),
                ),
              ),
              const _MenuTile(
                icon: Icons.import_export_rounded,
                title: 'Управление данными',
                subtitle: 'Основа для экспорта и импорта локальных данных',
              ),
            ],
          ),
          const SizedBox(height: 14),
          GlassPanel(
            borderRadius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'О приложении',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
                  strings.text('createdBy'),
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: AppColors.turquoise),
                ),
              ],
            ),
          ),
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
        Chip(label: Text('Русский')),
      ],
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

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 28,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.violet.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: AppColors.neonPurple),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
    );
  }
}
