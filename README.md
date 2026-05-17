# QDone

> Персональный планировщик на Flutter: задачи, календарь, напоминания,
> повторы и Android-виджет в одном аккуратном приложении.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Version](https://img.shields.io/badge/version-0.4.9-29B37A?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-111827?style=for-the-badge)

**QDone** - русскоязычное кроссплатформенное приложение для личного
планирования от **VolkoWeb studio**. Проект совмещает быстрый список задач,
календарь, повторяющиеся дела, гибкие напоминания, локальное хранение и
визуальный стиль с liquid glass-панелями.

Приложение сейчас развивается как основа премиального мобильного планировщика:
чистая архитектура, понятные доменные модели, независимые feature-модули и
нативная интеграция с Android-виджетом.

## Что внутри

| Направление | Возможности |
| --- | --- |
| Задачи | приоритеты, энергия, категории, статусы, архив, восстановление, отложить и перенести |
| Календарь | месяц с понедельника, индикаторы задач, список выбранного дня, создание и редактирование |
| Повторы | ежедневно, еженедельно, ежемесячно, ежегодно, свои интервалы и несколько времен в день |
| Напоминания | локальные уведомления, настройка времени для каждой задачи, точные Android-alarms при разрешении |
| Виджет | прозрачный Android home widget, быстрые действия, активные и выполненные задачи |
| Интерфейс | светлая, темная и системная темы, liquid glass-навигация, haptic feedback, анимации |

## Почему проект интересен

- **Русский интерфейс первым делом.** Локализация уже есть в `app_ru.arb`, а
  приложение использует русский сценарий как основной.
- **Clean Architecture без фанатизма.** Бизнес-логика задач, повторов,
  хранилища и UI разделены по feature-границам.
- **Локальная приватность.** Текущая persistence-основа хранит данные локально
  через `shared_preferences` и репозиторные интерфейсы.
- **Живые task actions.** Выполнение, архив, восстановление, перенос и snooze
  обновляют экран локально, без полного состояния загрузки.
- **Готовность к росту.** Текущую JSON-persistence можно заменить на Drift или
  другой storage-слой без переписывания presentation-контроллеров.

## Быстрый старт

```bash
flutter pub get
flutter run
```

Для Android debug-сборки:

```bash
flutter build apk --debug
```

## Проверка качества

```bash
flutter analyze
flutter test
```

В проекте уже есть тесты для повторяющихся задач, сериализации, локального
репозитория, настроек, backup-модели, reminder-времени, формы задачи и
синхронизации Android-виджета.

## Архитектура

```text
lib/
  app/                 app providers, router, root widget
  core/                theme, localization, notifications, storage, shared UI
  features/
    tasks/             entities, repositories, recurrence, use cases, UI
    calendar/          calendar state and presentation
    settings/          user settings, backup model, settings UI
    home_widget/       Android widget sync and presentation contracts
  shared/              shell, components, extensions, common models
```

Ключевой принцип: каждая большая зона приложения живет в своем feature-модуле,
а общие вещи остаются в `core` и `shared`.

## Стек

- `flutter_riverpod` - состояние и dependency wiring.
- `go_router` - навигация.
- `shared_preferences` - текущая локальная persistence-основа.
- `table_calendar` - календарный UI.
- `flutter_local_notifications`, `timezone`, `flutter_timezone` - уведомления и
  часовые пояса.
- `home_widget` - Android-виджет.
- `flutter_animate` - мягкие анимации интерфейса.
- `intl` - форматирование и локализация.

## Текущий статус

Версия: **0.4.9+49**.

Проект уже содержит рабочую основу задач, календаря, настроек, напоминаний и
Android-виджета. Перед production-релизом еще нужны финальная Android-подпись,
store metadata, финальная проверка iOS permission flow для уведомлений и
полевые проверки на устройствах Huawei/HarmonyOS.

Для Huawei/HarmonyOS может потребоваться вручную разрешить уведомления, точные
будильники/напоминания, autostart, indirect launch и фоновую активность для
QDone. После установки обновления лучше открыть приложение один раз, чтобы
существующие напоминания пересоздались на актуальном Android notification
channel.

## English

**QDone** is a Russian-first cross-platform Flutter planning app by
**VolkoWeb studio**. It combines tasks, calendar planning, recurring schedules,
local reminders, local persistence, animated liquid glass UI, and Android home
widget groundwork.

Run it with:

```bash
flutter pub get
flutter run
```

Validate it with:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Лицензия

Проект распространяется по лицензии MIT. Подробности в [LICENSE.md](LICENSE.md).
