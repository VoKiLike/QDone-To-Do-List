import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._plugin);

  static const String taskChannelId = 'qdone_tasks_v2';
  static final Int64List _taskVibrationPattern = Int64List.fromList(<int>[
    0,
    120,
    80,
    180,
  ]);

  static final AndroidNotificationChannel taskChannel =
      AndroidNotificationChannel(
        taskChannelId,
        'Задачи QDONE',
        description: 'Напоминания о задачах, повторах и умном откладывании.',
        importance: Importance.high,
        enableVibration: true,
        vibrationPattern: _taskVibrationPattern,
      );

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialization;
  bool _initialized = false;

  Future<void> ensureInitialized() {
    if (_initialized) {
      return Future<void>.value();
    }
    final pending = _initialization;
    if (pending != null) {
      return pending;
    }
    final initialization = _initialize().catchError((Object error) {
      _initialization = null;
      throw error;
    });
    _initialization = initialization;
    return initialization;
  }

  Future<void> _initialize() async {
    timezone_data.initializeTimeZones();
    await _configureLocalTimeZone();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(taskChannel);
    _initialized = true;
    _initialization = null;
  }

  Future<bool> requestPermissions() async {
    await ensureInitialized();
    final android = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return android ?? ios ?? true;
  }

  Future<bool> requestExactAlarmPermission() async {
    await ensureInitialized();
    final plugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (plugin == null) {
      return true;
    }
    await plugin.requestExactAlarmsPermission();
    return await plugin.canScheduleExactNotifications() ?? false;
  }

  Future<NotificationCapabilityStatus> capabilityStatus() async {
    await ensureInitialized();
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return NotificationCapabilityStatus(
      notificationsEnabled:
          await androidPlugin?.areNotificationsEnabled() ?? true,
      exactAlarmsEnabled:
          await androidPlugin?.canScheduleExactNotifications() ?? true,
    );
  }

  Future<List<PendingNotificationRequest>> pendingRequests() async {
    await ensureInitialized();
    return _plugin.pendingNotificationRequests();
  }

  Future<void> schedule(NotificationDelivery delivery) async {
    await ensureInitialized();
    await _plugin.zonedSchedule(
      delivery.id,
      delivery.title,
      delivery.body,
      tz.TZDateTime.from(delivery.scheduledAt, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          taskChannelId,
          'Задачи QDONE',
          channelDescription:
              'Напоминания о задачах, повторах и умном откладывании.',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          enableVibration: true,
          vibrationPattern: _taskVibrationPattern,
          visibility: NotificationVisibility.public,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: delivery.androidScheduleMode,
      payload: delivery.payload,
    );
  }

  Future<void> cancel(int notificationId) async {
    await ensureInitialized();
    await _plugin.cancel(notificationId);
  }

  Future<void> cancelAllPendingNotifications() async {
    await ensureInitialized();
    await _plugin.cancelAllPendingNotifications();
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }
}

class NotificationDelivery {
  const NotificationDelivery({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.payload,
    required this.androidScheduleMode,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String payload;
  final AndroidScheduleMode androidScheduleMode;
}

class NotificationCapabilityStatus {
  const NotificationCapabilityStatus({
    required this.notificationsEnabled,
    required this.exactAlarmsEnabled,
  });

  final bool notificationsEnabled;
  final bool exactAlarmsEnabled;
}
