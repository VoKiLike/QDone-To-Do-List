import 'package:flutter/material.dart';

class QDoneLocalizations {
  const QDoneLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[Locale('ru')];

  static QDoneLocalizations of(BuildContext context) {
    return Localizations.of<QDoneLocalizations>(context, QDoneLocalizations) ??
        const QDoneLocalizations(Locale('ru'));
  }

  String get appName => 'QDone';

  String text(String key) {
    final values = _localizedValues['ru']!;
    return values[key] ?? key;
  }

  static const LocalizationsDelegate<QDoneLocalizations> delegate =
      _QDoneLocalizationsDelegate();
}

class _QDoneLocalizationsDelegate
    extends LocalizationsDelegate<QDoneLocalizations> {
  const _QDoneLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => QDoneLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<QDoneLocalizations> load(Locale locale) async =>
      QDoneLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<QDoneLocalizations> old) =>
      false;
}

const _localizedValues = <String, Map<String, String>>{
  'ru': <String, String>{
    'calendar': 'Календарь',
    'tasks': 'Задачи',
    'menu': 'Меню',
    'today': 'Сегодня',
    'overdue': 'Просроченные',
    'current': 'Текущие',
    'future': 'Будущие',
    'completed': 'Архив выполненных',
    'quickCapture': 'Быстрый ввод',
    'settings': 'Настройки',
    'createdBy': 'Создано volkoweb studio',
  },
};
