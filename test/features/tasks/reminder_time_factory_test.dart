import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/tasks/domain/services/reminder_time_factory.dart';

void main() {
  test('creates default reminder before task due time', () {
    final reminders = buildDefaultReminderTimes(
      dueDateTime: DateTime(2026, 5, 10, 20),
      enabled: true,
      defaultReminderMinutes: 30,
      now: DateTime(2026, 5, 10, 10),
    );

    expect(reminders, <DateTime>[DateTime(2026, 5, 10, 19, 30)]);
  });

  test('falls back to due time when preferred reminder is already past', () {
    final reminders = buildDefaultReminderTimes(
      dueDateTime: DateTime(2026, 5, 10, 20),
      enabled: true,
      defaultReminderMinutes: 60,
      now: DateTime(2026, 5, 10, 19, 30),
    );

    expect(reminders, <DateTime>[DateTime(2026, 5, 10, 20)]);
  });

  test('does not create reminders when notifications are disabled', () {
    final reminders = buildDefaultReminderTimes(
      dueDateTime: DateTime(2026, 5, 10, 20),
      enabled: false,
      defaultReminderMinutes: 15,
      now: DateTime(2026, 5, 10, 10),
    );

    expect(reminders, isEmpty);
  });
}
