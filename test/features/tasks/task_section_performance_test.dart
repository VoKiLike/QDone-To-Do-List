import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_category.dart';
import 'package:qdone/features/tasks/presentation/widgets/task_card.dart';
import 'package:qdone/features/tasks/presentation/widgets/task_section.dart';

void main() {
  testWidgets('sliver builds only visible cards from the current page', (
    tester,
  ) async {
    final tasks = List<Task>.generate(50, _task);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              TaskSection(
                title: 'Текущие',
                tasks: tasks,
                totalCount: 10000,
                icon: Icons.today_rounded,
                accent: Colors.cyan,
                initiallyExpanded: true,
                onDone: (_) {},
                onRestore: (_) {},
                onDelete: (_) {},
                onSnooze: (_) {},
                onReschedule: (_) {},
                onEdit: (_) {},
                hasMore: true,
                isLoadingMore: false,
                onLoadMore: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    final builtCards = tester.widgetList<TaskCard>(find.byType(TaskCard));
    expect(builtCards.length, greaterThan(0));
    expect(builtCards.length, lessThan(50));
    expect(find.text('Task 49'), findsNothing);
  });
}

Task _task(int index) {
  return Task(
    id: 'task-$index',
    title: 'Task $index',
    createdAt: DateTime(2026, 6, 1),
    dueDate: DateTime(2026, 6, 9),
    dueTime: TimeOfDay(hour: 9 + (index % 8), minute: 0),
    category: const TaskCategory(
      id: 'personal',
      name: 'Личное',
      colorValue: 0xFF8B5CF6,
    ),
  );
}
