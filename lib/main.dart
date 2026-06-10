import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:qdone/app/app_providers.dart';
import 'package:qdone/app/qdone_app.dart';
import 'package:qdone/core/notifications/notification_background_worker.dart';
import 'package:qdone/core/notifications/notification_scheduler.dart';
import 'package:qdone/core/notifications/notification_service.dart';
import 'package:qdone/features/home_widget/data/home_widget_sync_service.dart';
import 'package:qdone/features/settings/data/local_settings_repository.dart';
import 'package:qdone/features/settings/data/settings_local_data_source.dart';
import 'package:qdone/features/tasks/data/database/qdone_database.dart';
import 'package:qdone/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:qdone/features/tasks/data/repositories/local_task_repository.dart';
import 'package:qdone/features/tasks/domain/services/task_mutation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> qdoneWidgetCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (uri?.host != 'toggle') {
    return;
  }
  final taskId = uri?.pathSegments.isNotEmpty == true
      ? uri!.pathSegments.first
      : uri?.queryParameters['taskId'];
  if (taskId == null || taskId.isEmpty) {
    return;
  }

  final preferences = await SharedPreferences.getInstance();
  final database = QDoneDatabase.defaults();
  final taskRepository = LocalTaskRepository(
    database,
    TaskLocalDataSource(preferences),
  );
  final settingsRepository = LocalSettingsRepository(
    SettingsLocalDataSource(preferences),
  );
  final notificationService = NotificationService(
    FlutterLocalNotificationsPlugin(),
  );
  try {
    final scheduler = NotificationScheduler(
      notificationService: notificationService,
      taskRepository: taskRepository,
      settingsRepository: settingsRepository,
      database: database,
    );
    await TaskMutationService(
      repository: taskRepository,
      notificationScheduler: scheduler,
    ).toggleFromWidget(taskId);
    await const HomeWidgetSyncService().sync(
      tasks: await taskRepository.readForDay(DateTime.now()),
      settings: await settingsRepository.read(),
    );
  } finally {
    await database.close();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const <String>[
      'Orbitron',
    ], await rootBundle.loadString('assets/fonts/OFL-Orbitron.txt'));
  });
  final preferences = await SharedPreferences.getInstance();
  final notificationService = NotificationService(
    FlutterLocalNotificationsPlugin(),
  );
  const notificationWorker = NotificationBackgroundWorker();
  await notificationWorker.initialize();
  final settings = await LocalSettingsRepository(
    SettingsLocalDataSource(preferences),
  ).read();
  await notificationWorker.configure(enabled: settings.notificationsEnabled);

  runApp(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(preferences),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const QDoneApp(),
    ),
  );

  unawaited(
    HomeWidget.registerInteractivityCallback(qdoneWidgetCallback)
        .then((_) => _trace('home widget callback registered'))
        .catchError((_) => false),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _trace('first frame');
    Timer(const Duration(seconds: 2), () {
      unawaited(notificationService.ensureInitialized().catchError((_) {}));
    });
  });
}

void _trace(String name) {
  if (kDebugMode || kProfileMode) {
    developer.Timeline.instantSync('qdone.$name');
  }
}
