import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdone/app/app_providers.dart';
import 'package:qdone/core/constants/app_constants.dart';
import 'package:qdone/core/localization/qdone_localizations.dart';
import 'package:qdone/core/notifications/notification_scheduler.dart';
import 'package:qdone/core/notifications/notification_service.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/theme/qdone_theme_tokens.dart';
import 'package:qdone/core/widgets/glass_panel.dart';
import 'package:qdone/core/widgets/liquid_background.dart';
import 'package:qdone/core/widgets/modal_glass_surface.dart';
import 'package:qdone/core/widgets/neon_controls.dart';
import 'package:qdone/core/widgets/qdone_brand_text.dart';
import 'package:qdone/core/widgets/qdone_modal_presenter.dart';
import 'package:qdone/core/widgets/qdone_tap_feedback.dart';
import 'package:qdone/features/settings/data/backup_file_service.dart';
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
    final feed = ref.watch(tasksControllerProvider).valueOrNull;
    final completed =
        ref.watch(completedTasksPageProvider).valueOrNull ?? const <Task>[];
    final completedCount = feed?.counts.completed ?? completed.length;

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
          _StartupScreenSettings(
            settings: settings,
            completedCount: completedCount,
          ),
          const SizedBox(height: 14),
          _NotificationSettings(settings: settings),
          const SizedBox(height: 14),
          _CalendarSettings(settings: settings),
          const SizedBox(height: 14),
          _WidgetSettings(settings: settings),
          const SizedBox(height: 14),
          const _KnowledgeBaseSettings(),
          const SizedBox(height: 14),
          _HistorySettings(
            completed: completed,
            completedCount: completedCount,
          ),
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
    const paletteModes = <AppThemeMode>[
      AppThemeMode.dark,
      AppThemeMode.light,
      AppThemeMode.indigo,
      AppThemeMode.turquoise,
    ];
    final controller = ref.read(settingsControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(icon: Icons.contrast_rounded, title: 'Тема'),
        const SizedBox(height: 4),
        Text(
          'Выберите палитру интерфейса',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.subdued(context)),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (var index = 0; index < paletteModes.length; index++) ...[
              if (index > 0) const SizedBox(width: 8),
              Expanded(
                child: _ThemePaletteCard(
                  mode: paletteModes[index],
                  tokens: _tokensForThemeMode(paletteModes[index]),
                  selected: settings.themeMode == paletteModes[index],
                  onTap: () => controller.setThemeMode(paletteModes[index]),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        _SystemThemeCard(
          selected: settings.themeMode == AppThemeMode.system,
          onTap: () => controller.setThemeMode(AppThemeMode.system),
        ),
      ],
    );
  }
}

