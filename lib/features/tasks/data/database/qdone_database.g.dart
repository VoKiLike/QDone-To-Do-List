// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qdone_database.dart';

// ignore_for_file: type=lint
class $TaskRecordsTable extends TaskRecords
    with TableInfo<$TaskRecordsTable, TaskRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasRecurrenceMeta = const VerificationMeta(
    'hasRecurrence',
  );
  @override
  late final GeneratedColumn<bool> hasRecurrence = GeneratedColumn<bool>(
    'has_recurrence',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_recurrence" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recurrenceEndMeta = const VerificationMeta(
    'recurrenceEnd',
  );
  @override
  late final GeneratedColumn<DateTime> recurrenceEnd =
      GeneratedColumn<DateTime>(
        'recurrence_end',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    payload,
    createdAt,
    dueAt,
    completedAt,
    status,
    isArchived,
    hasRecurrence,
    recurrenceEnd,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('has_recurrence')) {
      context.handle(
        _hasRecurrenceMeta,
        hasRecurrence.isAcceptableOrUnknown(
          data['has_recurrence']!,
          _hasRecurrenceMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_end')) {
      context.handle(
        _recurrenceEndMeta,
        recurrenceEnd.isAcceptableOrUnknown(
          data['recurrence_end']!,
          _recurrenceEndMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      hasRecurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_recurrence'],
      )!,
      recurrenceEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recurrence_end'],
      ),
    );
  }

  @override
  $TaskRecordsTable createAlias(String alias) {
    return $TaskRecordsTable(attachedDatabase, alias);
  }
}

