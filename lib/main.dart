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
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/services/recurrence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> qdoneWidgetCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (uri?.host != 'done') {
    return;
  }
  final taskId = uri?.queryParameters['taskId'];
  if (taskId == null || taskId.isEmpty) {
    return;
  }

  final preferences = await SharedPreferences.getInstance();
  final taskRepository = LocalTaskRepository(TaskLocalDataSource(preferences));
  final settingsRepository = LocalSettingsRepository(
    SettingsLocalDataSource(preferences),
  );
  final tasks = await taskRepository.watchAll();
  final index = tasks.indexWhere((task) => task.id == taskId);
  if (index == -1) {
    return;
  }

  final task = tasks[index];
  final nextOccurrence = const RecurrenceService().nextOccurrenceAfter(
    task: task,
    after: task.dueDateTime,
  );
  if (nextOccurrence != null) {
    await taskRepository.upsert(
      task.copyWith(
        dueDate: DateTime(
          nextOccurrence.year,
          nextOccurrence.month,
          nextOccurrence.day,
        ),
        dueTime: TimeOfDay(
          hour: nextOccurrence.hour,
          minute: nextOccurrence.minute,
        ),
        status: TaskStatus.active,
        clearCompletedAt: true,
        notificationIds: const <int>[],
      ),
    );
  } else {
    await taskRepository.upsert(
      task.copyWith(status: TaskStatus.completed, completedAt: DateTime.now()),
    );
  }
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