class _ThemePaletteCard extends StatelessWidget {
  const _ThemePaletteCard({
    required this.mode,
    required this.tokens,
    required this.selected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final QDoneThemeTokens tokens;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Semantics(
      button: true,
      selected: selected,
      label: 'Тема ${mode.label}',
      child: QDoneTapFeedback(
        onTap: onTap,
        borderRadius: radius,
        builder: (context, tapped) {
          final border = selected
              ? tokens.primary
              : tapped
              ? AppColors.primaryFor(context)
              : AppColors.line(context);
          return AnimatedScale(
            scale: tapped ? 0.97 : 1,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: Column(
              children: <Widget>[
                AnimatedContainer(
                  height: 76,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    gradient: tokens.backgroundGradient,
                    borderRadius: radius,
                    border: Border.all(
                      color: border,
                      width: selected ? 2 : 1.1,
                    ),
                    boxShadow: selected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: tokens.primary.withValues(alpha: 0.24),
                              blurRadius: 14,
                              offset: const Offset(0, 7),
                            ),
                          ]
                        : const <BoxShadow>[],
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 9,
                        right: 9,
                        top: 11,
                        child: Container(
                          height: 9,
                          decoration: BoxDecoration(
                            color: tokens.elevatedSurface,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 9,
                        right: 22,
                        top: 28,
                        child: Container(
                          height: 22,
                          decoration: BoxDecoration(
                            color: tokens.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tokens.line.withValues(alpha: 0.82),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 7,
                        bottom: 7,
                        child: AnimatedContainer(
                          width: 20,
                          height: 20,
                          duration: const Duration(milliseconds: 160),
                          decoration: BoxDecoration(
                            color: selected
                                ? tokens.primary
                                : tokens.elevatedSurface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? tokens.primary : tokens.line,
                            ),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: selected
                                ? tokens.accentForeground
                                : tokens.subdued,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mode.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected
                        ? AppColors.foreground(context)
                        : AppColors.subdued(context),
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SystemThemeCard extends StatelessWidget {
  const _SystemThemeCard({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    final accent = AppColors.primaryFor(context);
    return QDoneTapFeedback(
      onTap: onTap,
      borderRadius: radius,
      builder: (context, tapped) {
        final border = selected || tapped ? accent : AppColors.line(context);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.elevatedSurface(context),
            borderRadius: radius,
            border: Border.all(color: border, width: selected ? 1.8 : 1.1),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFFE7EDF2),
                      Color(0xFFE7EDF2),
                      Color(0xFF10182B),
                      Color(0xFF10182B),
                    ],
                    stops: <double>[0, 0.49, 0.51, 1],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line(context)),
                ),
                child: Icon(
                  Icons.brightness_auto_rounded,
                  color: selected ? accent : AppColors.foreground(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppThemeMode.system.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Следует настройке устройства',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.subdued(context),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                width: 24,
                height: 24,
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  color: selected ? accent : AppColors.mutedSurface(context),
                  shape: BoxShape.circle,
                  border: Border.all(color: border),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: selected
                      ? AppColors.accentForegroundFor(context)
                      : AppColors.subdued(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

QDoneThemeTokens _tokensForThemeMode(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.light => QDoneThemeTokens.light,
    AppThemeMode.indigo => QDoneThemeTokens.indigo,
    AppThemeMode.turquoise => QDoneThemeTokens.turquoise,
    AppThemeMode.dark || AppThemeMode.system => QDoneThemeTokens.graphite,
  };
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

class _StartupScreenSettings extends ConsumerWidget {
  const _StartupScreenSettings({
    required this.settings,
    required this.completedCount,
  });

  final UserSettings settings;
  final int completedCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPath = settings.selectedStartupBackgroundPath;
    final hasCustom =
        settings.startupUseCustomBackground && selectedPath != null;
    return _SettingsSection(
      children: <Widget>[
        const _SectionTitle(
          icon: Icons.auto_awesome_motion_rounded,
          title: 'Экран запуска',
        ),
        const SizedBox(height: 8),
        QDoneBrandRichText(
          'Атмосферная подготовка QDONE: цитаты, факты и спокойный вход в задачи без полос загрузки.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.subdued(context)),
        ),
        const SizedBox(height: 12),
        _StartupPreview(
          path: hasCustom ? selectedPath : null,
          completedCount: completedCount,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            NeonActionButton(
              onPressed: () => _pickBackground(context, ref),
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: const Text('Выбрать фон'),
            ),
            NeonActionButton(
              onPressed: hasCustom
                  ? () => ref
                        .read(settingsControllerProvider.notifier)
                        .resetStartupBackground()
                  : null,
              icon: const Icon(Icons.wallpaper_rounded),
              style: NeonControlStyle.quiet,
              label: const Text('Стандартный фон'),
            ),
            NeonActionButton(
              onPressed: hasCustom
                  ? () => _removeBackground(context, ref, selectedPath)
                  : null,
              icon: const Icon(Icons.delete_outline_rounded),
              style: NeonControlStyle.danger,
              label: const Text('Удалить фон'),
            ),
          ],
        ),
        if (settings.startupBackgroundPaths.length > 1) ...<Widget>[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: settings.startupBackgroundPaths
                .take(6)
                .map(
                  (path) => _QDoneOptionChip(
                    selected: path == selectedPath && hasCustom,
                    icon: Icons.image_rounded,
                    label: Text(
                      'Фон ${settings.startupBackgroundPaths.indexOf(path) + 1}',
                    ),
                    onSelected: (_) => ref
                        .read(settingsControllerProvider.notifier)
                        .selectStartupBackground(path),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Future<void> _pickBackground(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .addStartupBackground();
      if (context.mounted) {
        _showSnack(context, 'Фон экрана запуска обновлён');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, 'Не удалось выбрать изображение');
      }
    }
  }

  Future<void> _removeBackground(
    BuildContext context,
    WidgetRef ref,
    String path,
  ) async {
    await ref
        .read(settingsControllerProvider.notifier)
        .removeStartupBackground(path);
    if (context.mounted) {
      _showSnack(context, 'Фон удалён');
    }
  }
}

class _StartupPreview extends StatelessWidget {
  const _StartupPreview({required this.path, required this.completedCount});

  final String? path;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final hasImage = path != null;
    final useDarkText = isLight && !hasImage;
    final previewForeground = useDarkText
        ? AppColors.lightText
        : AppColors.white;
    final previewMuted = useDarkText
        ? AppColors.lightMuted
        : AppColors.white.withValues(alpha: 0.78);
    final badgeFill = useDarkText
        ? AppColors.lightElevatedSurface
        : AppColors.white.withValues(alpha: 0.18);
    final badgeBorder = useDarkText
        ? AppColors.lightLine
        : AppColors.white.withValues(alpha: 0.24);
    final cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .clamp(540, 1080)
            .round();
    return SizedBox(
      width: double.infinity,
      height: 112,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.backgroundGradientFor(context),
              ),
            ),
            if (hasImage)
              Image.file(
                File(path!),
                fit: BoxFit.cover,
                cacheWidth: cacheWidth,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: hasImage
                    ? Colors.black.withValues(alpha: 0.38)
                    : useDarkText
                    ? AppColors.lightSurface.withValues(alpha: 0.22)
                    : Colors.transparent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: badgeFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: badgeBorder),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: previewForeground,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Один ясный шаг сильнее длинного списка.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: previewForeground,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Выполнено задач: $completedCount',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: previewMuted,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            return _QDoneOptionChip(
              selected: settings.defaultReminderMinutes == minutes,
              label: Text(minutes == 0 ? 'В срок' : 'За $minutes мин'),
              onSelected: (_) => ref
                  .read(settingsControllerProvider.notifier)
                  .setDefaultReminderMinutes(minutes),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        NeonActionButton(
          onPressed: () => _requestPermission(context, ref),
          icon: const Icon(Icons.verified_user_rounded),
          label: const Text('Запросить разрешение'),
        ),
        const SizedBox(height: 10),
        const _NotificationDiagnostics(),
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
      await ref
          .read(notificationBackgroundWorkerProvider)
          .configure(enabled: allowed);
      if (allowed) {
        await ref.read(notificationSchedulerProvider).reconcile();
      }
      if (!context.mounted) {
        return;
      }
      _showSnack(
        context,
        allowed ? 'Уведомления включены' : 'Разрешение не выдано',
      );
      return;
    }
    await ref.read(tasksControllerProvider.notifier).cancelAllNotifications();
    await ref
        .read(notificationBackgroundWorkerProvider)
        .configure(enabled: false);
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
    await ref
        .read(notificationBackgroundWorkerProvider)
        .configure(enabled: allowed);
    if (allowed) {
      await ref.read(notificationSchedulerProvider).reconcile();
    }
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      allowed ? 'Разрешение на уведомления получено' : 'Разрешение не выдано',
    );
  }
}

class _NotificationDiagnostics extends ConsumerStatefulWidget {
  const _NotificationDiagnostics();

  @override
  ConsumerState<_NotificationDiagnostics> createState() =>
      _NotificationDiagnosticsState();
}

class _NotificationDiagnosticsState
    extends ConsumerState<_NotificationDiagnostics> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_NotificationDiagnosticsData>(
      future: _load(ref),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final capability = data?.capability;
        final scheduler = data?.scheduler;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryFor(context).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primaryFor(context).withValues(alpha: 0.28),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DiagnosticLine(
                  icon: Icons.notifications_rounded,
                  label: 'Системные уведомления',
                  value: _permissionLabel(capability?.notificationsEnabled),
                ),
                const SizedBox(height: 6),
                _DiagnosticLine(
                  icon: Icons.alarm_on_rounded,
                  label: 'Точные будильники Android',
                  value: _permissionLabel(capability?.exactAlarmsEnabled),
                ),
                const SizedBox(height: 6),
                _DiagnosticLine(
                  icon: Icons.schedule_rounded,
                  label: 'Запланировано',
                  value: scheduler == null
                      ? 'проверяем'
                      : '${scheduler.scheduledCount}/'
                            '${scheduler.maxScheduledCount}',
                ),
                const SizedBox(height: 6),
                _DiagnosticLine(
                  icon: Icons.sync_rounded,
                  label: 'Последняя синхронизация',
                  value: _formatSyncTime(scheduler?.lastSyncedAt),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    NeonActionButton(
                      onPressed: () => _repair(context, ref),
                      icon: const Icon(Icons.settings_backup_restore_rounded),
                      label: const Text('Восстановить расписание'),
                    ),
                    if (capability?.exactAlarmsEnabled == false)
                      NeonActionButton(
                        onPressed: () => _requestExact(context, ref),
                        icon: const Icon(Icons.alarm_add_rounded),
                        style: NeonControlStyle.quiet,
                        label: const Text('Разрешить точные'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<_NotificationDiagnosticsData> _load(WidgetRef ref) async {
    return _NotificationDiagnosticsData(
      capability: await ref
          .read(notificationServiceProvider)
          .capabilityStatus(),
      scheduler: await ref.read(notificationSchedulerProvider).status(),
    );
  }

  Future<void> _repair(BuildContext context, WidgetRef ref) async {
    final status = await ref
        .read(notificationSchedulerProvider)
        .reconcile(forceReset: true);
    if (mounted) {
      setState(() {});
    }
    if (context.mounted) {
      _showSnack(
        context,
        'Расписание восстановлено: ${status.scheduledCount}/'
        '${status.maxScheduledCount}',
      );
    }
  }

  Future<void> _requestExact(BuildContext context, WidgetRef ref) async {
    final allowed = await ref
        .read(notificationServiceProvider)
        .requestExactAlarmPermission();
    if (allowed) {
      await ref.read(notificationSchedulerProvider).reconcile();
    }
    if (mounted) {
      setState(() {});
    }
    if (context.mounted) {
      _showSnack(
        context,
        allowed
            ? 'Точные уведомления разрешены'
            : 'Будет использован неточный безопасный режим',
      );
    }
  }

  String _permissionLabel(bool? value) {
    if (value == null) {
      return 'проверяем';
    }
    return value ? 'доступно' : 'требует разрешения';
  }

  String _formatSyncTime(DateTime? value) {
    if (value == null) {
      return 'ещё не запускалась';
    }
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

class _NotificationDiagnosticsData {
  const _NotificationDiagnosticsData({
    required this.capability,
    required this.scheduler,
  });

  final NotificationCapabilityStatus capability;
  final NotificationSchedulerStatus scheduler;
}

class _DiagnosticLine extends StatelessWidget {
  const _DiagnosticLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.primaryFor(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.subdued(context),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
  const _WidgetSettings({required this.settings});

  final UserSettings settings;

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
          onChanged: (value) => _updateWidgetSetting(context, ref, () async {
            await controller.setWidgetTaskLimit(value);
          }),
        ),
        const SizedBox(height: 14),
        _SwitchRow(
          icon: Icons.inventory_2_rounded,
          title: 'Показывать выполненные',
          subtitle: 'Добавлять архивные задачи в список виджета',
          value: settings.widgetShowsCompleted,
          onChanged: (value) => _updateWidgetSetting(context, ref, () async {
            await controller.setWidgetShowsCompleted(value);
          }),
        ),
        _SwitchRow(
          icon: Icons.compress_rounded,
          title: 'Компактный режим',
          subtitle: 'Меньше воздуха, больше задач на экране',
          value: settings.compactWidget,
          onChanged: (value) => _updateWidgetSetting(context, ref, () async {
            await controller.setCompactWidget(value);
          }),
        ),
        const SizedBox(height: 8),
        NeonActionButton(
          onPressed: () => _syncWidget(context, ref),
          icon: const Icon(Icons.sync_rounded),
          label: const Text('Обновить виджет'),
        ),
      ],
    );
  }

  Future<void> _syncWidget(BuildContext context, WidgetRef ref) async {
    try {
      final tasks = await ref
          .read(taskRepositoryProvider)
          .readForDay(DateTime.now());
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
    Future<void> Function() update,
  ) async {
    await update();
    final settings =
        ref.read(settingsControllerProvider).valueOrNull ??
        const UserSettings();
    try {
      final tasks = await ref
          .read(taskRepositoryProvider)
          .readForDay(DateTime.now());
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
  const _HistorySettings({
    required this.completed,
    required this.completedCount,
  });

  final List<Task> completed;
  final int completedCount;

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
          completedCount == 0
              ? 'Архив выполненных задач пуст'
              : 'В архиве задач: $completedCount '
                    '(показаны последние ${completed.length})',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            NeonActionButton(
              onPressed: () => _showHistory(context, ref, completed),
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Открыть историю'),
            ),
            NeonActionButton(
              onPressed: completedCount == 0
                  ? null
                  : () => _clearCompleted(context, ref),
              icon: const Icon(Icons.cleaning_services_rounded),
              style: NeonControlStyle.danger,
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
        const QDoneBrandRichText(
          'Краткие объяснения значков и состояний QDONE, чтобы быстрее разобраться в интерфейсе.',
        ),
        const SizedBox(height: 10),
        NeonActionButton(
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
          'Сохраняет задачи и настройки в JSON-файл или буфер обмена, а также восстанавливает данные из выбранного файла или вставленного JSON.',
        ),
        _KnowledgeItem(
          Icons.verified_user_rounded,
          'Разрешение',
          'Запрашивает системный доступ к локальным уведомлениям.',
        ),
      ],
    ),
    _KnowledgeGroup(
      title: 'Android и Huawei',
      items: <_KnowledgeItem>[
        _KnowledgeItem(
          Icons.battery_saver_rounded,
          'Huawei Pura 70',
          'Если напоминания приходят нестабильно, проверьте автозапуск QDONE и работу в фоне в настройках батареи Huawei. Это системное ограничение Android/HarmonyOS, а не отдельная настройка внутри приложения.',
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
                  Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primaryFor(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Библиотека знаний',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  QDoneMaterialTapFeedback(
                    onTap: () => Navigator.pop(context),
                    semanticLabel: 'Закрыть',
                    borderRadius: BorderRadius.circular(24),
                    child: IconButton(
                      tooltip: 'Закрыть',
                      onPressed: () {},
                      icon: const Icon(Icons.close_rounded),
                    ),
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
          color: AppColors.secondaryFor(context).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.secondaryFor(context).withValues(alpha: 0.24),
          ),
        ),
        child: ListTile(
          leading: Icon(item.icon, color: AppColors.secondaryFor(context)),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: QDoneBrandRichText(item.description),
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
        const QDoneBrandRichText(
          'Экспортируйте локальные задачи и настройки или восстановите их '
          'из JSON QDONE. Поддерживаются backup v1, v2 и старый массив задач.',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            NeonActionButton(
              onPressed: () => _exportData(context, ref),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Экспорт'),
            ),
            NeonActionButton(
              onPressed: () => _importData(context, ref),
              icon: const Icon(Icons.download_rounded),
              style: NeonControlStyle.quiet,
              label: const Text('Импорт'),
            ),
          ],
        ),
      ],
    );
  }

  Future<String> _buildBackup(WidgetRef ref) async {
    final tasks = await ref.read(taskRepositoryProvider).readAll();
    final settings =
        ref.read(settingsControllerProvider).valueOrNull ??
        const UserSettings();
    return QDoneBackup.encode(tasks: tasks, settings: settings);
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final backup = await _buildBackup(ref);
    if (!context.mounted) {
      return;
    }
    final action = await QDoneModalPresenter.showAppDialog<_ExportAction>(
      context: context,
      builder: (context) => _ExportDialog(backup: backup),
    );
    if (action == null || !context.mounted) {
      return;
    }
    switch (action) {
      case _ExportAction.copy:
        await Clipboard.setData(ClipboardData(text: backup));
        if (context.mounted) {
          _showSnack(context, 'JSON экспортирован в буфер обмена');
        }
        break;
      case _ExportAction.file:
        await _saveBackupFile(context, ref, backup);
        break;
    }
  }

  Future<void> _saveBackupFile(
    BuildContext context,
    WidgetRef ref,
    String backup,
  ) async {
    try {
      final savedFile = await ref
          .read(backupFileServiceProvider)
          .exportBackupJson(backup);
      if (!context.mounted) {
        return;
      }
      _showSnack(context, 'Файл экспорта сохранён: $savedFile');
    } catch (error) {
      if (context.mounted) {
        _showSnack(context, 'Не удалось сохранить файл: $error');
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final result = await QDoneModalPresenter.showAppDialog<_ImportResult>(
      context: context,
      builder: (context) =>
          _ImportDialog(fileService: ref.read(backupFileServiceProvider)),
    );
    if (result == null || !context.mounted) {
      return;
    }
    await _applyImport(context, ref, result.payload, source: result.source);
  }

  Future<void> _applyImport(
    BuildContext context,
    WidgetRef ref,
    QDoneBackupPayload payload, {
    required String source,
  }) async {
    final confirmed = await _confirm(
      context,
      title: 'Импортировать данные?',
      message: 'Текущие задачи и настройки будут заменены данными из $source.',
    );
    if (!confirmed) {
      return;
    }
    final repository = ref.read(taskRepositoryProvider);
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final previousTasks = await repository.readAll();
    final previousSettings =
        ref.read(settingsControllerProvider).valueOrNull ??
        const UserSettings();
    final importedSettings = payload.includesSettings
        ? payload.settings
        : previousSettings;
    final importedTasks = payload.tasks;

    try {
      await ref.read(tasksControllerProvider.notifier).cancelAllNotifications();
      await repository.saveAll(importedTasks);
      final verifiedTasks = await repository.readAll();
      final expectedIds = importedTasks.map((task) => task.id).toSet();
      final actualIds = verifiedTasks.map((task) => task.id).toSet();
      if (verifiedTasks.length != importedTasks.length ||
          expectedIds.length != actualIds.length ||
          !actualIds.containsAll(expectedIds)) {
        throw StateError(
          'Проверка импорта не пройдена: '
          '${verifiedTasks.length}/${importedTasks.length}.',
        );
      }
      await settingsController.update(importedSettings);
      await ref
          .read(notificationBackgroundWorkerProvider)
          .configure(enabled: importedSettings.notificationsEnabled);
      await ref.read(notificationSchedulerProvider).reconcile(forceReset: true);
      await ref.read(tasksControllerProvider.notifier).load();
      await _syncWidgetAfterImport(ref, importedSettings);
      if (context.mounted) {
        _showSnack(
          context,
          'Импортировано задач: ${importedTasks.length}. '
          'Расписание уведомлений восстановлено.',
        );
      }
    } catch (error) {
      await repository.saveAll(previousTasks);
      await settingsController.update(previousSettings);
      await ref
          .read(notificationBackgroundWorkerProvider)
          .configure(enabled: previousSettings.notificationsEnabled);
      await ref.read(notificationSchedulerProvider).reconcile(forceReset: true);
      await ref.read(tasksControllerProvider.notifier).load();
      if (context.mounted) {
        _showSnack(context, 'Импорт отменён, исходные данные восстановлены.');
      }
    }
  }

  Future<void> _syncWidgetAfterImport(
    WidgetRef ref,
    UserSettings settings,
  ) async {
    try {
      final tasks = await ref
          .read(taskRepositoryProvider)
          .readForDay(DateTime.now());
      await ref
          .read(homeWidgetSyncServiceProvider)
          .sync(tasks: tasks, settings: settings);
    } catch (_) {
      // Import is valid even on platforms without an Android home widget.
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
        const QDoneBrandRichText(
          'QDONE - умный планировщик с календарем, повторяющимися задачами, напоминаниями, локальной историей и поддержкой Android-виджета.',
        ),
        const SizedBox(height: 14),
        Text(
          'Версия ${AppConstants.appVersion}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Создано ${AppConstants.studioName}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.primaryFor(context),
          ),
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
                        QDoneMaterialTapFeedback(
                          onTap: () async {
                            await ref
                                .read(tasksControllerProvider.notifier)
                                .restore(task);
                            if (context.mounted) {
                              QDoneModalPresenter.close(context);
                            }
                          },
                          semanticLabel: 'Восстановить',
                          borderRadius: BorderRadius.circular(24),
                          child: IconButton(
                            tooltip: 'Восстановить',
                            onPressed: () {},
                            icon: const Icon(Icons.restore_rounded),
                          ),
                        ),
                        QDoneMaterialTapFeedback(
                          onTap: () async {
                            await ref
                                .read(tasksControllerProvider.notifier)
                                .delete(task);
                            if (context.mounted) {
                              QDoneModalPresenter.close(context);
                            }
                          },
                          semanticLabel: 'Удалить',
                          borderRadius: BorderRadius.circular(24),
                          child: IconButton(
                            tooltip: 'Удалить',
                            onPressed: () {},
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
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

enum _ExportAction { copy, file }

class _ImportResult {
  const _ImportResult({required this.payload, required this.source});

  final QDoneBackupPayload payload;
  final String source;
}

class _ExportDialog extends StatefulWidget {
  const _ExportDialog({required this.backup});

  final String backup;

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.backup);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Экспорт JSON'),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: _controller,
          readOnly: true,
          minLines: 6,
          maxLines: 10,
          decoration: const InputDecoration(
            label: QDoneBrandRichText('JSON QDONE'),
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: <Widget>[
        QDoneMaterialTapFeedback(
          onTap: () => QDoneModalPresenter.close(context),
          semanticLabel: 'Отмена',
          child: TextButton(onPressed: () {}, child: const Text('Отмена')),
        ),
        QDoneMaterialTapFeedback(
          onTap: () => QDoneModalPresenter.close(context, _ExportAction.file),
          semanticLabel: 'Сохранить файл',
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save_alt_rounded),
            label: const Text('Сохранить файл'),
          ),
        ),
        QDoneMaterialTapFeedback(
          onTap: () => QDoneModalPresenter.close(context, _ExportAction.copy),
          semanticLabel: 'Копировать',
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Копировать'),
          ),
        ),
      ],
    );
  }
}

class _ImportDialog extends StatefulWidget {
  const _ImportDialog({required this.fileService});

  final BackupFileService fileService;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _isPickingFile = false;

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
            label: const QDoneBrandRichText('Вставьте JSON QDONE'),
            errorText: _error,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      actions: <Widget>[
        QDoneMaterialTapFeedback(
          onTap: () => QDoneModalPresenter.close(context),
          semanticLabel: 'Отмена',
          child: TextButton(onPressed: () {}, child: const Text('Отмена')),
        ),
        QDoneMaterialTapFeedback(
          onTap: _isPickingFile ? null : _pickFile,
          semanticLabel: _isPickingFile ? 'Открываем файл' : 'Выбрать файл',
          child: TextButton.icon(
            onPressed: _isPickingFile ? null : () {},
            icon: const Icon(Icons.file_open_rounded),
            label: Text(_isPickingFile ? 'Открываем...' : 'Выбрать файл'),
          ),
        ),
        QDoneMaterialTapFeedback(
          onTap: _isPickingFile ? null : _pickLatestLocalExport,
          semanticLabel: 'Последний экспорт',
          child: TextButton.icon(
            onPressed: _isPickingFile ? null : () {},
            icon: const Icon(Icons.history_rounded),
            label: const Text('Последний экспорт'),
          ),
        ),
        QDoneMaterialTapFeedback(
          onTap: () {
            try {
              QDoneModalPresenter.close(
                context,
                _ImportResult(
                  payload: QDoneBackup.decode(_controller.text),
                  source: 'вставленного JSON',
                ),
              );
            } on FormatException catch (error) {
              setState(() => _error = error.message);
            } catch (_) {
              setState(() => _error = 'Не удалось прочитать файл');
            }
          },
          semanticLabel: 'Импортировать',
          child: FilledButton(
            onPressed: () {},
            child: const Text('Импортировать'),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    if (!widget.fileService.supportsSystemFileDialogs) {
      setState(() => _error = 'Файловый импорт доступен на Android');
      return;
    }
    setState(() {
      _isPickingFile = true;
      _error = null;
    });
    try {
      final raw = await widget.fileService.pickBackupJson();
      if (!mounted) {
        return;
      }
      if (raw == null || raw.trim().isEmpty) {
        setState(() => _error = 'Выбор файла отменён');
        return;
      }
      QDoneModalPresenter.close(
        context,
        _ImportResult(
          payload: QDoneBackup.decode(raw),
          source: 'выбранного файла',
        ),
      );
    } on FormatException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error =
              'Системный выбор файла недоступен: $error. '
              'Можно вставить JSON вручную или выбрать последний экспорт.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  Future<void> _pickLatestLocalExport() async {
    setState(() {
      _isPickingFile = true;
      _error = null;
    });
    try {
      final raw = await widget.fileService.readLatestLocalBackupJson();
      if (!mounted) {
        return;
      }
      if (raw == null || raw.trim().isEmpty) {
        setState(() => _error = 'Локальных файлов экспорта пока нет');
        return;
      }
      QDoneModalPresenter.close(
        context,
        _ImportResult(
          payload: QDoneBackup.decode(raw),
          source: 'последнего локального экспорта',
        ),
      );
    } on FormatException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = 'Не удалось прочитать последний экспорт: $error',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
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
        Icon(icon, color: AppColors.primaryFor(context)),
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
    return NeonSwitchTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
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
        NeonIconButton(
          tooltip: 'Уменьшить',
          onPressed: value <= min ? null : () => onChanged(value - 1),
          icon: const Icon(Icons.remove_rounded),
        ),
        const SizedBox(width: 8),
        NeonIconButton(
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
    return _QDoneOptionChip(selected: false, icon: icon, label: Text(label));
  }
}

class _QDoneOptionChip extends StatelessWidget {
  const _QDoneOptionChip({
    required this.selected,
    required this.label,
    this.icon,
    this.onSelected,
  });

  final bool selected;
  final Widget label;
  final IconData? icon;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final enabled = onSelected != null;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = AppColors.primaryFor(context);
    final secondary = AppColors.secondaryFor(context);
    final radius = BorderRadius.circular(16);
    final baseFill = selected ? secondary : AppColors.elevatedSurface(context);
    final baseBorder = selected
        ? secondary.withValues(alpha: isLight ? 0.72 : 0.42)
        : AppColors.line(context).withValues(alpha: isLight ? 1 : 0.50);
    final foreground = selected
        ? Theme.of(context).colorScheme.onSecondary
        : enabled
        ? AppColors.foreground(context)
        : AppColors.subdued(context).withValues(alpha: isLight ? 0.78 : 0.60);
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: foreground,
      fontWeight: FontWeight.w900,
      letterSpacing: 0,
    );

    return QDoneTapFeedback(
      onTap: enabled ? () => onSelected?.call(!selected) : null,
      borderRadius: radius,
      builder: (context, tapped) {
        final fill = tapped
            ? Color.alphaBlend(
                primary.withValues(alpha: isLight ? 0.20 : 0.26),
                baseFill,
              )
            : baseFill;
        final border = tapped ? primary : baseBorder;
        return AnimatedScale(
          scale: tapped && enabled ? 0.98 : 1,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: radius,
              border: Border.all(color: border, width: 1.05),
              boxShadow: selected || tapped
                  ? <BoxShadow>[
                      BoxShadow(
                        color: (tapped ? primary : secondary).withValues(
                          alpha: tapped
                              ? isLight
                                    ? 0.20
                                    : 0.28
                              : isLight
                              ? 0.18
                              : 0.22,
                        ),
                        blurRadius: tapped ? 22 : 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            child: DefaultTextStyle.merge(
              style: labelStyle,
              child: IconTheme.merge(
                data: IconThemeData(color: foreground, size: 18),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (selected) ...<Widget>[
                      const Icon(Icons.check_rounded, size: 18),
                      const SizedBox(width: 7),
                    ] else if (icon != null) ...<Widget>[
                      Icon(icon, size: 18),
                      const SizedBox(width: 7),
                    ],
                    Flexible(child: label),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
            QDoneMaterialTapFeedback(
              onTap: () => QDoneModalPresenter.close(context, false),
              semanticLabel: 'Отмена',
              child: TextButton(onPressed: () {}, child: const Text('Отмена')),
            ),
            QDoneMaterialTapFeedback(
              onTap: () => QDoneModalPresenter.close(context, true),
              semanticLabel: 'Продолжить',
              child: FilledButton(
                onPressed: () {},
                child: const Text('Продолжить'),
              ),
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
