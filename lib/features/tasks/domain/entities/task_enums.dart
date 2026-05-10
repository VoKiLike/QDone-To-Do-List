enum TaskPriority {
  low,
  medium,
  high;

  String get label => switch (this) {
    TaskPriority.low => 'Низкий',
    TaskPriority.medium => 'Средний',
    TaskPriority.high => 'Высокий',
  };
}

enum EnergyLevel {
  low,
  medium,
  high;

  String get label => switch (this) {
    EnergyLevel.low => 'Низкая энергия',
    EnergyLevel.medium => 'Средняя энергия',
    EnergyLevel.high => 'Высокая энергия',
  };
}

enum TaskStatus {
  active,
  overdue,
  completed,
  archived;

  String get label => switch (this) {
    TaskStatus.active => 'Активная',
    TaskStatus.overdue => 'Просрочена',
    TaskStatus.completed => 'Выполнена',
    TaskStatus.archived => 'В архиве',
  };
}

enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
  custom;

  String get label => switch (this) {
    RecurrenceType.none => 'Без повтора',
    RecurrenceType.daily => 'Ежедневно',
    RecurrenceType.weekly => 'Еженедельно',
    RecurrenceType.monthly => 'Ежемесячно',
    RecurrenceType.yearly => 'Ежегодно',
    RecurrenceType.custom => 'Настраиваемый',
  };
}

enum RecurrenceIntervalUnit {
  minutes,
  hours,
  days,
  weeks,
  months;

  String get label => switch (this) {
    RecurrenceIntervalUnit.minutes => 'мин.',
    RecurrenceIntervalUnit.hours => 'ч.',
    RecurrenceIntervalUnit.days => 'дн.',
    RecurrenceIntervalUnit.weeks => 'нед.',
    RecurrenceIntervalUnit.months => 'мес.',
  };
}

enum AppThemeMode {
  dark,
  light,
  system;

  String get label => switch (this) {
    AppThemeMode.dark => 'Темная',
    AppThemeMode.light => 'Светлая',
    AppThemeMode.system => 'Системная',
  };
}
