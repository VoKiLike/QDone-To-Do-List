import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task_enums.dart';

class UserSettings {
  const UserSettings({
    this.themeMode = AppThemeMode.dark,
    this.languageCode = 'ru',
    this.defaultReminderMinutes = 15,
    this.defaultCategoryId = 'personal',
    this.widgetTransparency = 0.62,
    this.widgetShowsCompleted = false,
    this.widgetTaskLimit = 5,
    this.compactWidget = false,
  });

  final AppThemeMode themeMode;
  final String languageCode;
  final int defaultReminderMinutes;
  final String defaultCategoryId;
  final double widgetTransparency;
  final bool widgetShowsCompleted;
  final int widgetTaskLimit;
  final bool compactWidget;

  UserSettings copyWith({
    AppThemeMode? themeMode,
    String? languageCode,
    int? defaultReminderMinutes,
    String? defaultCategoryId,
    double? widgetTransparency,
    bool? widgetShowsCompleted,
    int? widgetTaskLimit,
    bool? compactWidget,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      defaultReminderMinutes:
          defaultReminderMinutes ?? this.defaultReminderMinutes,
      defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
      widgetTransparency: widgetTransparency ?? this.widgetTransparency,
      widgetShowsCompleted: widgetShowsCompleted ?? this.widgetShowsCompleted,
      widgetTaskLimit: widgetTaskLimit ?? this.widgetTaskLimit,
      compactWidget: compactWidget ?? this.compactWidget,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'themeMode': themeMode.name,
    'languageCode': languageCode,
    'defaultReminderMinutes': defaultReminderMinutes,
    'defaultCategoryId': defaultCategoryId,
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
      defaultReminderMinutes: json['defaultReminderMinutes'] as int? ?? 15,
      defaultCategoryId: json['defaultCategoryId'] as String? ?? 'personal',
      widgetTransparency:
          (json['widgetTransparency'] as num?)?.toDouble() ?? 0.62,
      widgetShowsCompleted: json['widgetShowsCompleted'] as bool? ?? false,
      widgetTaskLimit: json['widgetTaskLimit'] as int? ?? 5,
      compactWidget: json['compactWidget'] as bool? ?? false,
    );
  }
}
