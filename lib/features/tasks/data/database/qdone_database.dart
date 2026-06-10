import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:qdone/features/tasks/domain/entities/task.dart';
import 'package:qdone/features/tasks/domain/entities/task_enums.dart';
import 'package:qdone/features/tasks/domain/repositories/task_repository.dart';

part 'qdone_database.g.dart';

class TaskRecords extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get dueAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => text()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get hasRecurrence =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get recurrenceEnd => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class ReminderRecords extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  DateTimeColumn get scheduledAt => dateTime()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class NotificationScheduleRecords extends Table {
  IntColumn get notificationId => integer()();
  TextColumn get taskId => text()();
  TextColumn get reminderId => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get fingerprint => text()();
  TextColumn get scheduleMode => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{notificationId};
}

class MetadataRecords extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

@DriftDatabase(
  tables: <Type>[
    TaskRecords,
    ReminderRecords,
    NotificationScheduleRecords,
    MetadataRecords,
  ],
)
class QDoneDatabase extends _$QDoneDatabase {
  QDoneDatabase(super.executor);

  QDoneDatabase.defaults()
    : super(
        driftDatabase(
          name: 'qdone',
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tasks_due_at '
        'ON task_records (due_at, id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tasks_status_due '
        'ON task_records (status, is_archived, due_at, id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tasks_recurrence '
        'ON task_records (has_recurrence, recurrence_end, due_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_reminders_scheduled '
        'ON reminder_records (is_enabled, scheduled_at, task_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_schedule_time '
        'ON notification_schedule_records (scheduled_at)',
      );
    },
  );

  Future<void> upsertTask(Task task) {
    return transaction(() async {
      await into(taskRecords).insertOnConflictUpdate(_taskCompanion(task));
      await (delete(
        reminderRecords,
      )..where((row) => row.taskId.equals(task.id))).go();
      if (task.reminders.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            reminderRecords,
            task.reminders
                .map(
                  (reminder) => ReminderRecordsCompanion.insert(
                    id: reminder.id,
                    taskId: reminder.taskId,
                    scheduledAt: reminder.dateTime,
                    isEnabled: Value<bool>(reminder.isEnabled),
                  ),
                )
                .toList(),
            mode: InsertMode.insertOrReplace,
          );
        });
      }
    });
  }

  Future<void> replaceTasks(List<Task> tasks) {
    return transaction(() async {
      await delete(notificationScheduleRecords).go();
      await delete(reminderRecords).go();
      await delete(taskRecords).go();
      if (tasks.isEmpty) {
        return;
      }
      await batch((batch) {
        batch.insertAll(
          taskRecords,
          tasks.map(_taskCompanion).toList(),
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          reminderRecords,
          tasks
              .expand((task) => task.reminders)
              .map(
                (reminder) => ReminderRecordsCompanion.insert(
                  id: reminder.id,
                  taskId: reminder.taskId,
                  scheduledAt: reminder.dateTime,
                  isEnabled: Value<bool>(reminder.isEnabled),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<List<Task>> allTasks() async {
    final rows =
        await (select(taskRecords)
              ..orderBy(<OrderingTerm Function(TaskRecords)>[
                (row) => OrderingTerm.asc(row.dueAt),
                (row) => OrderingTerm.asc(row.id),
              ]))
            .get();
    return rows.map(_taskFromRow).toList();
  }

  Future<TaskPage> taskPage({
    required TaskSectionKind section,
    required DateTime now,
    TaskPageCursor? cursor,
    int limit = TaskRepository.defaultPageSize,
  }) async {
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final query = select(taskRecords);
    final active =
        taskRecords.isArchived.equals(false) &
        taskRecords.status.isNotIn(<String>[
          TaskStatus.completed.name,
          TaskStatus.archived.name,
        ]);

    switch (section) {
      case TaskSectionKind.overdue:
        query.where((_) => active & taskRecords.dueAt.isSmallerThanValue(now));
        break;
      case TaskSectionKind.current:
        query.where(
          (_) =>
              active &
              taskRecords.dueAt.isBiggerOrEqualValue(now) &
              taskRecords.dueAt.isSmallerOrEqualValue(todayEnd),
        );
        break;
      case TaskSectionKind.future:
        query.where(
          (_) => active & taskRecords.dueAt.isBiggerThanValue(todayEnd),
        );
        break;
      case TaskSectionKind.completed:
        query.where(
          (_) =>
              taskRecords.isArchived.equals(true) |
              taskRecords.status.isIn(<String>[
                TaskStatus.completed.name,
                TaskStatus.archived.name,
              ]),
        );
        break;
    }

    if (cursor != null) {
      final afterCursor =
          taskRecords.dueAt.isBiggerThanValue(cursor.sortAt) |
          (taskRecords.dueAt.equals(cursor.sortAt) &
              taskRecords.id.isBiggerThanValue(cursor.id));
      query.where((_) => afterCursor);
    }

    query
      ..orderBy(<OrderingTerm Function(TaskRecords)>[
        (row) => OrderingTerm.asc(row.dueAt),
        (row) => OrderingTerm.asc(row.id),
      ])
      ..limit(limit + 1);
    final rows = await query.get();
    final hasMore = rows.length > limit;
    final visible = hasMore ? rows.take(limit).toList() : rows;
    final tasks = visible.map(_taskFromRow).toList();
    final last = visible.isEmpty ? null : visible.last;
    return TaskPage(
      tasks: tasks,
      nextCursor: hasMore && last != null
          ? TaskPageCursor(sortAt: last.dueAt, id: last.id)
          : null,
    );
  }

  Future<TaskCounts> counts(DateTime now) async {
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final active =
        taskRecords.isArchived.equals(false) &
        taskRecords.status.isNotIn(<String>[
          TaskStatus.completed.name,
          TaskStatus.archived.name,
        ]);
    return TaskCounts(
      overdue: await _count(active & taskRecords.dueAt.isSmallerThanValue(now)),
      current: await _count(
        active &
            taskRecords.dueAt.isBiggerOrEqualValue(now) &
            taskRecords.dueAt.isSmallerOrEqualValue(todayEnd),
      ),
      future: await _count(
        active & taskRecords.dueAt.isBiggerThanValue(todayEnd),
      ),
      completed: await _count(
        taskRecords.isArchived.equals(true) |
            taskRecords.status.isIn(<String>[
              TaskStatus.completed.name,
              TaskStatus.archived.name,
            ]),
      ),
    );
  }

  Future<List<Task>> tasksForRange(DateTime from, DateTime to) async {
    final rows =
        await (select(taskRecords)
              ..where(
                (_) =>
                    taskRecords.isArchived.equals(false) &
                    (taskRecords.dueAt.isBetweenValues(from, to) |
                        (taskRecords.hasRecurrence.equals(true) &
                            taskRecords.dueAt.isSmallerOrEqualValue(to) &
                            (taskRecords.recurrenceEnd.isNull() |
                                taskRecords.recurrenceEnd.isBiggerOrEqualValue(
                                  from,
                                )))),
              )
              ..orderBy(<OrderingTerm Function(TaskRecords)>[
                (row) => OrderingTerm.asc(row.dueAt),
              ]))
            .get();
    return rows.map(_taskFromRow).toList();
  }

  Future<List<Task>> notificationCandidates({
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await customSelect(
      '''
      SELECT t.*
      FROM task_records t
      WHERE t.is_archived = 0
        AND t.status NOT IN (?, ?)
        AND (
          EXISTS (
            SELECT 1 FROM reminder_records r
            WHERE r.task_id = t.id
              AND r.is_enabled = 1
              AND r.scheduled_at BETWEEN ? AND ?
          )
          OR (
            t.has_recurrence = 1
            AND t.due_at <= ?
            AND (t.recurrence_end IS NULL OR t.recurrence_end >= ?)
            AND EXISTS (
              SELECT 1 FROM reminder_records r
              WHERE r.task_id = t.id AND r.is_enabled = 1
            )
          )
        )
      ORDER BY t.due_at ASC, t.id ASC
      ''',
      variables: <Variable<Object>>[
        Variable<String>(TaskStatus.completed.name),
        Variable<String>(TaskStatus.archived.name),
        Variable<DateTime>(from),
        Variable<DateTime>(to),
        Variable<DateTime>(to),
        Variable<DateTime>(from),
      ],
      readsFrom: <ResultSetImplementation>{taskRecords, reminderRecords},
    ).get();
    return rows
        .map(
          (row) => Task.fromJson(
            Map<String, dynamic>.from(
              jsonDecode(row.read<String>('payload')) as Map,
            ),
          ),
        )
        .toList();
  }

  Future<List<Task>> completedPage({int limit = 50, int offset = 0}) async {
    final rows =
        await (select(taskRecords)
              ..where(
                (_) =>
                    taskRecords.isArchived.equals(true) |
                    taskRecords.status.isIn(<String>[
                      TaskStatus.completed.name,
                      TaskStatus.archived.name,
                    ]),
              )
              ..orderBy(<OrderingTerm Function(TaskRecords)>[
                (row) => OrderingTerm.desc(row.completedAt),
                (row) => OrderingTerm.desc(row.dueAt),
              ])
              ..limit(limit, offset: offset))
            .get();
    return rows.map(_taskFromRow).toList();
  }

  Future<TaskDailySummary> dailySummary(DateTime now) async {
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final today = await tasksForRange(start, end);
    final effective = today.map((task) => task.effectiveStatus(now)).toList();
    final nextRow =
        await (select(taskRecords)
              ..where(
                (_) =>
                    taskRecords.isArchived.equals(false) &
                    taskRecords.status.isNotIn(<String>[
                      TaskStatus.completed.name,
                      TaskStatus.archived.name,
                    ]) &
                    taskRecords.dueAt.isBiggerThanValue(now),
              )
              ..orderBy(<OrderingTerm Function(TaskRecords)>[
                (row) => OrderingTerm.asc(row.dueAt),
              ])
              ..limit(1))
            .getSingleOrNull();
    return TaskDailySummary(
      completed: effective.where((task) => task.isCompleted).length,
      remaining: effective.where((task) => !task.isCompleted).length,
      overdue: await _count(
        taskRecords.isArchived.equals(false) &
            taskRecords.status.isNotIn(<String>[
              TaskStatus.completed.name,
              TaskStatus.archived.name,
            ]) &
            taskRecords.dueAt.isSmallerThanValue(now),
      ),
      nextTask: nextRow == null ? null : _taskFromRow(nextRow),
    );
  }

  Future<Task?> taskById(String taskId) async {
    final row = await (select(
      taskRecords,
    )..where((item) => item.id.equals(taskId))).getSingleOrNull();
    return row == null ? null : _taskFromRow(row);
  }

  Future<int> taskCount() async {
    final count = taskRecords.id.count();
    final row = await (selectOnly(
      taskRecords,
    )..addColumns(<Expression<Object>>[count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> deleteTask(String taskId) {
    return transaction(() async {
      await (delete(
        notificationScheduleRecords,
      )..where((row) => row.taskId.equals(taskId))).go();
      await (delete(
        reminderRecords,
      )..where((row) => row.taskId.equals(taskId))).go();
      await (delete(taskRecords)..where((row) => row.id.equals(taskId))).go();
    });
  }

  Future<void> deleteCompletedTasks() {
    return transaction(() async {
      final completedIds =
          await (selectOnly(taskRecords)
                ..addColumns(<Expression<Object>>[taskRecords.id])
                ..where(
                  taskRecords.status.equals(TaskStatus.completed.name) |
                      taskRecords.status.equals(TaskStatus.archived.name) |
                      taskRecords.isArchived.equals(true),
                ))
              .map((row) => row.read(taskRecords.id)!)
              .get();
      if (completedIds.isEmpty) {
        return;
      }
      await (delete(
        notificationScheduleRecords,
      )..where((row) => row.taskId.isIn(completedIds))).go();
      await (delete(
        reminderRecords,
      )..where((row) => row.taskId.isIn(completedIds))).go();
      await (delete(
        taskRecords,
      )..where((row) => row.id.isIn(completedIds))).go();
    });
  }

  Future<String?> metadata(String key) async {
    final row = await (select(
      metadataRecords,
    )..where((item) => item.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setMetadata(String key, String value) {
    return into(metadataRecords).insertOnConflictUpdate(
      MetadataRecordsCompanion.insert(key: key, value: value),
    );
  }

  Future<void> clearSchedule() => delete(notificationScheduleRecords).go();

  Future<List<NotificationScheduleRecord>> notificationSchedule() {
    return (select(notificationScheduleRecords)
          ..orderBy(<OrderingTerm Function(NotificationScheduleRecords)>[
            (row) => OrderingTerm.asc(row.scheduledAt),
          ]))
        .get();
  }

  Future<void> replaceNotificationSchedule(
    List<NotificationScheduleRecordsCompanion> rows,
  ) {
    return transaction(() async {
      await delete(notificationScheduleRecords).go();
      if (rows.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            notificationScheduleRecords,
            rows,
            mode: InsertMode.insertOrReplace,
          );
        });
      }
    });
  }

  Future<int> _count(Expression<bool> predicate) async {
    final count = taskRecords.id.count();
    final row =
        await (selectOnly(taskRecords)
              ..addColumns(<Expression<Object>>[count])
              ..where(predicate))
            .getSingle();
    return row.read(count) ?? 0;
  }

  TaskRecordsCompanion _taskCompanion(Task task) {
    return TaskRecordsCompanion.insert(
      id: task.id,
      payload: jsonEncode(task.toJson()),
      createdAt: task.createdAt,
      dueAt: task.dueDateTime,
      completedAt: Value<DateTime?>(task.completedAt),
      status: task.status.name,
      isArchived: Value<bool>(task.isArchived),
      hasRecurrence: Value<bool>(
        task.recurrenceRule.isEnabled &&
            task.recurrenceRule.type != RecurrenceType.none,
      ),
      recurrenceEnd: Value<DateTime?>(task.recurrenceRule.endDate),
    );
  }

  Task _taskFromRow(TaskRecord row) {
    return Task.fromJson(
      Map<String, dynamic>.from(jsonDecode(row.payload) as Map),
    );
  }
}
