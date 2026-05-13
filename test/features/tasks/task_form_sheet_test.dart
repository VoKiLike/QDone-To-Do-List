import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/presentation/widgets/task_form_sheet.dart';

void main() {
  const hapticsChannel = MethodChannel('qdone/haptics');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hapticsChannel, (_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hapticsChannel, null);
  });

  testWidgets('empty title shows validation and keeps sheet mounted', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TaskFormSheet(onSubmit: (_) async {})),
      ),
    );

    final createButton = find.widgetWithText(FilledButton, 'Создать задачу');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.text('Введите название задачи'), findsOneWidget);
    expect(find.byType(TaskFormSheet), findsOneWidget);
  });

  testWidgets('edit form prefills existing task title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskFormSheet(initialTask: _task(), onSubmit: (_) async {}),
        ),
      ),
    );

    expect(find.widgetWithText(TextField, 'Existing task'), findsOneWidget);
  });
}

Task _task() {
  return Task(
    id: 'task-1',
    title: 'Existing task',
    createdAt: DateTime(2026, 5, 10),
    dueDate: DateTime(2026, 5, 11),
    dueTime: const TimeOfDay(hour: 9, minute: 0),
    category: const TaskCategory(
      id: 'personal',
      name: 'Личное',
      colorValue: 0xFF8B5CF6,
    ),
  );
}
