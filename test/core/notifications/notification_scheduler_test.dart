import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/core/notifications/notification_scheduler.dart';
import 'package:qdone/core/notifications/notification_service.dart';
import 'package:qdone/features/settings/domain/settings_repository.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/tasks/data/database/qdone_database.dart';
import 'package:qdone/features/tasks/domain/entities/reminder.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/repositories/task_repository.dart';

void main() {
  late QDoneDatabase database;
  late _FakeNotificationService notifications;
  late _MemoryTaskRepository tasks;
  late _MemorySettingsRepository settings;

  setUp(() {
    database = QDoneDatabase(NativeDatabase.memory());
    notifications = _FakeNotificationService();
    tasks = _MemoryTaskRepository();
    settings = _MemorySettingsRepository();
  });

  tearDown(() async {
    await database.close();
  });

  NotificationScheduler scheduler() {
    return NotificationScheduler(
      notificationService: notifications,
      taskRepository: tasks,
      settingsRepository: settings,
      database: database,
    );
  }

  test('clears legacy alarms and never schedules more than 48', () async {
    notifications.pending.addAll(
      List<PendingNotificationRequest>.generate(
        500,
        (index) =>
            PendingNotificationRequest(index + 1, 'legacy', null, 'legacy'),
      ),
    );
    tasks.tasks = List<Task>.generate(100, _futureTask);

    final status = await scheduler().reconcile();

    expect(notifications.cancelAllCalls, 1);
    expect(notifications.deliveries, hasLength(48));
    expect(notifications.pending, hasLength(48));
    expect(status.scheduledCount, 48);
    expect(await database.notificationSchedule(), hasLength(48));
  });

  test('reconciliation is idempotent', () async {
    tasks.tasks = List<Task>.generate(10, _futureTask);
    final coordinator = scheduler();

    await coordinator.reconcile();
    final firstScheduleCalls = notifications.scheduleCalls;
    await coordinator.reconcile();

    expect(notifications.scheduleCalls, firstScheduleCalls);
    expect(notifications.cancelCalls, 0);
    expect(await database.notificationSchedule(), hasLength(10));
  });

  test('edited task cancels a legacy pending alarm with old payload', () async {
    await database.setMetadata(
      NotificationScheduler.resetMetadataKey,
      'complete',
    );
    notifications.pending.add(
      const PendingNotificationRequest(
        777,
        'Принять лекарство',
        null,
        'seed-medicine',
      ),
    );
    tasks.tasks = <Task>[
      _futureTask(0).copyWith(
        title: 'Моё лекарство',
        reminders: <Reminder>[
          Reminder(
            id: 'my-reminder',
            taskId: 'task-0',
            dateTime: DateTime.now().add(const Duration(hours: 3)),
          ),
        ],
      ),
    ];

    await scheduler().reconcile();

    expect(notifications.cancelledIds, contains(777));
    expect(
      notifications.pending.where((request) => request.id == 777),
      isEmpty,
    );
    expect(notifications.pending, hasLength(1));
  });

  test('keeps at most four events for one task', () async {
    final task = _futureTask(0);
    final base = task.reminders.single.dateTime;
    tasks.tasks = <Task>[
      task.copyWith(
        reminders: List<Reminder>.generate(
          10,
          (index) => Reminder(
            id: 'reminder-$index',
            taskId: task.id,
            dateTime: base.add(Duration(minutes: index)),
          ),
        ),
      ),
    ];

    final status = await scheduler().reconcile();

    expect(status.scheduledCount, 4);
    expect(notifications.deliveries, hasLength(4));
  });

  test('high priority uses exact only when permission is available', () async {
    tasks.tasks = <Task>[
      _futureTask(0, priority: TaskPriority.high),
      _futureTask(1, priority: TaskPriority.medium),
    ];
    notifications.exactAlarmsEnabled = true;

    await scheduler().reconcile();

    expect(
      notifications.deliveries.first.androidScheduleMode,
      AndroidScheduleMode.exactAllowWhileIdle,
    );
    expect(
      notifications.deliveries.last.androidScheduleMode,
      AndroidScheduleMode.inexactAllowWhileIdle,
    );

    await database.setMetadata(NotificationScheduler.resetMetadataKey, '');
    notifications
      ..deliveries.clear()
      ..exactAlarmsEnabled = false;
    await scheduler().reconcile(forceReset: true);

    expect(
      notifications.deliveries
          .map((delivery) => delivery.androidScheduleMode)
          .toSet(),
      <AndroidScheduleMode>{AndroidScheduleMode.inexactAllowWhileIdle},
    );
  });

  test('archive removes the previously scheduled alarm', () async {
    tasks.tasks = <Task>[_futureTask(0)];
    final coordinator = scheduler();
    await coordinator.reconcile();
    final originalId = notifications.pending.single.id;

    tasks.tasks = <Task>[
      _futureTask(0).copyWith(status: TaskStatus.archived, isArchived: true),
    ];
    await coordinator.reconcile();

    expect(notifications.cancelledIds, contains(originalId));
    expect(notifications.pending, isEmpty);
    expect(await database.notificationSchedule(), isEmpty);
  });

  test('disabled notifications clear alarms and registry', () async {
    tasks.tasks = <Task>[_futureTask(0)];
    final coordinator = scheduler();
    await coordinator.reconcile();
    settings.value = const UserSettings(notificationsEnabled: false);

    final status = await coordinator.reconcile();

    expect(notifications.cancelAllCalls, 2);
    expect(notifications.pending, isEmpty);
    expect(await database.notificationSchedule(), isEmpty);
    expect(status.scheduledCount, 0);
  });
}

