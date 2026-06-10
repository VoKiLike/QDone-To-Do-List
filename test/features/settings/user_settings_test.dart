import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';

void main() {
  test('serializes new interactive settings fields', () {
    const settings = UserSettings(
      themeMode: AppThemeMode.system,
      notificationsEnabled: false,
      defaultReminderMinutes: 30,
      calendarShowCompleted: false,
      calendarShowOverdue: false,
      calendarShowRecurring: false,
      widgetTransparency: 0.7,
      widgetShowsCompleted: true,
      widgetTaskLimit: 7,
      compactWidget: true,
      startupBackgroundPaths: <String>['/tmp/a.jpg', '/tmp/b.jpg'],
      selectedStartupBackgroundPath: '/tmp/b.jpg',
      startupUseCustomBackground: true,
    );

    final restored = UserSettings.fromJson(settings.toJson());

    expect(restored.themeMode, AppThemeMode.system);
    expect(restored.notificationsEnabled, isFalse);
    expect(restored.defaultReminderMinutes, 30);
    expect(restored.calendarShowCompleted, isFalse);
    expect(restored.calendarShowOverdue, isFalse);
    expect(restored.calendarShowRecurring, isFalse);
    expect(restored.widgetTransparency, 0.7);
    expect(restored.widgetShowsCompleted, isTrue);
    expect(restored.widgetTaskLimit, 7);
    expect(restored.compactWidget, isTrue);
    expect(restored.startupBackgroundPaths, <String>[
      '/tmp/a.jpg',
      '/tmp/b.jpg',
    ]);
    expect(restored.selectedStartupBackgroundPath, '/tmp/b.jpg');
    expect(restored.startupUseCustomBackground, isTrue);
  });

  test('keeps backward compatibility for old settings payloads', () {
    final restored = UserSettings.fromJson(<String, dynamic>{
      'themeMode': 'dark',
      'languageCode': 'en',
      'defaultReminderMinutes': 15,
    });

    expect(restored.languageCode, 'ru');
    expect(restored.notificationsEnabled, isTrue);
    expect(restored.calendarShowCompleted, isTrue);
    expect(restored.calendarShowOverdue, isTrue);
    expect(restored.calendarShowRecurring, isTrue);
    expect(restored.widgetTaskLimit, 5);
    expect(restored.startupBackgroundPaths, isEmpty);
    expect(restored.selectedStartupBackgroundPath, isNull);
    expect(restored.startupUseCustomBackground, isFalse);
  });

  test('serializes additional palette modes', () {
    for (final mode in const <AppThemeMode>[
      AppThemeMode.indigo,
      AppThemeMode.turquoise,
    ]) {
      final restored = UserSettings.fromJson(
        UserSettings(themeMode: mode).toJson(),
      );
      expect(restored.themeMode, mode);
    }
  });
}
