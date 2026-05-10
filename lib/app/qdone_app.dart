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

class QDoneApp extends ConsumerWidget {
  const QDoneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
