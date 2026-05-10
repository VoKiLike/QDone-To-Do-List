import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_to_do_list_app/core/notifications/notification_service.dart';
import 'package:flutter_to_do_list_app/features/settings/data/local_settings_repository.dart';
import 'package:flutter_to_do_list_app/features/settings/data/settings_local_data_source.dart';
import 'package:flutter_to_do_list_app/features/settings/domain/settings_repository.dart';
import 'package:flutter_to_do_list_app/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:flutter_to_do_list_app/features/tasks/data/repositories/local_task_repository.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/services/recurrence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'SharedPreferences must be overridden during bootstrap.',
  ),
);

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return LocalTaskRepository(
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
