class WidgetStorageContract {
  const WidgetStorageContract._();

  static const flutterPreferencesName = 'FlutterSharedPreferences';
  static const tasksKey = 'qdone.tasks.v1';
  static const settingsKey = 'qdone.settings.v1';
  static const androidTasksKey = 'flutter.$tasksKey';
  static const androidSettingsKey = 'flutter.$settingsKey';

  static const widgetTitleKey = 'widget_title';
  static const widgetTasksTextKey = 'widget_tasks';
  static const widgetTasksJsonKey = 'widget_tasks_json';
  static const widgetTransparencyKey = 'widget_transparency';
  static const widgetCompactKey = 'widget_compact';
  static const widgetShowCompletedKey = 'widget_show_completed';
  static const widgetTaskLimitKey = 'widget_task_limit';
  static const widgetThemeKey = 'widget_theme';
}
