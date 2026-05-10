List<DateTime> buildDefaultReminderTimes({
  required DateTime dueDateTime,
  required bool enabled,
  required int defaultReminderMinutes,
  DateTime? now,
}) {
  if (!enabled) {
    return const <DateTime>[];
  }
  final reference = now ?? DateTime.now();
  final offset = Duration(minutes: defaultReminderMinutes.clamp(0, 1440));
  final preferred = dueDateTime.subtract(offset);
  if (!preferred.isBefore(reference)) {
    return <DateTime>[preferred];
  }
  if (!dueDateTime.isBefore(reference)) {
    return <DateTime>[dueDateTime];
  }
  return const <DateTime>[];
}
