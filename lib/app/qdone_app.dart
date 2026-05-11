import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdone/app/app_router.dart';
import 'package:qdone/app/app_providers.dart';
import 'package:qdone/core/constants/app_constants.dart';
import 'package:qdone/core/localization/qdone_localizations.dart';
import 'package:qdone/core/theme/app_theme.dart';
import 'package:qdone/features/settings/presentation/controllers/settings_controller.dart';
import 'package:qdone/features/tasks/presentation/controllers/tasks_controller.dart';

class QDoneApp extends ConsumerStatefulWidget {
  const QDoneApp({super.key});

  @override
  ConsumerState<QDoneApp> createState() => _QDoneAppState();
}

class _QDoneAppState extends ConsumerState<QDoneApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reloadExternalState();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsControllerProvider);
    ref.listen(settingsControllerProvider, (_, _) => _syncHomeWidget(ref));
    ref.listen(tasksControllerProvider, (_, _) => _syncHomeWidget(ref));
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
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
    );
  }

  Future<void> _reloadExternalState() async {
    await ref.read(sharedPreferencesProvider).reload();
    await ref.read(settingsControllerProvider.notifier).load();
    await ref.read(tasksControllerProvider.notifier).load();
  }

  void _syncHomeWidget(WidgetRef ref) {
    final tasks = ref.read(tasksControllerProvider).valueOrNull;
    final settings = ref.read(settingsControllerProvider).valueOrNull;
    if (tasks == null || settings == null) {
      return;
    }
    ref
        .read(homeWidgetSyncServiceProvider)
        .sync(tasks: tasks, settings: settings)
        .catchError((_) {});
  }
}
