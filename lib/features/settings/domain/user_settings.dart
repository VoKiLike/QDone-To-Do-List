import 'package:qdone/features/tasks/domain/entities/task_enums.dart';

class UserSettings {
  const UserSettings({
    this.themeMode = AppThemeMode.dark,
    this.languageCode = 'ru',
    this.notificationsEnabled = true,
    this.defaultReminderMinutes = 15,
    this.defaultCategoryId = 'personal',
    this.calendarShowCompleted = true,
    this.calendarShowOverdue = true,
    this.calendarShowRecurring = true,
    this.widgetTransparency = 0.62,
    this.widgetShowsCompleted = false,
    this.widgetTaskLimit = 5,
    this.compactWidget = false,
  });

  final AppThemeMode themeMode;
  final String languageCode;
  final bool notificationsEnabled;
  final int defaultReminderMinutes;
  final String defaultCategoryId;
  final bool calendarShowCompleted;
  final bool calendarShowOverdue;
  final bool calendarShowRecurring;
  final double widgetTransparency;
  final bool widgetShowsCompleted;
  final int widgetTaskLimit;
  final bool compactWidget;

  UserSettings copyWith({
    AppThemeMode? themeMode,
    String? languageCode,
    bool? notificationsEnabled,
    int? defaultReminderMinutes,
    String? defaultCategoryId,
    bool? calendarShowCompleted,
    bool? calendarShowOverdue,
    bool? calendarShowRecurring,
    double? widgetTransparency,
    bool? widgetShowsCompleted,
    int? widgetTaskLimit,
    bool? compactWidget,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderMinutes:
          defaultReminderMinutes ?? this.defaultReminderMinutes,
      defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
      calendarShowCompleted:
          calendarShowCompleted ?? this.calendarShowCompleted,
      calendarShowOverdue: calendarShowOverdue ?? this.calendarShowOverdue,
      calendarShowRecurring:
          calendarShowRecurring ?? this.calendarShowRecurring,
      widgetTransparency: widgetTransparency ?? this.widgetTransparency,
      widgetShowsCompleted: widgetShowsCompleted ?? this.widgetShowsCompleted,
      widgetTaskLimit: widgetTaskLimit ?? this.widgetTaskLimit,
      compactWidget: compactWidget ?? this.compactWidget,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'themeMode': themeMode.name,
    'languageCode': languageCode,
    'notificationsEnabled': notificationsEnabled,
    'defaultReminderMinutes': defaultReminderMinutes,
    'defaultCategoryId': defaultCategoryId,
    'calendarShowCompleted': calendarShowCompleted,
    'calendarShowOverdue': calendarShowOverdue,
    'calendarShowRecurring': calendarShowRecurring,
    'widgetTransparency': widgetTransparency,
    'widgetShowsCompleted': widgetShowsCompleted,
    'widgetTaskLimit': widgetTaskLimit,
    'compactWidget': compactWidget,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      themeMode: AppThemeMode.values.byName(
        json['themeMode'] as String? ?? AppThemeMode.dark.name,
      ),
      languageCode: 'ru',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      defaultReminderMinutes: json['defaultReminderMinutes'] as int? ?? 15,
      defaultCategoryId: json['defaultCategoryId'] as String? ?? 'personal',
      calendarShowCompleted: json['calendarShowCompleted'] as bool? ?? true,
      calendarShowOverdue: json['calendarShowOverdue'] as bool? ?? true,
      calendarShowRecurring: json['calendarShowRecurring'] as bool? ?? true,
      widgetTransparency:
          (json['widgetTransparency'] as num?)?.toDouble() ?? 0.62,
      widgetShowsCompleted: json['widgetShowsCompleted'] as bool? ?? false,
      widgetTaskLimit: json['widgetTaskLimit'] as int? ?? 5,
      compactWidget: json['compactWidget'] as bool? ?? false,
    );
  }
}
