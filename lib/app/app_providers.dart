import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdone/core/notifications/notification_service.dart';
import 'package:qdone/core/notifications/notification_scheduler.dart';
import 'package:qdone/core/notifications/notification_background_worker.dart';
import 'package:qdone/features/settings/data/backup_file_service.dart';
import 'package:qdone/features/settings/data/local_settings_repository.dart';
import 'package:qdone/features/settings/data/settings_local_data_source.dart';
import 'package:qdone/features/settings/data/startup_background_repository.dart';
import 'package:qdone/features/settings/domain/settings_repository.dart';
import 'package:qdone/features/home_widget/data/home_widget_sync_service.dart';
import 'package:qdone/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:qdone/features/tasks/data/database/qdone_database.dart';
import 'package:qdone/features/tasks/data/repositories/local_task_repository.dart';
import 'package:qdone/features/tasks/domain/repositories/task_repository.dart';
import 'package:qdone/features/tasks/domain/services/recurrence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'SharedPreferences must be overridden during bootstrap.',
  ),
);

final qdoneDatabaseProvider = Provider<QDoneDatabase>((ref) {
  final database = QDoneDatabase.defaults();
  ref.onDispose(database.close);
  return database;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return LocalTaskRepository(
    ref.watch(qdoneDatabaseProvider),
    TaskLocalDataSource(ref.watch(sharedPreferencesProvider)),
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return LocalSettingsRepository(
    SettingsLocalDataSource(ref.watch(sharedPreferencesProvider)),
  );
});

final recurrenceServiceProvider = Provider<RecurrenceService>(
  (ref) => const RecurrenceService(),
);

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FlutterLocalNotificationsPlugin());
});

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler(
    notificationService: ref.watch(notificationServiceProvider),
    taskRepository: ref.watch(taskRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    database: ref.watch(qdoneDatabaseProvider),
  );
});

final notificationBackgroundWorkerProvider =
    Provider<NotificationBackgroundWorker>((ref) {
      return const NotificationBackgroundWorker();
    });

final homeWidgetSyncServiceProvider = Provider<HomeWidgetSyncService>((ref) {
  return const HomeWidgetSyncService();
});

final startupBackgroundRepositoryProvider =
    Provider<StartupBackgroundRepository>((ref) {
      return StartupBackgroundRepository();
    });

final backupFileServiceProvider = Provider<BackupFileService>((ref) {
  return const BackupFileService();
});
