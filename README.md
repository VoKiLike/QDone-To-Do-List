# QDone

**QDone** is a premium cross-platform Flutter personal planning app by
**volkoweb studio**. It is built as a modern to-do and calendar foundation with
Clean Architecture, local storage, recurring tasks, reminders, a liquid
glass-inspired interface, and Android home widget groundwork.

Русская версия ниже.

## Features

- Flutter app for Android and iOS.
- Russian-first UI.
- Dark, light, and system theme modes.
- Custom animated liquid glass bottom navigation.
- Calendar page with Monday-first month view, task indicators, selected-day task list, and task creation/editing.
- Task overview page with daily summary and collapsible task groups.
- Local task persistence through repository/data-source boundaries.
- Task model with priority, energy level, category, status, reminders, recurrence, archive state, and notification IDs.
- Recurring task foundation with daily, weekly, monthly, yearly, custom intervals, and multiple times per day.
- Local notification service foundation using `flutter_local_notifications` and `timezone`.
- Android transparent home screen widget foundation using `home_widget`.
- Focus Mode foundation for distraction-free task actions.

## Architecture

The project is organized around Clean Architecture-style feature boundaries:

- `lib/core` - theme, constants, localization, notifications, storage notes, and shared UI primitives.
- `lib/features/tasks` - task entities, repositories, recurrence service, controller, pages, and widgets.
- `lib/features/calendar` - calendar state and calendar presentation.
- `lib/features/settings` - user settings and settings UI.
- `lib/features/home_widget` - widget data sync foundation.
- `lib/shared` - app shell and shared components.

## Tech Stack

- `flutter_riverpod` for state management.
- `go_router` for navigation.
- `shared_preferences` for the current local persistence foundation.
- `table_calendar` for the calendar UI.
- `flutter_local_notifications` and `timezone` for notification groundwork.
- `home_widget` for Android widget integration.
- `flutter_animate` for UI polish.

## Run

```bash
flutter pub get
flutter run
```

## Validation

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Current Notes

- The app is currently Russian-first and uses Russian as the fixed app locale.
- Persistence is implemented behind repository interfaces using local JSON in `shared_preferences`; this can be migrated to Drift without changing presentation controllers.
- Android widget support is present as a foundation. Direct mark-as-done actions from the launcher widget still require native callback completion.
- Production release still needs final Android signing, store metadata, and final iOS notification permission review.

## License

This project is licensed under the MIT License. See [LICENSE.md](LICENSE.md).

---

# QDone на русском

**QDone** - премиальное кроссплатформенное Flutter-приложение для личного
планирования от **volkoweb studio**. Проект построен как современная основа
для задач и календаря: Clean Architecture, локальное хранение, повторяющиеся
задачи, напоминания, интерфейс в стиле liquid glass и основа Android-виджета.

## Возможности

- Flutter-приложение для Android и iOS.
- Русскоязычный интерфейс по умолчанию.
- Темная, светлая и системная темы.
- Кастомная анимированная нижняя навигация в стиле liquid glass.
- Страница календаря: месяц с началом недели в понедельник, точки задач, список задач выбранного дня, создание и редактирование задач.
- Главная страница задач: сводка дня и сворачиваемые группы задач.
- Локальное сохранение задач через repository/data-source слой.
- Модель задачи с приоритетом, уровнем энергии, категорией, статусом, напоминаниями, повтором, архивом и ID уведомлений.
- Основа повторяющихся задач: ежедневно, еженедельно, ежемесячно, ежегодно, пользовательские интервалы и несколько времен в день.
- Основа локальных уведомлений через `flutter_local_notifications` и `timezone`.
- Основа прозрачного Android home screen widget через `home_widget`.
- Основа Focus Mode для работы с одной задачей без лишних отвлечений.

## Архитектура

Проект организован по feature-first Clean Architecture:

- `lib/core` - тема, константы, локализация, уведомления, заметки по storage и общие UI-примитивы.
- `lib/features/tasks` - сущности задач, репозитории, сервис повторов, контроллер, страницы и виджеты.
- `lib/features/calendar` - состояние и UI календаря.
- `lib/features/settings` - пользовательские настройки и экран меню.
- `lib/features/home_widget` - синхронизация данных для Android-виджета.
- `lib/shared` - оболочка приложения и общие компоненты.

## Стек

- `flutter_riverpod` для состояния.
- `go_router` для навигации.
- `shared_preferences` для текущей основы локального хранения.
- `table_calendar` для календаря.
- `flutter_local_notifications` и `timezone` для основы уведомлений.
- `home_widget` для Android-виджета.
- `flutter_animate` для анимаций интерфейса.

## Запуск

```bash
flutter pub get
flutter run
```

## Проверка

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Текущие заметки

- Приложение сейчас ориентировано на русский язык и использует русский как фиксированную локаль.
- Хранение реализовано через repository-интерфейсы и локальный JSON в `shared_preferences`; позже это можно заменить на Drift без переписывания presentation controllers.
- Android-виджет добавлен как основа. Прямое выполнение задачи из виджета требует завершения native callback-логики.
- Для production-релиза еще нужны финальная Android-подпись, store metadata и финальная проверка iOS permission flow для уведомлений.

## Лицензия

Проект распространяется по лицензии MIT. См. [LICENSE.md](LICENSE.md).
