import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/presentation/widgets/task_card.dart';

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

  testWidgets('starts compact and reveals details only after expansion', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_task()));

    final compactHeight = tester.getSize(find.byType(TaskCard)).height;
    expect(compactHeight, lessThan(90));
    expect(find.text('Подробное описание задачи'), findsNothing);
    expect(find.text('Средняя энергия'), findsNothing);

    await tester.tap(find.byTooltip('Развернуть задачу'));
    await tester.pumpAndSettle();

    final expandedHeight = tester.getSize(find.byType(TaskCard)).height;
    expect(expandedHeight, greaterThan(compactHeight + 80));
    expect(find.text('Подробное описание задачи'), findsOneWidget);
    expect(find.text('Средняя энергия'), findsOneWidget);
    expect(find.byTooltip('Свернуть задачу'), findsOneWidget);
  });

  testWidgets('active status control completes the task once', (tester) async {
    var completeCalls = 0;
    await tester.pumpWidget(_app(_task(), onDone: () => completeCalls += 1));

    await tester.tap(find.bySemanticsLabel('Отметить задачу выполненной'));
    await tester.pump();

    expect(completeCalls, 1);
  });

  testWidgets('archived status control restores the task once', (tester) async {
    var restoreCalls = 0;
    await tester.pumpWidget(
      _app(
        _task(status: TaskStatus.archived, isArchived: true),
        onRestore: () => restoreCalls += 1,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Вернуть задачу из архива'));
    await tester.pump();

    expect(restoreCalls, 1);
  });
}

Widget _app(Task task, {VoidCallback? onDone, VoidCallback? onRestore}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: TaskCard(
            task: task,
            onDone: onDone ?? () {},
            onRestore: onRestore ?? () {},
            onDelete: () {},
            onSnooze: () {},
            onReschedule: () {},
            onEdit: () {},
          ),
        ),
      ),
    ),
  );
}

Task _task({TaskStatus status = TaskStatus.active, bool isArchived = false}) {
  final now = DateTime.now();
  return Task(
    id: 'task-1',
    title: 'Компактная задача',
    description: 'Подробное описание задачи',
    createdAt: now,
    dueDate: now.add(const Duration(days: 1)),
    dueTime: const TimeOfDay(hour: 11, minute: 30),
    status: status,
    isArchived: isArchived,
    category: const TaskCategory(
      id: 'personal',
      name: 'Личное',
      colorValue: 0xFF8B5CF6,
    ),
  );
}
