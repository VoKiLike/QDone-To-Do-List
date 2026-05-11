import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:qdone/app/app_providers.dart';
import 'package:qdone/app/qdone_app.dart';
import 'package:qdone/core/notifications/notification_service.dart';
import 'package:qdone/features/home_widget/data/home_widget_sync_service.dart';
import 'package:qdone/features/settings/data/local_settings_repository.dart';
import 'package:qdone/features/settings/data/settings_local_data_source.dart';
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
  final taskRepository = LocalTaskRepository(TaskLocalDataSource(preferences));
  final settingsRepository = LocalSettingsRepository(
    SettingsLocalDataSource(preferences),
  );
  final notificationService = NotificationService(
    FlutterLocalNotificationsPlugin(),
  );
  await notificationService.initialize();
  await TaskMutationService(
    repository: taskRepository,
    notificationService: notificationService,
    settingsRepository: settingsRepository,
  ).toggleFromWidget(taskId);
  await const HomeWidgetSyncService().sync(
    tasks: await taskRepository.watchAll(),
    settings: await settingsRepository.read(),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final notificationService = NotificationService(
    FlutterLocalNotificationsPlugin(),
  );
  await notificationService.initialize();
  await HomeWidget.registerInteractivityCallback(qdoneWidgetCallback);

  runApp(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(preferences),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const QDoneApp(),
    ),
  );
}
