import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qdone/core/notifications/notification_scheduler.dart';
import 'package:qdone/core/notifications/notification_service.dart';
import 'package:qdone/features/settings/data/local_settings_repository.dart';
import 'package:qdone/features/settings/data/settings_local_data_source.dart';
import 'package:qdone/features/tasks/data/database/qdone_database.dart';
import 'package:qdone/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:qdone/features/tasks/data/repositories/local_task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String qdoneNotificationWorkerName =
    'qdone.notification_schedule.reconcile';
const String qdoneNotificationWorkerUniqueName =
    'qdone.notification_schedule.periodic';

@pragma('vm:entry-point')
void qdoneNotificationCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != qdoneNotificationWorkerName) {
      return true;
    }
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    final preferences = await SharedPreferences.getInstance();
    final database = QDoneDatabase.defaults();
    try {
      final taskRepository = LocalTaskRepository(
        database,
        TaskLocalDataSource(preferences),
      );
      final scheduler = NotificationScheduler(
        notificationService: NotificationService(
          FlutterLocalNotificationsPlugin(),
        ),
        taskRepository: taskRepository,
        settingsRepository: LocalSettingsRepository(
          SettingsLocalDataSource(preferences),
        ),
        database: database,
      );
      await scheduler.reconcile();
      return true;
    } catch (_) {
      return false;
    } finally {
      await database.close();
    }
  });
}

class NotificationBackgroundWorker {
  const NotificationBackgroundWorker();

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> initialize() async {
    if (!isSupported) {
      return;
    }
    await Workmanager().initialize(qdoneNotificationCallbackDispatcher);
  }

  Future<void> configure({required bool enabled}) async {
    if (!isSupported) {
      return;
    }
    if (!enabled) {
      await Workmanager().cancelByUniqueName(qdoneNotificationWorkerUniqueName);
      return;
    }
    await Workmanager().registerPeriodicTask(
      qdoneNotificationWorkerUniqueName,
      qdoneNotificationWorkerName,
      frequency: const Duration(hours: 12),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  }
}
