import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_to_do_list_app/app/app_router.dart';
import 'package:flutter_to_do_list_app/core/constants/app_constants.dart';
import 'package:flutter_to_do_list_app/core/localization/qdone_localizations.dart';
import 'package:flutter_to_do_list_app/core/theme/app_theme.dart';
import 'package:flutter_to_do_list_app/features/settings/presentation/controllers/settings_controller.dart';

class QDoneApp extends ConsumerWidget {
  const QDoneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsControllerProvider);
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
}