class TaskRecord extends DataClass implements Insertable<TaskRecord> {
  final String id;
  final String payload;
  final DateTime createdAt;
  final DateTime dueAt;
  final DateTime? completedAt;
  final String status;
  final bool isArchived;
  final bool hasRecurrence;
  final DateTime? recurrenceEnd;
  const TaskRecord({
    required this.id,
    required this.payload,
    required this.createdAt,
    required this.dueAt,
    this.completedAt,
    required this.status,
    required this.isArchived,
    required this.hasRecurrence,
    this.recurrenceEnd,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['due_at'] = Variable<DateTime>(dueAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['status'] = Variable<String>(status);
    map['is_archived'] = Variable<bool>(isArchived);
    map['has_recurrence'] = Variable<bool>(hasRecurrence);
    if (!nullToAbsent || recurrenceEnd != null) {
      map['recurrence_end'] = Variable<DateTime>(recurrenceEnd);
    }
    return map;
  }

  TaskRecordsCompanion toCompanion(bool nullToAbsent) {
    return TaskRecordsCompanion(
      id: Value(id),
      payload: Value(payload),
      createdAt: Value(createdAt),
      dueAt: Value(dueAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      status: Value(status),
      isArchived: Value(isArchived),
      hasRecurrence: Value(hasRecurrence),
      recurrenceEnd: recurrenceEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceEnd),
    );
  }

  factory TaskRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRecord(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      status: serializer.fromJson<String>(json['status']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      hasRecurrence: serializer.fromJson<bool>(json['hasRecurrence']),
      recurrenceEnd: serializer.fromJson<DateTime?>(json['recurrenceEnd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'status': serializer.toJson<String>(status),
      'isArchived': serializer.toJson<bool>(isArchived),
      'hasRecurrence': serializer.toJson<bool>(hasRecurrence),
      'recurrenceEnd': serializer.toJson<DateTime?>(recurrenceEnd),
    };
  }

  TaskRecord copyWith({
    String? id,
    String? payload,
    DateTime? createdAt,
    DateTime? dueAt,
    Value<DateTime?> completedAt = const Value.absent(),
    String? status,
    bool? isArchived,
    bool? hasRecurrence,
    Value<DateTime?> recurrenceEnd = const Value.absent(),
  }) => TaskRecord(
    id: id ?? this.id,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    dueAt: dueAt ?? this.dueAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    status: status ?? this.status,
    isArchived: isArchived ?? this.isArchived,
    hasRecurrence: hasRecurrence ?? this.hasRecurrence,
    recurrenceEnd: recurrenceEnd.present
        ? recurrenceEnd.value
        : this.recurrenceEnd,
  );
  TaskRecord copyWithCompanion(TaskRecordsCompanion data) {
    return TaskRecord(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      status: data.status.present ? data.status.value : this.status,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      hasRecurrence: data.hasRecurrence.present
          ? data.hasRecurrence.value
          : this.hasRecurrence,
      recurrenceEnd: data.recurrenceEnd.present
          ? data.recurrenceEnd.value
          : this.recurrenceEnd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRecord(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('isArchived: $isArchived, ')
          ..write('hasRecurrence: $hasRecurrence, ')
          ..write('recurrenceEnd: $recurrenceEnd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    payload,
    createdAt,
    dueAt,
    completedAt,
    status,
    isArchived,
    hasRecurrence,
    recurrenceEnd,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRecord &&
          other.id == this.id &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.dueAt == this.dueAt &&
          other.completedAt == this.completedAt &&
          other.status == this.status &&
          other.isArchived == this.isArchived &&
          other.hasRecurrence == this.hasRecurrence &&
          other.recurrenceEnd == this.recurrenceEnd);
}

class TaskRecordsCompanion extends UpdateCompanion<TaskRecord> {
  final Value<String> id;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime> dueAt;
  final Value<DateTime?> completedAt;
  final Value<String> status;
  final Value<bool> isArchived;
  final Value<bool> hasRecurrence;
  final Value<DateTime?> recurrenceEnd;
  final Value<int> rowid;
  const TaskRecordsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.hasRecurrence = const Value.absent(),
    this.recurrenceEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskRecordsCompanion.insert({
    required String id,
    required String payload,
    required DateTime createdAt,
    required DateTime dueAt,
    this.completedAt = const Value.absent(),
    required String status,
    this.isArchived = const Value.absent(),
    this.hasRecurrence = const Value.absent(),
    this.recurrenceEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload),
       createdAt = Value(createdAt),
       dueAt = Value(dueAt),
       status = Value(status);
  static Insertable<TaskRecord> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? completedAt,
    Expression<String>? status,
    Expression<bool>? isArchived,
    Expression<bool>? hasRecurrence,
    Expression<DateTime>? recurrenceEnd,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (dueAt != null) 'due_at': dueAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (status != null) 'status': status,
      if (isArchived != null) 'is_archived': isArchived,
      if (hasRecurrence != null) 'has_recurrence': hasRecurrence,
      if (recurrenceEnd != null) 'recurrence_end': recurrenceEnd,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<DateTime>? dueAt,
    Value<DateTime?>? completedAt,
    Value<String>? status,
    Value<bool>? isArchived,
    Value<bool>? hasRecurrence,
    Value<DateTime?>? recurrenceEnd,
    Value<int>? rowid,
  }) {
    return TaskRecordsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      dueAt: dueAt ?? this.dueAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      isArchived: isArchived ?? this.isArchived,
      hasRecurrence: hasRecurrence ?? this.hasRecurrence,
      recurrenceEnd: recurrenceEnd ?? this.recurrenceEnd,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (hasRecurrence.present) {
      map['has_recurrence'] = Variable<bool>(hasRecurrence.value);
    }
    if (recurrenceEnd.present) {
      map['recurrence_end'] = Variable<DateTime>(recurrenceEnd.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskRecordsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('isArchived: $isArchived, ')
          ..write('hasRecurrence: $hasRecurrence, ')
          ..write('recurrenceEnd: $recurrenceEnd, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderRecordsTable extends ReminderRecords
    with TableInfo<$ReminderRecordsTable, ReminderRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, taskId, scheduledAt, isEnabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
    );
  }

  @override
  $ReminderRecordsTable createAlias(String alias) {
    return $ReminderRecordsTable(attachedDatabase, alias);
  }
}

class ReminderRecord extends DataClass implements Insertable<ReminderRecord> {
  final String id;
  final String taskId;
  final DateTime scheduledAt;
  final bool isEnabled;
  const ReminderRecord({
    required this.id,
    required this.taskId,
    required this.scheduledAt,
    required this.isEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['is_enabled'] = Variable<bool>(isEnabled);
    return map;
  }

  ReminderRecordsCompanion toCompanion(bool nullToAbsent) {
    return ReminderRecordsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      scheduledAt: Value(scheduledAt),
      isEnabled: Value(isEnabled),
    );
  }

  factory ReminderRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRecord(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'isEnabled': serializer.toJson<bool>(isEnabled),
    };
  }

  ReminderRecord copyWith({
    String? id,
    String? taskId,
    DateTime? scheduledAt,
    bool? isEnabled,
  }) => ReminderRecord(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    isEnabled: isEnabled ?? this.isEnabled,
  );
  ReminderRecord copyWithCompanion(ReminderRecordsCompanion data) {
    return ReminderRecord(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRecord(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('isEnabled: $isEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, scheduledAt, isEnabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRecord &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.scheduledAt == this.scheduledAt &&
          other.isEnabled == this.isEnabled);
}

class ReminderRecordsCompanion extends UpdateCompanion<ReminderRecord> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<DateTime> scheduledAt;
  final Value<bool> isEnabled;
  final Value<int> rowid;
  const ReminderRecordsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderRecordsCompanion.insert({
    required String id,
    required String taskId,
    required DateTime scheduledAt,
    this.isEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       scheduledAt = Value(scheduledAt);
  static Insertable<ReminderRecord> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<DateTime>? scheduledAt,
    Expression<bool>? isEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<DateTime>? scheduledAt,
    Value<bool>? isEnabled,
    Value<int>? rowid,
  }) {
    return ReminderRecordsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isEnabled: isEnabled ?? this.isEnabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRecordsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationScheduleRecordsTable extends NotificationScheduleRecords
    with
        TableInfo<
          $NotificationScheduleRecordsTable,
          NotificationScheduleRecord
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationScheduleRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<String> reminderId = GeneratedColumn<String>(
    'reminder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleModeMeta = const VerificationMeta(
    'scheduleMode',
  );
  @override
  late final GeneratedColumn<String> scheduleMode = GeneratedColumn<String>(
    'schedule_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    notificationId,
    taskId,
    reminderId,
    scheduledAt,
    fingerprint,
    scheduleMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_schedule_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationScheduleRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('schedule_mode')) {
      context.handle(
        _scheduleModeMeta,
        scheduleMode.isAcceptableOrUnknown(
          data['schedule_mode']!,
          _scheduleModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleModeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {notificationId};
  @override
  NotificationScheduleRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationScheduleRecord(
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_id'],
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      scheduleMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_mode'],
      )!,
    );
  }

  @override
  $NotificationScheduleRecordsTable createAlias(String alias) {
    return $NotificationScheduleRecordsTable(attachedDatabase, alias);
  }
}

class NotificationScheduleRecord extends DataClass
    implements Insertable<NotificationScheduleRecord> {
  final int notificationId;
  final String taskId;
  final String? reminderId;
  final DateTime scheduledAt;
  final String fingerprint;
  final String scheduleMode;
  const NotificationScheduleRecord({
    required this.notificationId,
    required this.taskId,
    this.reminderId,
    required this.scheduledAt,
    required this.fingerprint,
    required this.scheduleMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['notification_id'] = Variable<int>(notificationId);
    map['task_id'] = Variable<String>(taskId);
    if (!nullToAbsent || reminderId != null) {
      map['reminder_id'] = Variable<String>(reminderId);
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['fingerprint'] = Variable<String>(fingerprint);
    map['schedule_mode'] = Variable<String>(scheduleMode);
    return map;
  }

  NotificationScheduleRecordsCompanion toCompanion(bool nullToAbsent) {
    return NotificationScheduleRecordsCompanion(
      notificationId: Value(notificationId),
      taskId: Value(taskId),
      reminderId: reminderId == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderId),
      scheduledAt: Value(scheduledAt),
      fingerprint: Value(fingerprint),
      scheduleMode: Value(scheduleMode),
    );
  }

  factory NotificationScheduleRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationScheduleRecord(
      notificationId: serializer.fromJson<int>(json['notificationId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      reminderId: serializer.fromJson<String?>(json['reminderId']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      scheduleMode: serializer.fromJson<String>(json['scheduleMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'notificationId': serializer.toJson<int>(notificationId),
      'taskId': serializer.toJson<String>(taskId),
      'reminderId': serializer.toJson<String?>(reminderId),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'scheduleMode': serializer.toJson<String>(scheduleMode),
    };
  }

  NotificationScheduleRecord copyWith({
    int? notificationId,
    String? taskId,
    Value<String?> reminderId = const Value.absent(),
    DateTime? scheduledAt,
    String? fingerprint,
    String? scheduleMode,
  }) => NotificationScheduleRecord(
    notificationId: notificationId ?? this.notificationId,
    taskId: taskId ?? this.taskId,
    reminderId: reminderId.present ? reminderId.value : this.reminderId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    fingerprint: fingerprint ?? this.fingerprint,
    scheduleMode: scheduleMode ?? this.scheduleMode,
  );
  NotificationScheduleRecord copyWithCompanion(
    NotificationScheduleRecordsCompanion data,
  ) {
    return NotificationScheduleRecord(
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      scheduleMode: data.scheduleMode.present
          ? data.scheduleMode.value
          : this.scheduleMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationScheduleRecord(')
          ..write('notificationId: $notificationId, ')
          ..write('taskId: $taskId, ')
          ..write('reminderId: $reminderId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('scheduleMode: $scheduleMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    notificationId,
    taskId,
    reminderId,
    scheduledAt,
    fingerprint,
    scheduleMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationScheduleRecord &&
          other.notificationId == this.notificationId &&
          other.taskId == this.taskId &&
          other.reminderId == this.reminderId &&
          other.scheduledAt == this.scheduledAt &&
          other.fingerprint == this.fingerprint &&
          other.scheduleMode == this.scheduleMode);
}

class NotificationScheduleRecordsCompanion
    extends UpdateCompanion<NotificationScheduleRecord> {
  final Value<int> notificationId;
  final Value<String> taskId;
  final Value<String?> reminderId;
  final Value<DateTime> scheduledAt;
  final Value<String> fingerprint;
  final Value<String> scheduleMode;
  const NotificationScheduleRecordsCompanion({
    this.notificationId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.scheduleMode = const Value.absent(),
  });
  NotificationScheduleRecordsCompanion.insert({
    this.notificationId = const Value.absent(),
    required String taskId,
    this.reminderId = const Value.absent(),
    required DateTime scheduledAt,
    required String fingerprint,
    required String scheduleMode,
  }) : taskId = Value(taskId),
       scheduledAt = Value(scheduledAt),
       fingerprint = Value(fingerprint),
       scheduleMode = Value(scheduleMode);
  static Insertable<NotificationScheduleRecord> custom({
    Expression<int>? notificationId,
    Expression<String>? taskId,
    Expression<String>? reminderId,
    Expression<DateTime>? scheduledAt,
    Expression<String>? fingerprint,
    Expression<String>? scheduleMode,
  }) {
    return RawValuesInsertable({
      if (notificationId != null) 'notification_id': notificationId,
      if (taskId != null) 'task_id': taskId,
      if (reminderId != null) 'reminder_id': reminderId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (scheduleMode != null) 'schedule_mode': scheduleMode,
    });
  }

  NotificationScheduleRecordsCompanion copyWith({
    Value<int>? notificationId,
    Value<String>? taskId,
    Value<String?>? reminderId,
    Value<DateTime>? scheduledAt,
    Value<String>? fingerprint,
    Value<String>? scheduleMode,
  }) {
    return NotificationScheduleRecordsCompanion(
      notificationId: notificationId ?? this.notificationId,
      taskId: taskId ?? this.taskId,
      reminderId: reminderId ?? this.reminderId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      fingerprint: fingerprint ?? this.fingerprint,
      scheduleMode: scheduleMode ?? this.scheduleMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<String>(reminderId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (scheduleMode.present) {
      map['schedule_mode'] = Variable<String>(scheduleMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationScheduleRecordsCompanion(')
          ..write('notificationId: $notificationId, ')
          ..write('taskId: $taskId, ')
          ..write('reminderId: $reminderId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('scheduleMode: $scheduleMode')
          ..write(')'))
        .toString();
  }
}

class $MetadataRecordsTable extends MetadataRecords
    with TableInfo<$MetadataRecordsTable, MetadataRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetadataRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metadata_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetadataRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetadataRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetadataRecord(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MetadataRecordsTable createAlias(String alias) {
    return $MetadataRecordsTable(attachedDatabase, alias);
  }
}

class MetadataRecord extends DataClass implements Insertable<MetadataRecord> {
  final String key;
  final String value;
  const MetadataRecord({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetadataRecordsCompanion toCompanion(bool nullToAbsent) {
    return MetadataRecordsCompanion(key: Value(key), value: Value(value));
  }

  factory MetadataRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetadataRecord(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetadataRecord copyWith({String? key, String? value}) =>
      MetadataRecord(key: key ?? this.key, value: value ?? this.value);
  MetadataRecord copyWithCompanion(MetadataRecordsCompanion data) {
    return MetadataRecord(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetadataRecord(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetadataRecord &&
          other.key == this.key &&
          other.value == this.value);
}

class MetadataRecordsCompanion extends UpdateCompanion<MetadataRecord> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetadataRecordsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetadataRecordsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MetadataRecord> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetadataRecordsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetadataRecordsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetadataRecordsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$QDoneDatabase extends GeneratedDatabase {
  _$QDoneDatabase(QueryExecutor e) : super(e);
  $QDoneDatabaseManager get managers => $QDoneDatabaseManager(this);
  late final $TaskRecordsTable taskRecords = $TaskRecordsTable(this);
  late final $ReminderRecordsTable reminderRecords = $ReminderRecordsTable(
    this,
  );
  late final $NotificationScheduleRecordsTable notificationScheduleRecords =
      $NotificationScheduleRecordsTable(this);
  late final $MetadataRecordsTable metadataRecords = $MetadataRecordsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    taskRecords,
    reminderRecords,
    notificationScheduleRecords,
    metadataRecords,
  ];
}

typedef $$TaskRecordsTableCreateCompanionBuilder =
    TaskRecordsCompanion Function({
      required String id,
      required String payload,
      required DateTime createdAt,
      required DateTime dueAt,
      Value<DateTime?> completedAt,
      required String status,
      Value<bool> isArchived,
      Value<bool> hasRecurrence,
      Value<DateTime?> recurrenceEnd,
      Value<int> rowid,
    });
typedef $$TaskRecordsTableUpdateCompanionBuilder =
    TaskRecordsCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<DateTime> dueAt,
      Value<DateTime?> completedAt,
      Value<String> status,
      Value<bool> isArchived,
      Value<bool> hasRecurrence,
      Value<DateTime?> recurrenceEnd,
      Value<int> rowid,
    });

class $$TaskRecordsTableFilterComposer
    extends Composer<_$QDoneDatabase, $TaskRecordsTable> {
  $$TaskRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasRecurrence => $composableBuilder(
    column: $table.hasRecurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recurrenceEnd => $composableBuilder(
    column: $table.recurrenceEnd,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskRecordsTableOrderingComposer
    extends Composer<_$QDoneDatabase, $TaskRecordsTable> {
  $$TaskRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasRecurrence => $composableBuilder(
    column: $table.hasRecurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recurrenceEnd => $composableBuilder(
    column: $table.recurrenceEnd,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskRecordsTableAnnotationComposer
    extends Composer<_$QDoneDatabase, $TaskRecordsTable> {
  $$TaskRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasRecurrence => $composableBuilder(
    column: $table.hasRecurrence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recurrenceEnd => $composableBuilder(
    column: $table.recurrenceEnd,
    builder: (column) => column,
  );
}

class $$TaskRecordsTableTableManager
    extends
        RootTableManager<
          _$QDoneDatabase,
          $TaskRecordsTable,
          TaskRecord,
          $$TaskRecordsTableFilterComposer,
          $$TaskRecordsTableOrderingComposer,
          $$TaskRecordsTableAnnotationComposer,
          $$TaskRecordsTableCreateCompanionBuilder,
          $$TaskRecordsTableUpdateCompanionBuilder,
          (
            TaskRecord,
            BaseReferences<_$QDoneDatabase, $TaskRecordsTable, TaskRecord>,
          ),
          TaskRecord,
          PrefetchHooks Function()
        > {
  $$TaskRecordsTableTableManager(_$QDoneDatabase db, $TaskRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> hasRecurrence = const Value.absent(),
                Value<DateTime?> recurrenceEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskRecordsCompanion(
                id: id,
                payload: payload,
                createdAt: createdAt,
                dueAt: dueAt,
                completedAt: completedAt,
                status: status,
                isArchived: isArchived,
                hasRecurrence: hasRecurrence,
                recurrenceEnd: recurrenceEnd,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                required DateTime createdAt,
                required DateTime dueAt,
                Value<DateTime?> completedAt = const Value.absent(),
                required String status,
                Value<bool> isArchived = const Value.absent(),
                Value<bool> hasRecurrence = const Value.absent(),
                Value<DateTime?> recurrenceEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskRecordsCompanion.insert(
                id: id,
                payload: payload,
                createdAt: createdAt,
                dueAt: dueAt,
                completedAt: completedAt,
                status: status,
                isArchived: isArchived,
                hasRecurrence: hasRecurrence,
                recurrenceEnd: recurrenceEnd,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$QDoneDatabase,
      $TaskRecordsTable,
      TaskRecord,
      $$TaskRecordsTableFilterComposer,
      $$TaskRecordsTableOrderingComposer,
      $$TaskRecordsTableAnnotationComposer,
      $$TaskRecordsTableCreateCompanionBuilder,
      $$TaskRecordsTableUpdateCompanionBuilder,
      (
        TaskRecord,
        BaseReferences<_$QDoneDatabase, $TaskRecordsTable, TaskRecord>,
      ),
      TaskRecord,
      PrefetchHooks Function()
    >;
typedef $$ReminderRecordsTableCreateCompanionBuilder =
    ReminderRecordsCompanion Function({
      required String id,
      required String taskId,
      required DateTime scheduledAt,
      Value<bool> isEnabled,
      Value<int> rowid,
    });
typedef $$ReminderRecordsTableUpdateCompanionBuilder =
    ReminderRecordsCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<DateTime> scheduledAt,
      Value<bool> isEnabled,
      Value<int> rowid,
    });

class $$ReminderRecordsTableFilterComposer
    extends Composer<_$QDoneDatabase, $ReminderRecordsTable> {
  $$ReminderRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderRecordsTableOrderingComposer
    extends Composer<_$QDoneDatabase, $ReminderRecordsTable> {
  $$ReminderRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderRecordsTableAnnotationComposer
    extends Composer<_$QDoneDatabase, $ReminderRecordsTable> {
  $$ReminderRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);
}

class $$ReminderRecordsTableTableManager
    extends
        RootTableManager<
          _$QDoneDatabase,
          $ReminderRecordsTable,
          ReminderRecord,
          $$ReminderRecordsTableFilterComposer,
          $$ReminderRecordsTableOrderingComposer,
          $$ReminderRecordsTableAnnotationComposer,
          $$ReminderRecordsTableCreateCompanionBuilder,
          $$ReminderRecordsTableUpdateCompanionBuilder,
          (
            ReminderRecord,
            BaseReferences<
              _$QDoneDatabase,
              $ReminderRecordsTable,
              ReminderRecord
            >,
          ),
          ReminderRecord,
          PrefetchHooks Function()
        > {
  $$ReminderRecordsTableTableManager(
    _$QDoneDatabase db,
    $ReminderRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRecordsCompanion(
                id: id,
                taskId: taskId,
                scheduledAt: scheduledAt,
                isEnabled: isEnabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required DateTime scheduledAt,
                Value<bool> isEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRecordsCompanion.insert(
                id: id,
                taskId: taskId,
                scheduledAt: scheduledAt,
                isEnabled: isEnabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$QDoneDatabase,
      $ReminderRecordsTable,
      ReminderRecord,
      $$ReminderRecordsTableFilterComposer,
      $$ReminderRecordsTableOrderingComposer,
      $$ReminderRecordsTableAnnotationComposer,
      $$ReminderRecordsTableCreateCompanionBuilder,
      $$ReminderRecordsTableUpdateCompanionBuilder,
      (
        ReminderRecord,
        BaseReferences<_$QDoneDatabase, $ReminderRecordsTable, ReminderRecord>,
      ),
      ReminderRecord,
      PrefetchHooks Function()
    >;
typedef $$NotificationScheduleRecordsTableCreateCompanionBuilder =
    NotificationScheduleRecordsCompanion Function({
      Value<int> notificationId,
      required String taskId,
      Value<String?> reminderId,
      required DateTime scheduledAt,
      required String fingerprint,
      required String scheduleMode,
    });
typedef $$NotificationScheduleRecordsTableUpdateCompanionBuilder =
    NotificationScheduleRecordsCompanion Function({
      Value<int> notificationId,
      Value<String> taskId,
      Value<String?> reminderId,
      Value<DateTime> scheduledAt,
      Value<String> fingerprint,
      Value<String> scheduleMode,
    });

class $$NotificationScheduleRecordsTableFilterComposer
    extends Composer<_$QDoneDatabase, $NotificationScheduleRecordsTable> {
  $$NotificationScheduleRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleMode => $composableBuilder(
    column: $table.scheduleMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationScheduleRecordsTableOrderingComposer
    extends Composer<_$QDoneDatabase, $NotificationScheduleRecordsTable> {
  $$NotificationScheduleRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleMode => $composableBuilder(
    column: $table.scheduleMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationScheduleRecordsTableAnnotationComposer
    extends Composer<_$QDoneDatabase, $NotificationScheduleRecordsTable> {
  $$NotificationScheduleRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleMode => $composableBuilder(
    column: $table.scheduleMode,
    builder: (column) => column,
  );
}

class $$NotificationScheduleRecordsTableTableManager
    extends
        RootTableManager<
          _$QDoneDatabase,
          $NotificationScheduleRecordsTable,
          NotificationScheduleRecord,
          $$NotificationScheduleRecordsTableFilterComposer,
          $$NotificationScheduleRecordsTableOrderingComposer,
          $$NotificationScheduleRecordsTableAnnotationComposer,
          $$NotificationScheduleRecordsTableCreateCompanionBuilder,
          $$NotificationScheduleRecordsTableUpdateCompanionBuilder,
          (
            NotificationScheduleRecord,
            BaseReferences<
              _$QDoneDatabase,
              $NotificationScheduleRecordsTable,
              NotificationScheduleRecord
            >,
          ),
          NotificationScheduleRecord,
          PrefetchHooks Function()
        > {
  $$NotificationScheduleRecordsTableTableManager(
    _$QDoneDatabase db,
    $NotificationScheduleRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationScheduleRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NotificationScheduleRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationScheduleRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> notificationId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String?> reminderId = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<String> scheduleMode = const Value.absent(),
              }) => NotificationScheduleRecordsCompanion(
                notificationId: notificationId,
                taskId: taskId,
                reminderId: reminderId,
                scheduledAt: scheduledAt,
                fingerprint: fingerprint,
                scheduleMode: scheduleMode,
              ),
          createCompanionCallback:
              ({
                Value<int> notificationId = const Value.absent(),
                required String taskId,
                Value<String?> reminderId = const Value.absent(),
                required DateTime scheduledAt,
                required String fingerprint,
                required String scheduleMode,
              }) => NotificationScheduleRecordsCompanion.insert(
                notificationId: notificationId,
                taskId: taskId,
                reminderId: reminderId,
                scheduledAt: scheduledAt,
                fingerprint: fingerprint,
                scheduleMode: scheduleMode,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationScheduleRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$QDoneDatabase,
      $NotificationScheduleRecordsTable,
      NotificationScheduleRecord,
      $$NotificationScheduleRecordsTableFilterComposer,
      $$NotificationScheduleRecordsTableOrderingComposer,
      $$NotificationScheduleRecordsTableAnnotationComposer,
      $$NotificationScheduleRecordsTableCreateCompanionBuilder,
      $$NotificationScheduleRecordsTableUpdateCompanionBuilder,
      (
        NotificationScheduleRecord,
        BaseReferences<
          _$QDoneDatabase,
          $NotificationScheduleRecordsTable,
          NotificationScheduleRecord
        >,
      ),
      NotificationScheduleRecord,
      PrefetchHooks Function()
    >;
typedef $$MetadataRecordsTableCreateCompanionBuilder =
    MetadataRecordsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$MetadataRecordsTableUpdateCompanionBuilder =
    MetadataRecordsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$MetadataRecordsTableFilterComposer
    extends Composer<_$QDoneDatabase, $MetadataRecordsTable> {
  $$MetadataRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetadataRecordsTableOrderingComposer
    extends Composer<_$QDoneDatabase, $MetadataRecordsTable> {
  $$MetadataRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetadataRecordsTableAnnotationComposer
    extends Composer<_$QDoneDatabase, $MetadataRecordsTable> {
  $$MetadataRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetadataRecordsTableTableManager
    extends
        RootTableManager<
          _$QDoneDatabase,
          $MetadataRecordsTable,
          MetadataRecord,
          $$MetadataRecordsTableFilterComposer,
          $$MetadataRecordsTableOrderingComposer,
          $$MetadataRecordsTableAnnotationComposer,
          $$MetadataRecordsTableCreateCompanionBuilder,
          $$MetadataRecordsTableUpdateCompanionBuilder,
          (
            MetadataRecord,
            BaseReferences<
              _$QDoneDatabase,
              $MetadataRecordsTable,
              MetadataRecord
            >,
          ),
          MetadataRecord,
          PrefetchHooks Function()
        > {
  $$MetadataRecordsTableTableManager(
    _$QDoneDatabase db,
    $MetadataRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetadataRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetadataRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetadataRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetadataRecordsCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetadataRecordsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetadataRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$QDoneDatabase,
      $MetadataRecordsTable,
      MetadataRecord,
      $$MetadataRecordsTableFilterComposer,
      $$MetadataRecordsTableOrderingComposer,
      $$MetadataRecordsTableAnnotationComposer,
      $$MetadataRecordsTableCreateCompanionBuilder,
      $$MetadataRecordsTableUpdateCompanionBuilder,
      (
        MetadataRecord,
        BaseReferences<_$QDoneDatabase, $MetadataRecordsTable, MetadataRecord>,
      ),
      MetadataRecord,
      PrefetchHooks Function()
    >;

class $QDoneDatabaseManager {
  final _$QDoneDatabase _db;
  $QDoneDatabaseManager(this._db);
  $$TaskRecordsTableTableManager get taskRecords =>
      $$TaskRecordsTableTableManager(_db, _db.taskRecords);
  $$ReminderRecordsTableTableManager get reminderRecords =>
      $$ReminderRecordsTableTableManager(_db, _db.reminderRecords);
  $$NotificationScheduleRecordsTableTableManager
  get notificationScheduleRecords =>
      $$NotificationScheduleRecordsTableTableManager(
        _db,
        _db.notificationScheduleRecords,
      );
  $$MetadataRecordsTableTableManager get metadataRecords =>
      $$MetadataRecordsTableTableManager(_db, _db.metadataRecords);
}
