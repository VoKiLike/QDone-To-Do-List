class NotificationSchedule {
  const NotificationSchedule({
    required this.id,
    required this.taskId,
    required this.scheduledAt,
    required this.notificationId,
    this.channelId = 'qdone_tasks',
  });

  final String id;
  final String taskId;
  final DateTime scheduledAt;
  final int notificationId;
  final String channelId;
}
