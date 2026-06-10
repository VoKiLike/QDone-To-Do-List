import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdone/app/app_providers.dart';
import 'package:qdone/app/app_router.dart';
import 'package:qdone/core/constants/app_constants.dart';
import 'package:qdone/core/localization/qdone_localizations.dart';
import 'package:qdone/core/theme/app_theme.dart';
import 'package:qdone/features/home_widget/data/home_widget_sync_service.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/settings/presentation/controllers/settings_controller.dart';
import 'package:qdone/features/startup/presentation/qdone_startup_gate.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/presentation/controllers/tasks_controller.dart';

class QDoneApp extends ConsumerStatefulWidget {
  const QDoneApp({super.key});

  @override
  ConsumerState<QDoneApp> createState() => _QDoneAppState();
}

class _QDoneAppState extends ConsumerState<QDoneApp>
    with WidgetsBindingObserver {
  DateTime? _lastExternalReloadAt;
  String? _lastHomeWidgetFingerprint;
  bool _homeWidgetSyncQueued = false;
  bool _startupReleased = false;
  bool _homeWidgetSyncPending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref
            .read(settingsControllerProvider.notifier)
            .recoverLostStartupBackground()
            .catchError((_) {}),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_reloadExternalState());
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(settingsControllerProvider).valueOrNull ??
        const UserSettings();
    ref.listen(settingsControllerProvider, (_, _) => _syncHomeWidget(ref));
    ref.listen(tasksControllerProvider, (_, _) => _syncHomeWidget(ref));
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: switch (settings.themeMode) {
        AppThemeMode.indigo => AppTheme.indigo(),
        AppThemeMode.turquoise => AppTheme.turquoise(),
        _ => AppTheme.dark(),
      },
      themeMode: ref.watch(effectiveThemeModeProvider),
      locale: const Locale('ru'),
      supportedLocales: QDoneLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        QDoneLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routerConfig: appRouter,
      builder: (context, child) {
        return QDoneStartupGate(
          onReleased: _handleStartupReleased,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  void _handleStartupReleased() {
    if (_startupReleased) {
      return;
    }
    _startupReleased = true;
    ref.read(tasksControllerProvider.notifier).scheduleNotificationRefresh();
    if (_homeWidgetSyncPending) {
      _homeWidgetSyncPending = false;
      _syncHomeWidget(ref);
    }
  }

  Future<void> _reloadExternalState() async {
    final now = DateTime.now();
    final lastReload = _lastExternalReloadAt;
    if (lastReload != null && now.difference(lastReload).inSeconds < 2) {
      return;
    }
    _lastExternalReloadAt = now;
    await ref.read(settingsControllerProvider.notifier).reloadExternal();
    await ref.read(tasksControllerProvider.notifier).reloadExternal();
  }

  void _syncHomeWidget(WidgetRef ref) {
    if (!_startupReleased) {
      _homeWidgetSyncPending = true;
      return;
    }
    if (_homeWidgetSyncQueued) {
      _homeWidgetSyncPending = true;
      return;
    }
    final settings = ref.read(settingsControllerProvider).valueOrNull;
    if (settings == null) {
      return;
    }
    _homeWidgetSyncQueued = true;
    _trace('home widget sync');
    unawaited(_performHomeWidgetSync(ref, settings));
  }

  Future<void> _performHomeWidgetSync(
    WidgetRef ref,
    UserSettings settings,
  ) async {
    try {
      final tasks = await ref
          .read(taskRepositoryProvider)
          .readForDay(DateTime.now());
      final fingerprint = _homeWidgetFingerprint(tasks, settings);
      if (fingerprint != _lastHomeWidgetFingerprint) {
        _lastHomeWidgetFingerprint = fingerprint;
        await ref
            .read(homeWidgetSyncServiceProvider)
            .sync(tasks: tasks, settings: settings);
      }
    } catch (_) {
      // Home-screen widgets are not available on every supported platform.
    } finally {
      _homeWidgetSyncQueued = false;
      if (_homeWidgetSyncPending) {
        _homeWidgetSyncPending = false;
        _syncHomeWidget(ref);
      }
    }
  }

  String _homeWidgetFingerprint(List<Task> tasks, UserSettings settings) {
    final payload = const HomeWidgetSyncService().buildWidgetPayload(
      tasks: tasks,
      settings: settings,
    );
    final taskPart = payload.tasks
        .map(
          (task) =>
              '${task.id}:${task.title}:${task.time}:${task.category}:'
              '${task.status}:${task.priority}:${task.isCompleted}:'
              '${task.canToggle}',
        )
        .join('|');
    return '${settings.widgetTaskLimit}:${settings.widgetShowsCompleted}:'
        '${settings.widgetTransparency}:${settings.compactWidget}:'
        '${settings.themeMode.name}:$taskPart';
  }
}

void _trace(String name) {
  if (kDebugMode || kProfileMode) {
    developer.Timeline.instantSync('qdone.$name');
  }
}