Task _futureTask(int index, {TaskPriority priority = TaskPriority.medium}) {
  final due = DateTime.now().add(Duration(hours: index + 2));
  return Task(
    id: 'task-$index',
    title: 'Task $index',
    createdAt: DateTime.now(),
    dueDate: DateTime(due.year, due.month, due.day),
    dueTime: TimeOfDay(hour: due.hour, minute: due.minute),
    priority: priority,
    category: const TaskCategory(
      id: 'personal',
      name: 'Личное',
      colorValue: 0xFF8B5CF6,
    ),
    reminders: <Reminder>[
      Reminder(id: 'reminder-$index', taskId: 'task-$index', dateTime: due),
    ],
  );
}

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService() : super(FlutterLocalNotificationsPlugin());

  final List<PendingNotificationRequest> pending =
      <PendingNotificationRequest>[];
  final List<NotificationDelivery> deliveries = <NotificationDelivery>[];
  final List<int> cancelledIds = <int>[];
  bool exactAlarmsEnabled = true;
  bool notificationsEnabled = true;
  int cancelAllCalls = 0;
  int cancelCalls = 0;
  int scheduleCalls = 0;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<NotificationCapabilityStatus> capabilityStatus() async {
    return NotificationCapabilityStatus(
      notificationsEnabled: notificationsEnabled,
      exactAlarmsEnabled: exactAlarmsEnabled,
    );
  }

  @override
  Future<List<PendingNotificationRequest>> pendingRequests() async {
    return List<PendingNotificationRequest>.of(pending);
  }

  @override
  Future<void> schedule(NotificationDelivery delivery) async {
    scheduleCalls++;
    deliveries.add(delivery);
    pending.removeWhere((request) => request.id == delivery.id);
    pending.add(
      PendingNotificationRequest(
        delivery.id,
        delivery.title,
        delivery.body,
        delivery.payload,
      ),
    );
  }

  @override
  Future<void> cancel(int notificationId) async {
    cancelCalls++;
    cancelledIds.add(notificationId);
    pending.removeWhere((request) => request.id == notificationId);
  }

  @override
  Future<void> cancelAllPendingNotifications() async {
    cancelAllCalls++;
    pending.clear();
  }
}

class _MemorySettingsRepository implements SettingsRepository {
  UserSettings value = const UserSettings();

  @override
  Future<UserSettings> read() async => value;

  @override
  Future<void> reloadExternal() async {}

  @override
  Future<void> save(UserSettings settings) async {
    value = settings;
  }
}

class _MemoryTaskRepository implements TaskRepository {
  List<Task> tasks = <Task>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<List<Task>> readNotificationCandidates(
    DateTime from,
    DateTime to,
  ) async => List<Task>.of(tasks);

  @override
  Future<Task?> getById(String taskId) async => null;

  @override
  Future<List<Task>> readAll() async => List<Task>.of(tasks);

  @override
  Future<TaskCounts> readCounts() async => const TaskCounts();

  @override
  Future<TaskDailySummary> readDailySummary() async => const TaskDailySummary();

  @override
  Future<TaskPage> readSectionPage(
    TaskSectionKind section, {
    TaskPageCursor? cursor,
    int limit = TaskRepository.defaultPageSize,
  }) async => const TaskPage(tasks: <Task>[]);

  @override
  Future<List<Task>> readForDay(DateTime day) async => const <Task>[];

  @override
  Future<List<Task>> readForRange(DateTime from, DateTime to) async =>
      const <Task>[];

  @override
  Future<List<Task>> readCompletedPage({
    int limit = 50,
    int offset = 0,
  }) async => const <Task>[];

  @override
  Future<void> saveAll(List<Task> tasks) async {
    this.tasks = List<Task>.of(tasks);
  }

  @override
  Future<void> upsert(Task task) async {}

  @override
  Future<void> delete(String taskId) async {}

  @override
  Future<void> clearCompleted() async {}

  @override
  Future<void> reloadExternal() async {}
}
