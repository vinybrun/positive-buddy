// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    createdAt,
    completedAt,
    archivedAt,
    displayOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;

  /// Set when the user (or the heuristic + user confirm in Phase 5)
  /// declares the goal achieved. Active goals have this null.
  final DateTime? completedAt;

  /// v11: distinct from completedAt — set when the user gives up on / removes
  /// a goal mid-flight (the orphan-cleanup in the goal wizard also uses this).
  /// Graduated and archived goals were indistinguishable before v11.
  final DateTime? archivedAt;
  final int displayOrder;
  const Goal({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.completedAt,
    this.archivedAt,
    required this.displayOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['display_order'] = Variable<int>(displayOrder);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      displayOrder: Value(displayOrder),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'displayOrder': serializer.toJson<int>(displayOrder),
    };
  }

  Goal copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
    int? displayOrder,
  }) => Goal(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    displayOrder: displayOrder ?? this.displayOrder,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    createdAt,
    completedAt,
    archivedAt,
    displayOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.archivedAt == this.archivedAt &&
          other.displayOrder == this.displayOrder);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> displayOrder;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<Goal> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? displayOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (displayOrder != null) 'display_order': displayOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? displayOrder,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      displayOrder: displayOrder ?? this.displayOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customMessageMeta = const VerificationMeta(
    'customMessage',
  );
  @override
  late final GeneratedColumn<String> customMessage = GeneratedColumn<String>(
    'custom_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alarmStyleMeta = const VerificationMeta(
    'alarmStyle',
  );
  @override
  late final GeneratedColumn<String> alarmStyle = GeneratedColumn<String>(
    'alarm_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('flexible'),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _timeWindowMeta = const VerificationMeta(
    'timeWindow',
  );
  @override
  late final GeneratedColumn<String> timeWindow = GeneratedColumn<String>(
    'time_window',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('anytime'),
  );
  static const VerificationMeta _timeWindowsJsonMeta = const VerificationMeta(
    'timeWindowsJson',
  );
  @override
  late final GeneratedColumn<String> timeWindowsJson = GeneratedColumn<String>(
    'time_windows_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('["anytime"]'),
  );
  static const VerificationMeta _customStartMinutesMeta =
      const VerificationMeta('customStartMinutes');
  @override
  late final GeneratedColumn<int> customStartMinutes = GeneratedColumn<int>(
    'custom_start_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customEndMinutesMeta = const VerificationMeta(
    'customEndMinutes',
  );
  @override
  late final GeneratedColumn<int> customEndMinutes = GeneratedColumn<int>(
    'custom_end_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetPerWeekMeta = const VerificationMeta(
    'targetPerWeek',
  );
  @override
  late final GeneratedColumn<int> targetPerWeek = GeneratedColumn<int>(
    'target_per_week',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredWeekdayMeta = const VerificationMeta(
    'preferredWeekday',
  );
  @override
  late final GeneratedColumn<int> preferredWeekday = GeneratedColumn<int>(
    'preferred_weekday',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goalId,
    name,
    category,
    customMessage,
    kind,
    alarmStyle,
    active,
    completedAt,
    timeWindow,
    timeWindowsJson,
    customStartMinutes,
    customEndMinutes,
    targetPerWeek,
    preferredWeekday,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('custom_message')) {
      context.handle(
        _customMessageMeta,
        customMessage.isAcceptableOrUnknown(
          data['custom_message']!,
          _customMessageMeta,
        ),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('alarm_style')) {
      context.handle(
        _alarmStyleMeta,
        alarmStyle.isAcceptableOrUnknown(data['alarm_style']!, _alarmStyleMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
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
    if (data.containsKey('time_window')) {
      context.handle(
        _timeWindowMeta,
        timeWindow.isAcceptableOrUnknown(data['time_window']!, _timeWindowMeta),
      );
    }
    if (data.containsKey('time_windows_json')) {
      context.handle(
        _timeWindowsJsonMeta,
        timeWindowsJson.isAcceptableOrUnknown(
          data['time_windows_json']!,
          _timeWindowsJsonMeta,
        ),
      );
    }
    if (data.containsKey('custom_start_minutes')) {
      context.handle(
        _customStartMinutesMeta,
        customStartMinutes.isAcceptableOrUnknown(
          data['custom_start_minutes']!,
          _customStartMinutesMeta,
        ),
      );
    }
    if (data.containsKey('custom_end_minutes')) {
      context.handle(
        _customEndMinutesMeta,
        customEndMinutes.isAcceptableOrUnknown(
          data['custom_end_minutes']!,
          _customEndMinutesMeta,
        ),
      );
    }
    if (data.containsKey('target_per_week')) {
      context.handle(
        _targetPerWeekMeta,
        targetPerWeek.isAcceptableOrUnknown(
          data['target_per_week']!,
          _targetPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('preferred_weekday')) {
      context.handle(
        _preferredWeekdayMeta,
        preferredWeekday.isAcceptableOrUnknown(
          data['preferred_weekday']!,
          _preferredWeekdayMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      customMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_message'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      alarmStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alarm_style'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      timeWindow: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_window'],
      )!,
      timeWindowsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_windows_json'],
      )!,
      customStartMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_start_minutes'],
      ),
      customEndMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_end_minutes'],
      ),
      targetPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_per_week'],
      ),
      preferredWeekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preferred_weekday'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final String id;

  /// v6: every habit is tied to a goal. Nullable in the column for
  /// migration safety / defensive reads of legacy rows; the UI requires
  /// a goal at creation time.
  final String? goalId;
  final String name;
  final String category;
  final String? customMessage;
  final String kind;

  /// v10: for 'time' kind, how the alarm fires:
  /// - 'flexible' (default): engine picks the time within the chosen window
  /// - 'fixed': user picks exact time(s) — stored as 'time' slots
  /// Ignored for 'freq' (those are always engine-shifted priming).
  final String alarmStyle;
  final bool active;

  /// v6: set when the user graduates the habit (Phase 5). Active habits
  /// have this null; once set the habit is hidden from Today and lives
  /// in the Completed section.
  final DateTime? completedAt;
  final String timeWindow;
  final String timeWindowsJson;
  final int? customStartMinutes;
  final int? customEndMinutes;
  final int? targetPerWeek;

  /// Phase 3: optional preferred day-of-week for frequency habits (1..7,
  /// Mon..Sun). The smart scheduler picks the time of day; this column
  /// lets the user pin the day. Null = "any day works".
  final int? preferredWeekday;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Habit({
    required this.id,
    this.goalId,
    required this.name,
    required this.category,
    this.customMessage,
    required this.kind,
    required this.alarmStyle,
    required this.active,
    this.completedAt,
    required this.timeWindow,
    required this.timeWindowsJson,
    this.customStartMinutes,
    this.customEndMinutes,
    this.targetPerWeek,
    this.preferredWeekday,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || goalId != null) {
      map['goal_id'] = Variable<String>(goalId);
    }
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || customMessage != null) {
      map['custom_message'] = Variable<String>(customMessage);
    }
    map['kind'] = Variable<String>(kind);
    map['alarm_style'] = Variable<String>(alarmStyle);
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['time_window'] = Variable<String>(timeWindow);
    map['time_windows_json'] = Variable<String>(timeWindowsJson);
    if (!nullToAbsent || customStartMinutes != null) {
      map['custom_start_minutes'] = Variable<int>(customStartMinutes);
    }
    if (!nullToAbsent || customEndMinutes != null) {
      map['custom_end_minutes'] = Variable<int>(customEndMinutes);
    }
    if (!nullToAbsent || targetPerWeek != null) {
      map['target_per_week'] = Variable<int>(targetPerWeek);
    }
    if (!nullToAbsent || preferredWeekday != null) {
      map['preferred_weekday'] = Variable<int>(preferredWeekday);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      goalId: goalId == null && nullToAbsent
          ? const Value.absent()
          : Value(goalId),
      name: Value(name),
      category: Value(category),
      customMessage: customMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(customMessage),
      kind: Value(kind),
      alarmStyle: Value(alarmStyle),
      active: Value(active),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      timeWindow: Value(timeWindow),
      timeWindowsJson: Value(timeWindowsJson),
      customStartMinutes: customStartMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(customStartMinutes),
      customEndMinutes: customEndMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(customEndMinutes),
      targetPerWeek: targetPerWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPerWeek),
      preferredWeekday: preferredWeekday == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredWeekday),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<String>(json['id']),
      goalId: serializer.fromJson<String?>(json['goalId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      customMessage: serializer.fromJson<String?>(json['customMessage']),
      kind: serializer.fromJson<String>(json['kind']),
      alarmStyle: serializer.fromJson<String>(json['alarmStyle']),
      active: serializer.fromJson<bool>(json['active']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      timeWindow: serializer.fromJson<String>(json['timeWindow']),
      timeWindowsJson: serializer.fromJson<String>(json['timeWindowsJson']),
      customStartMinutes: serializer.fromJson<int?>(json['customStartMinutes']),
      customEndMinutes: serializer.fromJson<int?>(json['customEndMinutes']),
      targetPerWeek: serializer.fromJson<int?>(json['targetPerWeek']),
      preferredWeekday: serializer.fromJson<int?>(json['preferredWeekday']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'goalId': serializer.toJson<String?>(goalId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'customMessage': serializer.toJson<String?>(customMessage),
      'kind': serializer.toJson<String>(kind),
      'alarmStyle': serializer.toJson<String>(alarmStyle),
      'active': serializer.toJson<bool>(active),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'timeWindow': serializer.toJson<String>(timeWindow),
      'timeWindowsJson': serializer.toJson<String>(timeWindowsJson),
      'customStartMinutes': serializer.toJson<int?>(customStartMinutes),
      'customEndMinutes': serializer.toJson<int?>(customEndMinutes),
      'targetPerWeek': serializer.toJson<int?>(targetPerWeek),
      'preferredWeekday': serializer.toJson<int?>(preferredWeekday),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Habit copyWith({
    String? id,
    Value<String?> goalId = const Value.absent(),
    String? name,
    String? category,
    Value<String?> customMessage = const Value.absent(),
    String? kind,
    String? alarmStyle,
    bool? active,
    Value<DateTime?> completedAt = const Value.absent(),
    String? timeWindow,
    String? timeWindowsJson,
    Value<int?> customStartMinutes = const Value.absent(),
    Value<int?> customEndMinutes = const Value.absent(),
    Value<int?> targetPerWeek = const Value.absent(),
    Value<int?> preferredWeekday = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Habit(
    id: id ?? this.id,
    goalId: goalId.present ? goalId.value : this.goalId,
    name: name ?? this.name,
    category: category ?? this.category,
    customMessage: customMessage.present
        ? customMessage.value
        : this.customMessage,
    kind: kind ?? this.kind,
    alarmStyle: alarmStyle ?? this.alarmStyle,
    active: active ?? this.active,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    timeWindow: timeWindow ?? this.timeWindow,
    timeWindowsJson: timeWindowsJson ?? this.timeWindowsJson,
    customStartMinutes: customStartMinutes.present
        ? customStartMinutes.value
        : this.customStartMinutes,
    customEndMinutes: customEndMinutes.present
        ? customEndMinutes.value
        : this.customEndMinutes,
    targetPerWeek: targetPerWeek.present
        ? targetPerWeek.value
        : this.targetPerWeek,
    preferredWeekday: preferredWeekday.present
        ? preferredWeekday.value
        : this.preferredWeekday,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      customMessage: data.customMessage.present
          ? data.customMessage.value
          : this.customMessage,
      kind: data.kind.present ? data.kind.value : this.kind,
      alarmStyle: data.alarmStyle.present
          ? data.alarmStyle.value
          : this.alarmStyle,
      active: data.active.present ? data.active.value : this.active,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      timeWindow: data.timeWindow.present
          ? data.timeWindow.value
          : this.timeWindow,
      timeWindowsJson: data.timeWindowsJson.present
          ? data.timeWindowsJson.value
          : this.timeWindowsJson,
      customStartMinutes: data.customStartMinutes.present
          ? data.customStartMinutes.value
          : this.customStartMinutes,
      customEndMinutes: data.customEndMinutes.present
          ? data.customEndMinutes.value
          : this.customEndMinutes,
      targetPerWeek: data.targetPerWeek.present
          ? data.targetPerWeek.value
          : this.targetPerWeek,
      preferredWeekday: data.preferredWeekday.present
          ? data.preferredWeekday.value
          : this.preferredWeekday,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('customMessage: $customMessage, ')
          ..write('kind: $kind, ')
          ..write('alarmStyle: $alarmStyle, ')
          ..write('active: $active, ')
          ..write('completedAt: $completedAt, ')
          ..write('timeWindow: $timeWindow, ')
          ..write('timeWindowsJson: $timeWindowsJson, ')
          ..write('customStartMinutes: $customStartMinutes, ')
          ..write('customEndMinutes: $customEndMinutes, ')
          ..write('targetPerWeek: $targetPerWeek, ')
          ..write('preferredWeekday: $preferredWeekday, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    goalId,
    name,
    category,
    customMessage,
    kind,
    alarmStyle,
    active,
    completedAt,
    timeWindow,
    timeWindowsJson,
    customStartMinutes,
    customEndMinutes,
    targetPerWeek,
    preferredWeekday,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.name == this.name &&
          other.category == this.category &&
          other.customMessage == this.customMessage &&
          other.kind == this.kind &&
          other.alarmStyle == this.alarmStyle &&
          other.active == this.active &&
          other.completedAt == this.completedAt &&
          other.timeWindow == this.timeWindow &&
          other.timeWindowsJson == this.timeWindowsJson &&
          other.customStartMinutes == this.customStartMinutes &&
          other.customEndMinutes == this.customEndMinutes &&
          other.targetPerWeek == this.targetPerWeek &&
          other.preferredWeekday == this.preferredWeekday &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<String> id;
  final Value<String?> goalId;
  final Value<String> name;
  final Value<String> category;
  final Value<String?> customMessage;
  final Value<String> kind;
  final Value<String> alarmStyle;
  final Value<bool> active;
  final Value<DateTime?> completedAt;
  final Value<String> timeWindow;
  final Value<String> timeWindowsJson;
  final Value<int?> customStartMinutes;
  final Value<int?> customEndMinutes;
  final Value<int?> targetPerWeek;
  final Value<int?> preferredWeekday;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.customMessage = const Value.absent(),
    this.kind = const Value.absent(),
    this.alarmStyle = const Value.absent(),
    this.active = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.timeWindow = const Value.absent(),
    this.timeWindowsJson = const Value.absent(),
    this.customStartMinutes = const Value.absent(),
    this.customEndMinutes = const Value.absent(),
    this.targetPerWeek = const Value.absent(),
    this.preferredWeekday = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    this.goalId = const Value.absent(),
    required String name,
    required String category,
    this.customMessage = const Value.absent(),
    required String kind,
    this.alarmStyle = const Value.absent(),
    this.active = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.timeWindow = const Value.absent(),
    this.timeWindowsJson = const Value.absent(),
    this.customStartMinutes = const Value.absent(),
    this.customEndMinutes = const Value.absent(),
    this.targetPerWeek = const Value.absent(),
    this.preferredWeekday = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       kind = Value(kind),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Habit> custom({
    Expression<String>? id,
    Expression<String>? goalId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? customMessage,
    Expression<String>? kind,
    Expression<String>? alarmStyle,
    Expression<bool>? active,
    Expression<DateTime>? completedAt,
    Expression<String>? timeWindow,
    Expression<String>? timeWindowsJson,
    Expression<int>? customStartMinutes,
    Expression<int>? customEndMinutes,
    Expression<int>? targetPerWeek,
    Expression<int>? preferredWeekday,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (customMessage != null) 'custom_message': customMessage,
      if (kind != null) 'kind': kind,
      if (alarmStyle != null) 'alarm_style': alarmStyle,
      if (active != null) 'active': active,
      if (completedAt != null) 'completed_at': completedAt,
      if (timeWindow != null) 'time_window': timeWindow,
      if (timeWindowsJson != null) 'time_windows_json': timeWindowsJson,
      if (customStartMinutes != null)
        'custom_start_minutes': customStartMinutes,
      if (customEndMinutes != null) 'custom_end_minutes': customEndMinutes,
      if (targetPerWeek != null) 'target_per_week': targetPerWeek,
      if (preferredWeekday != null) 'preferred_weekday': preferredWeekday,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<String>? id,
    Value<String?>? goalId,
    Value<String>? name,
    Value<String>? category,
    Value<String?>? customMessage,
    Value<String>? kind,
    Value<String>? alarmStyle,
    Value<bool>? active,
    Value<DateTime?>? completedAt,
    Value<String>? timeWindow,
    Value<String>? timeWindowsJson,
    Value<int?>? customStartMinutes,
    Value<int?>? customEndMinutes,
    Value<int?>? targetPerWeek,
    Value<int?>? preferredWeekday,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      name: name ?? this.name,
      category: category ?? this.category,
      customMessage: customMessage ?? this.customMessage,
      kind: kind ?? this.kind,
      alarmStyle: alarmStyle ?? this.alarmStyle,
      active: active ?? this.active,
      completedAt: completedAt ?? this.completedAt,
      timeWindow: timeWindow ?? this.timeWindow,
      timeWindowsJson: timeWindowsJson ?? this.timeWindowsJson,
      customStartMinutes: customStartMinutes ?? this.customStartMinutes,
      customEndMinutes: customEndMinutes ?? this.customEndMinutes,
      targetPerWeek: targetPerWeek ?? this.targetPerWeek,
      preferredWeekday: preferredWeekday ?? this.preferredWeekday,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (customMessage.present) {
      map['custom_message'] = Variable<String>(customMessage.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (alarmStyle.present) {
      map['alarm_style'] = Variable<String>(alarmStyle.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (timeWindow.present) {
      map['time_window'] = Variable<String>(timeWindow.value);
    }
    if (timeWindowsJson.present) {
      map['time_windows_json'] = Variable<String>(timeWindowsJson.value);
    }
    if (customStartMinutes.present) {
      map['custom_start_minutes'] = Variable<int>(customStartMinutes.value);
    }
    if (customEndMinutes.present) {
      map['custom_end_minutes'] = Variable<int>(customEndMinutes.value);
    }
    if (targetPerWeek.present) {
      map['target_per_week'] = Variable<int>(targetPerWeek.value);
    }
    if (preferredWeekday.present) {
      map['preferred_weekday'] = Variable<int>(preferredWeekday.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('customMessage: $customMessage, ')
          ..write('kind: $kind, ')
          ..write('alarmStyle: $alarmStyle, ')
          ..write('active: $active, ')
          ..write('completedAt: $completedAt, ')
          ..write('timeWindow: $timeWindow, ')
          ..write('timeWindowsJson: $timeWindowsJson, ')
          ..write('customStartMinutes: $customStartMinutes, ')
          ..write('customEndMinutes: $customEndMinutes, ')
          ..write('targetPerWeek: $targetPerWeek, ')
          ..write('preferredWeekday: $preferredWeekday, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleSlotsTable extends ScheduleSlots
    with TableInfo<$ScheduleSlotsTable, ScheduleSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeOfDayMeta = const VerificationMeta(
    'timeOfDay',
  );
  @override
  late final GeneratedColumn<int> timeOfDay = GeneratedColumn<int>(
    'time_of_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayMaskMeta = const VerificationMeta(
    'weekdayMask',
  );
  @override
  late final GeneratedColumn<int> weekdayMask = GeneratedColumn<int>(
    'weekday_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0x7F),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    kind,
    timeOfDay,
    weekdayMask,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleSlot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('time_of_day')) {
      context.handle(
        _timeOfDayMeta,
        timeOfDay.isAcceptableOrUnknown(data['time_of_day']!, _timeOfDayMeta),
      );
    } else if (isInserting) {
      context.missing(_timeOfDayMeta);
    }
    if (data.containsKey('weekday_mask')) {
      context.handle(
        _weekdayMaskMeta,
        weekdayMask.isAcceptableOrUnknown(
          data['weekday_mask']!,
          _weekdayMaskMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleSlot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      timeOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_of_day'],
      )!,
      weekdayMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday_mask'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $ScheduleSlotsTable createAlias(String alias) {
    return $ScheduleSlotsTable(attachedDatabase, alias);
  }
}

class ScheduleSlot extends DataClass implements Insertable<ScheduleSlot> {
  final int id;
  final String habitId;
  final String kind;
  final int timeOfDay;
  final int weekdayMask;
  final bool enabled;
  const ScheduleSlot({
    required this.id,
    required this.habitId,
    required this.kind,
    required this.timeOfDay,
    required this.weekdayMask,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['kind'] = Variable<String>(kind);
    map['time_of_day'] = Variable<int>(timeOfDay);
    map['weekday_mask'] = Variable<int>(weekdayMask);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  ScheduleSlotsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleSlotsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      kind: Value(kind),
      timeOfDay: Value(timeOfDay),
      weekdayMask: Value(weekdayMask),
      enabled: Value(enabled),
    );
  }

  factory ScheduleSlot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleSlot(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      kind: serializer.fromJson<String>(json['kind']),
      timeOfDay: serializer.fromJson<int>(json['timeOfDay']),
      weekdayMask: serializer.fromJson<int>(json['weekdayMask']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<String>(habitId),
      'kind': serializer.toJson<String>(kind),
      'timeOfDay': serializer.toJson<int>(timeOfDay),
      'weekdayMask': serializer.toJson<int>(weekdayMask),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  ScheduleSlot copyWith({
    int? id,
    String? habitId,
    String? kind,
    int? timeOfDay,
    int? weekdayMask,
    bool? enabled,
  }) => ScheduleSlot(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    kind: kind ?? this.kind,
    timeOfDay: timeOfDay ?? this.timeOfDay,
    weekdayMask: weekdayMask ?? this.weekdayMask,
    enabled: enabled ?? this.enabled,
  );
  ScheduleSlot copyWithCompanion(ScheduleSlotsCompanion data) {
    return ScheduleSlot(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      kind: data.kind.present ? data.kind.value : this.kind,
      timeOfDay: data.timeOfDay.present ? data.timeOfDay.value : this.timeOfDay,
      weekdayMask: data.weekdayMask.present
          ? data.weekdayMask.value
          : this.weekdayMask,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleSlot(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('kind: $kind, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, habitId, kind, timeOfDay, weekdayMask, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleSlot &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.kind == this.kind &&
          other.timeOfDay == this.timeOfDay &&
          other.weekdayMask == this.weekdayMask &&
          other.enabled == this.enabled);
}

class ScheduleSlotsCompanion extends UpdateCompanion<ScheduleSlot> {
  final Value<int> id;
  final Value<String> habitId;
  final Value<String> kind;
  final Value<int> timeOfDay;
  final Value<int> weekdayMask;
  final Value<bool> enabled;
  const ScheduleSlotsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.kind = const Value.absent(),
    this.timeOfDay = const Value.absent(),
    this.weekdayMask = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  ScheduleSlotsCompanion.insert({
    this.id = const Value.absent(),
    required String habitId,
    required String kind,
    required int timeOfDay,
    this.weekdayMask = const Value.absent(),
    this.enabled = const Value.absent(),
  }) : habitId = Value(habitId),
       kind = Value(kind),
       timeOfDay = Value(timeOfDay);
  static Insertable<ScheduleSlot> custom({
    Expression<int>? id,
    Expression<String>? habitId,
    Expression<String>? kind,
    Expression<int>? timeOfDay,
    Expression<int>? weekdayMask,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (kind != null) 'kind': kind,
      if (timeOfDay != null) 'time_of_day': timeOfDay,
      if (weekdayMask != null) 'weekday_mask': weekdayMask,
      if (enabled != null) 'enabled': enabled,
    });
  }

  ScheduleSlotsCompanion copyWith({
    Value<int>? id,
    Value<String>? habitId,
    Value<String>? kind,
    Value<int>? timeOfDay,
    Value<int>? weekdayMask,
    Value<bool>? enabled,
  }) {
    return ScheduleSlotsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      kind: kind ?? this.kind,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      weekdayMask: weekdayMask ?? this.weekdayMask,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (timeOfDay.present) {
      map['time_of_day'] = Variable<int>(timeOfDay.value);
    }
    if (weekdayMask.present) {
      map['weekday_mask'] = Variable<int>(weekdayMask.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleSlotsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('kind: $kind, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

class $NotificationLogTable extends NotificationLog
    with TableInfo<$NotificationLogTable, NotificationLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id)',
    ),
  );
  static const VerificationMeta _scheduledForMeta = const VerificationMeta(
    'scheduledFor',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
    'scheduled_for',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firedAtMeta = const VerificationMeta(
    'firedAt',
  );
  @override
  late final GeneratedColumn<DateTime> firedAt = GeneratedColumn<DateTime>(
    'fired_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _responseMeta = const VerificationMeta(
    'response',
  );
  @override
  late final GeneratedColumn<String> response = GeneratedColumn<String>(
    'response',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respondedAtMeta = const VerificationMeta(
    'respondedAt',
  );
  @override
  late final GeneratedColumn<DateTime> respondedAt = GeneratedColumn<DateTime>(
    'responded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toneUsedMeta = const VerificationMeta(
    'toneUsed',
  );
  @override
  late final GeneratedColumn<String> toneUsed = GeneratedColumn<String>(
    'tone_used',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    scheduledFor,
    firedAt,
    response,
    respondedAt,
    source,
    toneUsed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
        _scheduledForMeta,
        scheduledFor.isAcceptableOrUnknown(
          data['scheduled_for']!,
          _scheduledForMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledForMeta);
    }
    if (data.containsKey('fired_at')) {
      context.handle(
        _firedAtMeta,
        firedAt.isAcceptableOrUnknown(data['fired_at']!, _firedAtMeta),
      );
    }
    if (data.containsKey('response')) {
      context.handle(
        _responseMeta,
        response.isAcceptableOrUnknown(data['response']!, _responseMeta),
      );
    } else if (isInserting) {
      context.missing(_responseMeta);
    }
    if (data.containsKey('responded_at')) {
      context.handle(
        _respondedAtMeta,
        respondedAt.isAcceptableOrUnknown(
          data['responded_at']!,
          _respondedAtMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('tone_used')) {
      context.handle(
        _toneUsedMeta,
        toneUsed.isAcceptableOrUnknown(data['tone_used']!, _toneUsedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      scheduledFor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_for'],
      )!,
      firedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fired_at'],
      ),
      response: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response'],
      )!,
      respondedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}responded_at'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      toneUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tone_used'],
      ),
    );
  }

  @override
  $NotificationLogTable createAlias(String alias) {
    return $NotificationLogTable(attachedDatabase, alias);
  }
}

class NotificationLogData extends DataClass
    implements Insertable<NotificationLogData> {
  final int id;
  final String habitId;
  final DateTime scheduledFor;
  final DateTime? firedAt;
  final String response;
  final DateTime? respondedAt;
  final String source;
  final String? toneUsed;
  const NotificationLogData({
    required this.id,
    required this.habitId,
    required this.scheduledFor,
    this.firedAt,
    required this.response,
    this.respondedAt,
    required this.source,
    this.toneUsed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    if (!nullToAbsent || firedAt != null) {
      map['fired_at'] = Variable<DateTime>(firedAt);
    }
    map['response'] = Variable<String>(response);
    if (!nullToAbsent || respondedAt != null) {
      map['responded_at'] = Variable<DateTime>(respondedAt);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || toneUsed != null) {
      map['tone_used'] = Variable<String>(toneUsed);
    }
    return map;
  }

  NotificationLogCompanion toCompanion(bool nullToAbsent) {
    return NotificationLogCompanion(
      id: Value(id),
      habitId: Value(habitId),
      scheduledFor: Value(scheduledFor),
      firedAt: firedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firedAt),
      response: Value(response),
      respondedAt: respondedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(respondedAt),
      source: Value(source),
      toneUsed: toneUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(toneUsed),
    );
  }

  factory NotificationLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationLogData(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      scheduledFor: serializer.fromJson<DateTime>(json['scheduledFor']),
      firedAt: serializer.fromJson<DateTime?>(json['firedAt']),
      response: serializer.fromJson<String>(json['response']),
      respondedAt: serializer.fromJson<DateTime?>(json['respondedAt']),
      source: serializer.fromJson<String>(json['source']),
      toneUsed: serializer.fromJson<String?>(json['toneUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<String>(habitId),
      'scheduledFor': serializer.toJson<DateTime>(scheduledFor),
      'firedAt': serializer.toJson<DateTime?>(firedAt),
      'response': serializer.toJson<String>(response),
      'respondedAt': serializer.toJson<DateTime?>(respondedAt),
      'source': serializer.toJson<String>(source),
      'toneUsed': serializer.toJson<String?>(toneUsed),
    };
  }

  NotificationLogData copyWith({
    int? id,
    String? habitId,
    DateTime? scheduledFor,
    Value<DateTime?> firedAt = const Value.absent(),
    String? response,
    Value<DateTime?> respondedAt = const Value.absent(),
    String? source,
    Value<String?> toneUsed = const Value.absent(),
  }) => NotificationLogData(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    scheduledFor: scheduledFor ?? this.scheduledFor,
    firedAt: firedAt.present ? firedAt.value : this.firedAt,
    response: response ?? this.response,
    respondedAt: respondedAt.present ? respondedAt.value : this.respondedAt,
    source: source ?? this.source,
    toneUsed: toneUsed.present ? toneUsed.value : this.toneUsed,
  );
  NotificationLogData copyWithCompanion(NotificationLogCompanion data) {
    return NotificationLogData(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
      firedAt: data.firedAt.present ? data.firedAt.value : this.firedAt,
      response: data.response.present ? data.response.value : this.response,
      respondedAt: data.respondedAt.present
          ? data.respondedAt.value
          : this.respondedAt,
      source: data.source.present ? data.source.value : this.source,
      toneUsed: data.toneUsed.present ? data.toneUsed.value : this.toneUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogData(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('firedAt: $firedAt, ')
          ..write('response: $response, ')
          ..write('respondedAt: $respondedAt, ')
          ..write('source: $source, ')
          ..write('toneUsed: $toneUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    habitId,
    scheduledFor,
    firedAt,
    response,
    respondedAt,
    source,
    toneUsed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationLogData &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.scheduledFor == this.scheduledFor &&
          other.firedAt == this.firedAt &&
          other.response == this.response &&
          other.respondedAt == this.respondedAt &&
          other.source == this.source &&
          other.toneUsed == this.toneUsed);
}

class NotificationLogCompanion extends UpdateCompanion<NotificationLogData> {
  final Value<int> id;
  final Value<String> habitId;
  final Value<DateTime> scheduledFor;
  final Value<DateTime?> firedAt;
  final Value<String> response;
  final Value<DateTime?> respondedAt;
  final Value<String> source;
  final Value<String?> toneUsed;
  const NotificationLogCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.firedAt = const Value.absent(),
    this.response = const Value.absent(),
    this.respondedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.toneUsed = const Value.absent(),
  });
  NotificationLogCompanion.insert({
    this.id = const Value.absent(),
    required String habitId,
    required DateTime scheduledFor,
    this.firedAt = const Value.absent(),
    required String response,
    this.respondedAt = const Value.absent(),
    required String source,
    this.toneUsed = const Value.absent(),
  }) : habitId = Value(habitId),
       scheduledFor = Value(scheduledFor),
       response = Value(response),
       source = Value(source);
  static Insertable<NotificationLogData> custom({
    Expression<int>? id,
    Expression<String>? habitId,
    Expression<DateTime>? scheduledFor,
    Expression<DateTime>? firedAt,
    Expression<String>? response,
    Expression<DateTime>? respondedAt,
    Expression<String>? source,
    Expression<String>? toneUsed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (firedAt != null) 'fired_at': firedAt,
      if (response != null) 'response': response,
      if (respondedAt != null) 'responded_at': respondedAt,
      if (source != null) 'source': source,
      if (toneUsed != null) 'tone_used': toneUsed,
    });
  }

  NotificationLogCompanion copyWith({
    Value<int>? id,
    Value<String>? habitId,
    Value<DateTime>? scheduledFor,
    Value<DateTime?>? firedAt,
    Value<String>? response,
    Value<DateTime?>? respondedAt,
    Value<String>? source,
    Value<String?>? toneUsed,
  }) {
    return NotificationLogCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      firedAt: firedAt ?? this.firedAt,
      response: response ?? this.response,
      respondedAt: respondedAt ?? this.respondedAt,
      source: source ?? this.source,
      toneUsed: toneUsed ?? this.toneUsed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    if (firedAt.present) {
      map['fired_at'] = Variable<DateTime>(firedAt.value);
    }
    if (response.present) {
      map['response'] = Variable<String>(response.value);
    }
    if (respondedAt.present) {
      map['responded_at'] = Variable<DateTime>(respondedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (toneUsed.present) {
      map['tone_used'] = Variable<String>(toneUsed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('firedAt: $firedAt, ')
          ..write('response: $response, ')
          ..write('respondedAt: $respondedAt, ')
          ..write('source: $source, ')
          ..write('toneUsed: $toneUsed')
          ..write(')'))
        .toString();
  }
}

class $UserProfileTableTable extends UserProfileTable
    with TableInfo<$UserProfileTableTable, UserProfileTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _tonePreferenceMeta = const VerificationMeta(
    'tonePreference',
  );
  @override
  late final GeneratedColumn<String> tonePreference = GeneratedColumn<String>(
    'tone_preference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mixed'),
  );
  static const VerificationMeta _dailyNotifBudgetMeta = const VerificationMeta(
    'dailyNotifBudget',
  );
  @override
  late final GeneratedColumn<int> dailyNotifBudget = GeneratedColumn<int>(
    'daily_notif_budget',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _wakingWindowJsonMeta = const VerificationMeta(
    'wakingWindowJson',
  );
  @override
  late final GeneratedColumn<String> wakingWindowJson = GeneratedColumn<String>(
    'waking_window_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _slotPreferencesJsonMeta =
      const VerificationMeta('slotPreferencesJson');
  @override
  late final GeneratedColumn<String> slotPreferencesJson =
      GeneratedColumn<String>(
        'slot_preferences_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _weekdayOverridesJsonMeta =
      const VerificationMeta('weekdayOverridesJson');
  @override
  late final GeneratedColumn<String> weekdayOverridesJson =
      GeneratedColumn<String>(
        'weekday_overrides_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _goalsJsonMeta = const VerificationMeta(
    'goalsJson',
  );
  @override
  late final GeneratedColumn<String> goalsJson = GeneratedColumn<String>(
    'goals_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _followUpEnabledMeta = const VerificationMeta(
    'followUpEnabled',
  );
  @override
  late final GeneratedColumn<bool> followUpEnabled = GeneratedColumn<bool>(
    'follow_up_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("follow_up_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _popupEnabledMeta = const VerificationMeta(
    'popupEnabled',
  );
  @override
  late final GeneratedColumn<bool> popupEnabled = GeneratedColumn<bool>(
    'popup_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("popup_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _vibrationEnabledMeta = const VerificationMeta(
    'vibrationEnabled',
  );
  @override
  late final GeneratedColumn<bool> vibrationEnabled = GeneratedColumn<bool>(
    'vibration_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibration_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _soundEnabledMeta = const VerificationMeta(
    'soundEnabled',
  );
  @override
  late final GeneratedColumn<bool> soundEnabled = GeneratedColumn<bool>(
    'sound_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ttlMinutesMeta = const VerificationMeta(
    'ttlMinutes',
  );
  @override
  late final GeneratedColumn<int> ttlMinutes = GeneratedColumn<int>(
    'ttl_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _onboardedMeta = const VerificationMeta(
    'onboarded',
  );
  @override
  late final GeneratedColumn<bool> onboarded = GeneratedColumn<bool>(
    'onboarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _selectedBuddyMeta = const VerificationMeta(
    'selectedBuddy',
  );
  @override
  late final GeneratedColumn<String> selectedBuddy = GeneratedColumn<String>(
    'selected_buddy',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeIdMeta = const VerificationMeta(
    'themeId',
  );
  @override
  late final GeneratedColumn<String> themeId = GeneratedColumn<String>(
    'theme_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  );
  static const VerificationMeta _customPrimaryColorMeta =
      const VerificationMeta('customPrimaryColor');
  @override
  late final GeneratedColumn<int> customPrimaryColor = GeneratedColumn<int>(
    'custom_primary_color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customAccentColorMeta = const VerificationMeta(
    'customAccentColor',
  );
  @override
  late final GeneratedColumn<int> customAccentColor = GeneratedColumn<int>(
    'custom_accent_color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customBackgroundColorMeta =
      const VerificationMeta('customBackgroundColor');
  @override
  late final GeneratedColumn<int> customBackgroundColor = GeneratedColumn<int>(
    'custom_background_color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bgBaseMeta = const VerificationMeta('bgBase');
  @override
  late final GeneratedColumn<String> bgBase = GeneratedColumn<String>(
    'bg_base',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  );
  static const VerificationMeta _bgTintColorMeta = const VerificationMeta(
    'bgTintColor',
  );
  @override
  late final GeneratedColumn<int> bgTintColor = GeneratedColumn<int>(
    'bg_tint_color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFFCC6B49),
  );
  static const VerificationMeta _bgTintStrengthMeta = const VerificationMeta(
    'bgTintStrength',
  );
  @override
  late final GeneratedColumn<int> bgTintStrength = GeneratedColumn<int>(
    'bg_tint_strength',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  static const VerificationMeta _darkModeMeta = const VerificationMeta(
    'darkMode',
  );
  @override
  late final GeneratedColumn<String> darkMode = GeneratedColumn<String>(
    'dark_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _presenceModeMeta = const VerificationMeta(
    'presenceMode',
  );
  @override
  late final GeneratedColumn<String> presenceMode = GeneratedColumn<String>(
    'presence_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('both'),
  );
  static const VerificationMeta _widgetColorModeMeta = const VerificationMeta(
    'widgetColorMode',
  );
  @override
  late final GeneratedColumn<String> widgetColorMode = GeneratedColumn<String>(
    'widget_color_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('primary'),
  );
  static const VerificationMeta _widgetShowCountMeta = const VerificationMeta(
    'widgetShowCount',
  );
  @override
  late final GeneratedColumn<bool> widgetShowCount = GeneratedColumn<bool>(
    'widget_show_count',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("widget_show_count" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _buddyOrderJsonMeta = const VerificationMeta(
    'buddyOrderJson',
  );
  @override
  late final GeneratedColumn<String> buddyOrderJson = GeneratedColumn<String>(
    'buddy_order_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _customSoundsEnabledMeta =
      const VerificationMeta('customSoundsEnabled');
  @override
  late final GeneratedColumn<bool> customSoundsEnabled = GeneratedColumn<bool>(
    'custom_sounds_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("custom_sounds_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tonePreference,
    dailyNotifBudget,
    wakingWindowJson,
    slotPreferencesJson,
    weekdayOverridesJson,
    goalsJson,
    followUpEnabled,
    popupEnabled,
    vibrationEnabled,
    soundEnabled,
    ttlMinutes,
    onboarded,
    selectedBuddy,
    themeId,
    customPrimaryColor,
    customAccentColor,
    customBackgroundColor,
    bgBase,
    bgTintColor,
    bgTintStrength,
    darkMode,
    presenceMode,
    widgetColorMode,
    widgetShowCount,
    buddyOrderJson,
    customSoundsEnabled,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tone_preference')) {
      context.handle(
        _tonePreferenceMeta,
        tonePreference.isAcceptableOrUnknown(
          data['tone_preference']!,
          _tonePreferenceMeta,
        ),
      );
    }
    if (data.containsKey('daily_notif_budget')) {
      context.handle(
        _dailyNotifBudgetMeta,
        dailyNotifBudget.isAcceptableOrUnknown(
          data['daily_notif_budget']!,
          _dailyNotifBudgetMeta,
        ),
      );
    }
    if (data.containsKey('waking_window_json')) {
      context.handle(
        _wakingWindowJsonMeta,
        wakingWindowJson.isAcceptableOrUnknown(
          data['waking_window_json']!,
          _wakingWindowJsonMeta,
        ),
      );
    }
    if (data.containsKey('slot_preferences_json')) {
      context.handle(
        _slotPreferencesJsonMeta,
        slotPreferencesJson.isAcceptableOrUnknown(
          data['slot_preferences_json']!,
          _slotPreferencesJsonMeta,
        ),
      );
    }
    if (data.containsKey('weekday_overrides_json')) {
      context.handle(
        _weekdayOverridesJsonMeta,
        weekdayOverridesJson.isAcceptableOrUnknown(
          data['weekday_overrides_json']!,
          _weekdayOverridesJsonMeta,
        ),
      );
    }
    if (data.containsKey('goals_json')) {
      context.handle(
        _goalsJsonMeta,
        goalsJson.isAcceptableOrUnknown(data['goals_json']!, _goalsJsonMeta),
      );
    }
    if (data.containsKey('follow_up_enabled')) {
      context.handle(
        _followUpEnabledMeta,
        followUpEnabled.isAcceptableOrUnknown(
          data['follow_up_enabled']!,
          _followUpEnabledMeta,
        ),
      );
    }
    if (data.containsKey('popup_enabled')) {
      context.handle(
        _popupEnabledMeta,
        popupEnabled.isAcceptableOrUnknown(
          data['popup_enabled']!,
          _popupEnabledMeta,
        ),
      );
    }
    if (data.containsKey('vibration_enabled')) {
      context.handle(
        _vibrationEnabledMeta,
        vibrationEnabled.isAcceptableOrUnknown(
          data['vibration_enabled']!,
          _vibrationEnabledMeta,
        ),
      );
    }
    if (data.containsKey('sound_enabled')) {
      context.handle(
        _soundEnabledMeta,
        soundEnabled.isAcceptableOrUnknown(
          data['sound_enabled']!,
          _soundEnabledMeta,
        ),
      );
    }
    if (data.containsKey('ttl_minutes')) {
      context.handle(
        _ttlMinutesMeta,
        ttlMinutes.isAcceptableOrUnknown(data['ttl_minutes']!, _ttlMinutesMeta),
      );
    }
    if (data.containsKey('onboarded')) {
      context.handle(
        _onboardedMeta,
        onboarded.isAcceptableOrUnknown(data['onboarded']!, _onboardedMeta),
      );
    }
    if (data.containsKey('selected_buddy')) {
      context.handle(
        _selectedBuddyMeta,
        selectedBuddy.isAcceptableOrUnknown(
          data['selected_buddy']!,
          _selectedBuddyMeta,
        ),
      );
    }
    if (data.containsKey('theme_id')) {
      context.handle(
        _themeIdMeta,
        themeId.isAcceptableOrUnknown(data['theme_id']!, _themeIdMeta),
      );
    }
    if (data.containsKey('custom_primary_color')) {
      context.handle(
        _customPrimaryColorMeta,
        customPrimaryColor.isAcceptableOrUnknown(
          data['custom_primary_color']!,
          _customPrimaryColorMeta,
        ),
      );
    }
    if (data.containsKey('custom_accent_color')) {
      context.handle(
        _customAccentColorMeta,
        customAccentColor.isAcceptableOrUnknown(
          data['custom_accent_color']!,
          _customAccentColorMeta,
        ),
      );
    }
    if (data.containsKey('custom_background_color')) {
      context.handle(
        _customBackgroundColorMeta,
        customBackgroundColor.isAcceptableOrUnknown(
          data['custom_background_color']!,
          _customBackgroundColorMeta,
        ),
      );
    }
    if (data.containsKey('bg_base')) {
      context.handle(
        _bgBaseMeta,
        bgBase.isAcceptableOrUnknown(data['bg_base']!, _bgBaseMeta),
      );
    }
    if (data.containsKey('bg_tint_color')) {
      context.handle(
        _bgTintColorMeta,
        bgTintColor.isAcceptableOrUnknown(
          data['bg_tint_color']!,
          _bgTintColorMeta,
        ),
      );
    }
    if (data.containsKey('bg_tint_strength')) {
      context.handle(
        _bgTintStrengthMeta,
        bgTintStrength.isAcceptableOrUnknown(
          data['bg_tint_strength']!,
          _bgTintStrengthMeta,
        ),
      );
    }
    if (data.containsKey('dark_mode')) {
      context.handle(
        _darkModeMeta,
        darkMode.isAcceptableOrUnknown(data['dark_mode']!, _darkModeMeta),
      );
    }
    if (data.containsKey('presence_mode')) {
      context.handle(
        _presenceModeMeta,
        presenceMode.isAcceptableOrUnknown(
          data['presence_mode']!,
          _presenceModeMeta,
        ),
      );
    }
    if (data.containsKey('widget_color_mode')) {
      context.handle(
        _widgetColorModeMeta,
        widgetColorMode.isAcceptableOrUnknown(
          data['widget_color_mode']!,
          _widgetColorModeMeta,
        ),
      );
    }
    if (data.containsKey('widget_show_count')) {
      context.handle(
        _widgetShowCountMeta,
        widgetShowCount.isAcceptableOrUnknown(
          data['widget_show_count']!,
          _widgetShowCountMeta,
        ),
      );
    }
    if (data.containsKey('buddy_order_json')) {
      context.handle(
        _buddyOrderJsonMeta,
        buddyOrderJson.isAcceptableOrUnknown(
          data['buddy_order_json']!,
          _buddyOrderJsonMeta,
        ),
      );
    }
    if (data.containsKey('custom_sounds_enabled')) {
      context.handle(
        _customSoundsEnabledMeta,
        customSoundsEnabled.isAcceptableOrUnknown(
          data['custom_sounds_enabled']!,
          _customSoundsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tonePreference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tone_preference'],
      )!,
      dailyNotifBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_notif_budget'],
      )!,
      wakingWindowJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}waking_window_json'],
      )!,
      slotPreferencesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot_preferences_json'],
      )!,
      weekdayOverridesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekday_overrides_json'],
      )!,
      goalsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goals_json'],
      )!,
      followUpEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}follow_up_enabled'],
      )!,
      popupEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}popup_enabled'],
      )!,
      vibrationEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibration_enabled'],
      )!,
      soundEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_enabled'],
      )!,
      ttlMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ttl_minutes'],
      )!,
      onboarded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarded'],
      )!,
      selectedBuddy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_buddy'],
      ),
      themeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_id'],
      )!,
      customPrimaryColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_primary_color'],
      ),
      customAccentColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_accent_color'],
      ),
      customBackgroundColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_background_color'],
      ),
      bgBase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bg_base'],
      )!,
      bgTintColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bg_tint_color'],
      )!,
      bgTintStrength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bg_tint_strength'],
      )!,
      darkMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dark_mode'],
      )!,
      presenceMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}presence_mode'],
      )!,
      widgetColorMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}widget_color_mode'],
      )!,
      widgetShowCount: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}widget_show_count'],
      )!,
      buddyOrderJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buddy_order_json'],
      )!,
      customSoundsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}custom_sounds_enabled'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfileTableTable createAlias(String alias) {
    return $UserProfileTableTable(attachedDatabase, alias);
  }
}

class UserProfileTableData extends DataClass
    implements Insertable<UserProfileTableData> {
  final int id;
  final String tonePreference;
  final int dailyNotifBudget;
  final String wakingWindowJson;
  final String slotPreferencesJson;
  final String weekdayOverridesJson;
  final String goalsJson;
  final bool followUpEnabled;
  final bool popupEnabled;
  final bool vibrationEnabled;
  final bool soundEnabled;
  final int ttlMinutes;
  final bool onboarded;
  final String? selectedBuddy;
  final String themeId;
  final int? customPrimaryColor;
  final int? customAccentColor;

  /// v8 — legacy direct background color. Kept readable for old data but
  /// the active path is the v9 triple below.
  final int? customBackgroundColor;

  /// v9 — background is composed: a base ('light' | 'dark' | 'colorful')
  /// blended with a tint color at a 0..100 strength. The themeProvider
  /// computes the actual scaffold from these three. Defaults give the
  /// shipped "cream + sunrise tint at 10%" look on a fresh install.
  final String bgBase;
  final int bgTintColor;
  final int bgTintStrength;
  final String darkMode;
  final String presenceMode;

  /// v13 — home-screen widget progress color. 'primary' (default) paints the
  /// bar / ring the user's primary color at all completion levels;
  /// 'progressive' fades it red → yellow → green as more habits are checked.
  final String widgetColorMode;

  /// v14 — whether the widgets show the "done/total" count. When false the
  /// count is hidden and the progress bar is vertically centered.
  final bool widgetShowCount;

  /// v15 — user-defined buddy ordering for the picker, stored as a JSON
  /// array of BuddyId.id strings (e.g. ["cat","fox","snake",…]). Empty /
  /// null means "use the built-in default order". The picker floats a
  /// buddy chosen from behind the "More" tray to the front of this list so
  /// it stays visible next time.
  final String buddyOrderJson;

  /// v16 — when true (default) habit reminders play the selected buddy's
  /// own animal sound (per-buddy notification channel). When false, sound
  /// falls back to the system default. Only matters when [soundEnabled].
  final bool customSoundsEnabled;
  final DateTime updatedAt;
  const UserProfileTableData({
    required this.id,
    required this.tonePreference,
    required this.dailyNotifBudget,
    required this.wakingWindowJson,
    required this.slotPreferencesJson,
    required this.weekdayOverridesJson,
    required this.goalsJson,
    required this.followUpEnabled,
    required this.popupEnabled,
    required this.vibrationEnabled,
    required this.soundEnabled,
    required this.ttlMinutes,
    required this.onboarded,
    this.selectedBuddy,
    required this.themeId,
    this.customPrimaryColor,
    this.customAccentColor,
    this.customBackgroundColor,
    required this.bgBase,
    required this.bgTintColor,
    required this.bgTintStrength,
    required this.darkMode,
    required this.presenceMode,
    required this.widgetColorMode,
    required this.widgetShowCount,
    required this.buddyOrderJson,
    required this.customSoundsEnabled,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tone_preference'] = Variable<String>(tonePreference);
    map['daily_notif_budget'] = Variable<int>(dailyNotifBudget);
    map['waking_window_json'] = Variable<String>(wakingWindowJson);
    map['slot_preferences_json'] = Variable<String>(slotPreferencesJson);
    map['weekday_overrides_json'] = Variable<String>(weekdayOverridesJson);
    map['goals_json'] = Variable<String>(goalsJson);
    map['follow_up_enabled'] = Variable<bool>(followUpEnabled);
    map['popup_enabled'] = Variable<bool>(popupEnabled);
    map['vibration_enabled'] = Variable<bool>(vibrationEnabled);
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    map['ttl_minutes'] = Variable<int>(ttlMinutes);
    map['onboarded'] = Variable<bool>(onboarded);
    if (!nullToAbsent || selectedBuddy != null) {
      map['selected_buddy'] = Variable<String>(selectedBuddy);
    }
    map['theme_id'] = Variable<String>(themeId);
    if (!nullToAbsent || customPrimaryColor != null) {
      map['custom_primary_color'] = Variable<int>(customPrimaryColor);
    }
    if (!nullToAbsent || customAccentColor != null) {
      map['custom_accent_color'] = Variable<int>(customAccentColor);
    }
    if (!nullToAbsent || customBackgroundColor != null) {
      map['custom_background_color'] = Variable<int>(customBackgroundColor);
    }
    map['bg_base'] = Variable<String>(bgBase);
    map['bg_tint_color'] = Variable<int>(bgTintColor);
    map['bg_tint_strength'] = Variable<int>(bgTintStrength);
    map['dark_mode'] = Variable<String>(darkMode);
    map['presence_mode'] = Variable<String>(presenceMode);
    map['widget_color_mode'] = Variable<String>(widgetColorMode);
    map['widget_show_count'] = Variable<bool>(widgetShowCount);
    map['buddy_order_json'] = Variable<String>(buddyOrderJson);
    map['custom_sounds_enabled'] = Variable<bool>(customSoundsEnabled);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfileTableCompanion toCompanion(bool nullToAbsent) {
    return UserProfileTableCompanion(
      id: Value(id),
      tonePreference: Value(tonePreference),
      dailyNotifBudget: Value(dailyNotifBudget),
      wakingWindowJson: Value(wakingWindowJson),
      slotPreferencesJson: Value(slotPreferencesJson),
      weekdayOverridesJson: Value(weekdayOverridesJson),
      goalsJson: Value(goalsJson),
      followUpEnabled: Value(followUpEnabled),
      popupEnabled: Value(popupEnabled),
      vibrationEnabled: Value(vibrationEnabled),
      soundEnabled: Value(soundEnabled),
      ttlMinutes: Value(ttlMinutes),
      onboarded: Value(onboarded),
      selectedBuddy: selectedBuddy == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedBuddy),
      themeId: Value(themeId),
      customPrimaryColor: customPrimaryColor == null && nullToAbsent
          ? const Value.absent()
          : Value(customPrimaryColor),
      customAccentColor: customAccentColor == null && nullToAbsent
          ? const Value.absent()
          : Value(customAccentColor),
      customBackgroundColor: customBackgroundColor == null && nullToAbsent
          ? const Value.absent()
          : Value(customBackgroundColor),
      bgBase: Value(bgBase),
      bgTintColor: Value(bgTintColor),
      bgTintStrength: Value(bgTintStrength),
      darkMode: Value(darkMode),
      presenceMode: Value(presenceMode),
      widgetColorMode: Value(widgetColorMode),
      widgetShowCount: Value(widgetShowCount),
      buddyOrderJson: Value(buddyOrderJson),
      customSoundsEnabled: Value(customSoundsEnabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfileTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileTableData(
      id: serializer.fromJson<int>(json['id']),
      tonePreference: serializer.fromJson<String>(json['tonePreference']),
      dailyNotifBudget: serializer.fromJson<int>(json['dailyNotifBudget']),
      wakingWindowJson: serializer.fromJson<String>(json['wakingWindowJson']),
      slotPreferencesJson: serializer.fromJson<String>(
        json['slotPreferencesJson'],
      ),
      weekdayOverridesJson: serializer.fromJson<String>(
        json['weekdayOverridesJson'],
      ),
      goalsJson: serializer.fromJson<String>(json['goalsJson']),
      followUpEnabled: serializer.fromJson<bool>(json['followUpEnabled']),
      popupEnabled: serializer.fromJson<bool>(json['popupEnabled']),
      vibrationEnabled: serializer.fromJson<bool>(json['vibrationEnabled']),
      soundEnabled: serializer.fromJson<bool>(json['soundEnabled']),
      ttlMinutes: serializer.fromJson<int>(json['ttlMinutes']),
      onboarded: serializer.fromJson<bool>(json['onboarded']),
      selectedBuddy: serializer.fromJson<String?>(json['selectedBuddy']),
      themeId: serializer.fromJson<String>(json['themeId']),
      customPrimaryColor: serializer.fromJson<int?>(json['customPrimaryColor']),
      customAccentColor: serializer.fromJson<int?>(json['customAccentColor']),
      customBackgroundColor: serializer.fromJson<int?>(
        json['customBackgroundColor'],
      ),
      bgBase: serializer.fromJson<String>(json['bgBase']),
      bgTintColor: serializer.fromJson<int>(json['bgTintColor']),
      bgTintStrength: serializer.fromJson<int>(json['bgTintStrength']),
      darkMode: serializer.fromJson<String>(json['darkMode']),
      presenceMode: serializer.fromJson<String>(json['presenceMode']),
      widgetColorMode: serializer.fromJson<String>(json['widgetColorMode']),
      widgetShowCount: serializer.fromJson<bool>(json['widgetShowCount']),
      buddyOrderJson: serializer.fromJson<String>(json['buddyOrderJson']),
      customSoundsEnabled: serializer.fromJson<bool>(
        json['customSoundsEnabled'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tonePreference': serializer.toJson<String>(tonePreference),
      'dailyNotifBudget': serializer.toJson<int>(dailyNotifBudget),
      'wakingWindowJson': serializer.toJson<String>(wakingWindowJson),
      'slotPreferencesJson': serializer.toJson<String>(slotPreferencesJson),
      'weekdayOverridesJson': serializer.toJson<String>(weekdayOverridesJson),
      'goalsJson': serializer.toJson<String>(goalsJson),
      'followUpEnabled': serializer.toJson<bool>(followUpEnabled),
      'popupEnabled': serializer.toJson<bool>(popupEnabled),
      'vibrationEnabled': serializer.toJson<bool>(vibrationEnabled),
      'soundEnabled': serializer.toJson<bool>(soundEnabled),
      'ttlMinutes': serializer.toJson<int>(ttlMinutes),
      'onboarded': serializer.toJson<bool>(onboarded),
      'selectedBuddy': serializer.toJson<String?>(selectedBuddy),
      'themeId': serializer.toJson<String>(themeId),
      'customPrimaryColor': serializer.toJson<int?>(customPrimaryColor),
      'customAccentColor': serializer.toJson<int?>(customAccentColor),
      'customBackgroundColor': serializer.toJson<int?>(customBackgroundColor),
      'bgBase': serializer.toJson<String>(bgBase),
      'bgTintColor': serializer.toJson<int>(bgTintColor),
      'bgTintStrength': serializer.toJson<int>(bgTintStrength),
      'darkMode': serializer.toJson<String>(darkMode),
      'presenceMode': serializer.toJson<String>(presenceMode),
      'widgetColorMode': serializer.toJson<String>(widgetColorMode),
      'widgetShowCount': serializer.toJson<bool>(widgetShowCount),
      'buddyOrderJson': serializer.toJson<String>(buddyOrderJson),
      'customSoundsEnabled': serializer.toJson<bool>(customSoundsEnabled),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfileTableData copyWith({
    int? id,
    String? tonePreference,
    int? dailyNotifBudget,
    String? wakingWindowJson,
    String? slotPreferencesJson,
    String? weekdayOverridesJson,
    String? goalsJson,
    bool? followUpEnabled,
    bool? popupEnabled,
    bool? vibrationEnabled,
    bool? soundEnabled,
    int? ttlMinutes,
    bool? onboarded,
    Value<String?> selectedBuddy = const Value.absent(),
    String? themeId,
    Value<int?> customPrimaryColor = const Value.absent(),
    Value<int?> customAccentColor = const Value.absent(),
    Value<int?> customBackgroundColor = const Value.absent(),
    String? bgBase,
    int? bgTintColor,
    int? bgTintStrength,
    String? darkMode,
    String? presenceMode,
    String? widgetColorMode,
    bool? widgetShowCount,
    String? buddyOrderJson,
    bool? customSoundsEnabled,
    DateTime? updatedAt,
  }) => UserProfileTableData(
    id: id ?? this.id,
    tonePreference: tonePreference ?? this.tonePreference,
    dailyNotifBudget: dailyNotifBudget ?? this.dailyNotifBudget,
    wakingWindowJson: wakingWindowJson ?? this.wakingWindowJson,
    slotPreferencesJson: slotPreferencesJson ?? this.slotPreferencesJson,
    weekdayOverridesJson: weekdayOverridesJson ?? this.weekdayOverridesJson,
    goalsJson: goalsJson ?? this.goalsJson,
    followUpEnabled: followUpEnabled ?? this.followUpEnabled,
    popupEnabled: popupEnabled ?? this.popupEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    ttlMinutes: ttlMinutes ?? this.ttlMinutes,
    onboarded: onboarded ?? this.onboarded,
    selectedBuddy: selectedBuddy.present
        ? selectedBuddy.value
        : this.selectedBuddy,
    themeId: themeId ?? this.themeId,
    customPrimaryColor: customPrimaryColor.present
        ? customPrimaryColor.value
        : this.customPrimaryColor,
    customAccentColor: customAccentColor.present
        ? customAccentColor.value
        : this.customAccentColor,
    customBackgroundColor: customBackgroundColor.present
        ? customBackgroundColor.value
        : this.customBackgroundColor,
    bgBase: bgBase ?? this.bgBase,
    bgTintColor: bgTintColor ?? this.bgTintColor,
    bgTintStrength: bgTintStrength ?? this.bgTintStrength,
    darkMode: darkMode ?? this.darkMode,
    presenceMode: presenceMode ?? this.presenceMode,
    widgetColorMode: widgetColorMode ?? this.widgetColorMode,
    widgetShowCount: widgetShowCount ?? this.widgetShowCount,
    buddyOrderJson: buddyOrderJson ?? this.buddyOrderJson,
    customSoundsEnabled: customSoundsEnabled ?? this.customSoundsEnabled,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfileTableData copyWithCompanion(UserProfileTableCompanion data) {
    return UserProfileTableData(
      id: data.id.present ? data.id.value : this.id,
      tonePreference: data.tonePreference.present
          ? data.tonePreference.value
          : this.tonePreference,
      dailyNotifBudget: data.dailyNotifBudget.present
          ? data.dailyNotifBudget.value
          : this.dailyNotifBudget,
      wakingWindowJson: data.wakingWindowJson.present
          ? data.wakingWindowJson.value
          : this.wakingWindowJson,
      slotPreferencesJson: data.slotPreferencesJson.present
          ? data.slotPreferencesJson.value
          : this.slotPreferencesJson,
      weekdayOverridesJson: data.weekdayOverridesJson.present
          ? data.weekdayOverridesJson.value
          : this.weekdayOverridesJson,
      goalsJson: data.goalsJson.present ? data.goalsJson.value : this.goalsJson,
      followUpEnabled: data.followUpEnabled.present
          ? data.followUpEnabled.value
          : this.followUpEnabled,
      popupEnabled: data.popupEnabled.present
          ? data.popupEnabled.value
          : this.popupEnabled,
      vibrationEnabled: data.vibrationEnabled.present
          ? data.vibrationEnabled.value
          : this.vibrationEnabled,
      soundEnabled: data.soundEnabled.present
          ? data.soundEnabled.value
          : this.soundEnabled,
      ttlMinutes: data.ttlMinutes.present
          ? data.ttlMinutes.value
          : this.ttlMinutes,
      onboarded: data.onboarded.present ? data.onboarded.value : this.onboarded,
      selectedBuddy: data.selectedBuddy.present
          ? data.selectedBuddy.value
          : this.selectedBuddy,
      themeId: data.themeId.present ? data.themeId.value : this.themeId,
      customPrimaryColor: data.customPrimaryColor.present
          ? data.customPrimaryColor.value
          : this.customPrimaryColor,
      customAccentColor: data.customAccentColor.present
          ? data.customAccentColor.value
          : this.customAccentColor,
      customBackgroundColor: data.customBackgroundColor.present
          ? data.customBackgroundColor.value
          : this.customBackgroundColor,
      bgBase: data.bgBase.present ? data.bgBase.value : this.bgBase,
      bgTintColor: data.bgTintColor.present
          ? data.bgTintColor.value
          : this.bgTintColor,
      bgTintStrength: data.bgTintStrength.present
          ? data.bgTintStrength.value
          : this.bgTintStrength,
      darkMode: data.darkMode.present ? data.darkMode.value : this.darkMode,
      presenceMode: data.presenceMode.present
          ? data.presenceMode.value
          : this.presenceMode,
      widgetColorMode: data.widgetColorMode.present
          ? data.widgetColorMode.value
          : this.widgetColorMode,
      widgetShowCount: data.widgetShowCount.present
          ? data.widgetShowCount.value
          : this.widgetShowCount,
      buddyOrderJson: data.buddyOrderJson.present
          ? data.buddyOrderJson.value
          : this.buddyOrderJson,
      customSoundsEnabled: data.customSoundsEnabled.present
          ? data.customSoundsEnabled.value
          : this.customSoundsEnabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileTableData(')
          ..write('id: $id, ')
          ..write('tonePreference: $tonePreference, ')
          ..write('dailyNotifBudget: $dailyNotifBudget, ')
          ..write('wakingWindowJson: $wakingWindowJson, ')
          ..write('slotPreferencesJson: $slotPreferencesJson, ')
          ..write('weekdayOverridesJson: $weekdayOverridesJson, ')
          ..write('goalsJson: $goalsJson, ')
          ..write('followUpEnabled: $followUpEnabled, ')
          ..write('popupEnabled: $popupEnabled, ')
          ..write('vibrationEnabled: $vibrationEnabled, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('ttlMinutes: $ttlMinutes, ')
          ..write('onboarded: $onboarded, ')
          ..write('selectedBuddy: $selectedBuddy, ')
          ..write('themeId: $themeId, ')
          ..write('customPrimaryColor: $customPrimaryColor, ')
          ..write('customAccentColor: $customAccentColor, ')
          ..write('customBackgroundColor: $customBackgroundColor, ')
          ..write('bgBase: $bgBase, ')
          ..write('bgTintColor: $bgTintColor, ')
          ..write('bgTintStrength: $bgTintStrength, ')
          ..write('darkMode: $darkMode, ')
          ..write('presenceMode: $presenceMode, ')
          ..write('widgetColorMode: $widgetColorMode, ')
          ..write('widgetShowCount: $widgetShowCount, ')
          ..write('buddyOrderJson: $buddyOrderJson, ')
          ..write('customSoundsEnabled: $customSoundsEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    tonePreference,
    dailyNotifBudget,
    wakingWindowJson,
    slotPreferencesJson,
    weekdayOverridesJson,
    goalsJson,
    followUpEnabled,
    popupEnabled,
    vibrationEnabled,
    soundEnabled,
    ttlMinutes,
    onboarded,
    selectedBuddy,
    themeId,
    customPrimaryColor,
    customAccentColor,
    customBackgroundColor,
    bgBase,
    bgTintColor,
    bgTintStrength,
    darkMode,
    presenceMode,
    widgetColorMode,
    widgetShowCount,
    buddyOrderJson,
    customSoundsEnabled,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileTableData &&
          other.id == this.id &&
          other.tonePreference == this.tonePreference &&
          other.dailyNotifBudget == this.dailyNotifBudget &&
          other.wakingWindowJson == this.wakingWindowJson &&
          other.slotPreferencesJson == this.slotPreferencesJson &&
          other.weekdayOverridesJson == this.weekdayOverridesJson &&
          other.goalsJson == this.goalsJson &&
          other.followUpEnabled == this.followUpEnabled &&
          other.popupEnabled == this.popupEnabled &&
          other.vibrationEnabled == this.vibrationEnabled &&
          other.soundEnabled == this.soundEnabled &&
          other.ttlMinutes == this.ttlMinutes &&
          other.onboarded == this.onboarded &&
          other.selectedBuddy == this.selectedBuddy &&
          other.themeId == this.themeId &&
          other.customPrimaryColor == this.customPrimaryColor &&
          other.customAccentColor == this.customAccentColor &&
          other.customBackgroundColor == this.customBackgroundColor &&
          other.bgBase == this.bgBase &&
          other.bgTintColor == this.bgTintColor &&
          other.bgTintStrength == this.bgTintStrength &&
          other.darkMode == this.darkMode &&
          other.presenceMode == this.presenceMode &&
          other.widgetColorMode == this.widgetColorMode &&
          other.widgetShowCount == this.widgetShowCount &&
          other.buddyOrderJson == this.buddyOrderJson &&
          other.customSoundsEnabled == this.customSoundsEnabled &&
          other.updatedAt == this.updatedAt);
}

class UserProfileTableCompanion extends UpdateCompanion<UserProfileTableData> {
  final Value<int> id;
  final Value<String> tonePreference;
  final Value<int> dailyNotifBudget;
  final Value<String> wakingWindowJson;
  final Value<String> slotPreferencesJson;
  final Value<String> weekdayOverridesJson;
  final Value<String> goalsJson;
  final Value<bool> followUpEnabled;
  final Value<bool> popupEnabled;
  final Value<bool> vibrationEnabled;
  final Value<bool> soundEnabled;
  final Value<int> ttlMinutes;
  final Value<bool> onboarded;
  final Value<String?> selectedBuddy;
  final Value<String> themeId;
  final Value<int?> customPrimaryColor;
  final Value<int?> customAccentColor;
  final Value<int?> customBackgroundColor;
  final Value<String> bgBase;
  final Value<int> bgTintColor;
  final Value<int> bgTintStrength;
  final Value<String> darkMode;
  final Value<String> presenceMode;
  final Value<String> widgetColorMode;
  final Value<bool> widgetShowCount;
  final Value<String> buddyOrderJson;
  final Value<bool> customSoundsEnabled;
  final Value<DateTime> updatedAt;
  const UserProfileTableCompanion({
    this.id = const Value.absent(),
    this.tonePreference = const Value.absent(),
    this.dailyNotifBudget = const Value.absent(),
    this.wakingWindowJson = const Value.absent(),
    this.slotPreferencesJson = const Value.absent(),
    this.weekdayOverridesJson = const Value.absent(),
    this.goalsJson = const Value.absent(),
    this.followUpEnabled = const Value.absent(),
    this.popupEnabled = const Value.absent(),
    this.vibrationEnabled = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.ttlMinutes = const Value.absent(),
    this.onboarded = const Value.absent(),
    this.selectedBuddy = const Value.absent(),
    this.themeId = const Value.absent(),
    this.customPrimaryColor = const Value.absent(),
    this.customAccentColor = const Value.absent(),
    this.customBackgroundColor = const Value.absent(),
    this.bgBase = const Value.absent(),
    this.bgTintColor = const Value.absent(),
    this.bgTintStrength = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.presenceMode = const Value.absent(),
    this.widgetColorMode = const Value.absent(),
    this.widgetShowCount = const Value.absent(),
    this.buddyOrderJson = const Value.absent(),
    this.customSoundsEnabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfileTableCompanion.insert({
    this.id = const Value.absent(),
    this.tonePreference = const Value.absent(),
    this.dailyNotifBudget = const Value.absent(),
    this.wakingWindowJson = const Value.absent(),
    this.slotPreferencesJson = const Value.absent(),
    this.weekdayOverridesJson = const Value.absent(),
    this.goalsJson = const Value.absent(),
    this.followUpEnabled = const Value.absent(),
    this.popupEnabled = const Value.absent(),
    this.vibrationEnabled = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.ttlMinutes = const Value.absent(),
    this.onboarded = const Value.absent(),
    this.selectedBuddy = const Value.absent(),
    this.themeId = const Value.absent(),
    this.customPrimaryColor = const Value.absent(),
    this.customAccentColor = const Value.absent(),
    this.customBackgroundColor = const Value.absent(),
    this.bgBase = const Value.absent(),
    this.bgTintColor = const Value.absent(),
    this.bgTintStrength = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.presenceMode = const Value.absent(),
    this.widgetColorMode = const Value.absent(),
    this.widgetShowCount = const Value.absent(),
    this.buddyOrderJson = const Value.absent(),
    this.customSoundsEnabled = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<UserProfileTableData> custom({
    Expression<int>? id,
    Expression<String>? tonePreference,
    Expression<int>? dailyNotifBudget,
    Expression<String>? wakingWindowJson,
    Expression<String>? slotPreferencesJson,
    Expression<String>? weekdayOverridesJson,
    Expression<String>? goalsJson,
    Expression<bool>? followUpEnabled,
    Expression<bool>? popupEnabled,
    Expression<bool>? vibrationEnabled,
    Expression<bool>? soundEnabled,
    Expression<int>? ttlMinutes,
    Expression<bool>? onboarded,
    Expression<String>? selectedBuddy,
    Expression<String>? themeId,
    Expression<int>? customPrimaryColor,
    Expression<int>? customAccentColor,
    Expression<int>? customBackgroundColor,
    Expression<String>? bgBase,
    Expression<int>? bgTintColor,
    Expression<int>? bgTintStrength,
    Expression<String>? darkMode,
    Expression<String>? presenceMode,
    Expression<String>? widgetColorMode,
    Expression<bool>? widgetShowCount,
    Expression<String>? buddyOrderJson,
    Expression<bool>? customSoundsEnabled,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tonePreference != null) 'tone_preference': tonePreference,
      if (dailyNotifBudget != null) 'daily_notif_budget': dailyNotifBudget,
      if (wakingWindowJson != null) 'waking_window_json': wakingWindowJson,
      if (slotPreferencesJson != null)
        'slot_preferences_json': slotPreferencesJson,
      if (weekdayOverridesJson != null)
        'weekday_overrides_json': weekdayOverridesJson,
      if (goalsJson != null) 'goals_json': goalsJson,
      if (followUpEnabled != null) 'follow_up_enabled': followUpEnabled,
      if (popupEnabled != null) 'popup_enabled': popupEnabled,
      if (vibrationEnabled != null) 'vibration_enabled': vibrationEnabled,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (ttlMinutes != null) 'ttl_minutes': ttlMinutes,
      if (onboarded != null) 'onboarded': onboarded,
      if (selectedBuddy != null) 'selected_buddy': selectedBuddy,
      if (themeId != null) 'theme_id': themeId,
      if (customPrimaryColor != null)
        'custom_primary_color': customPrimaryColor,
      if (customAccentColor != null) 'custom_accent_color': customAccentColor,
      if (customBackgroundColor != null)
        'custom_background_color': customBackgroundColor,
      if (bgBase != null) 'bg_base': bgBase,
      if (bgTintColor != null) 'bg_tint_color': bgTintColor,
      if (bgTintStrength != null) 'bg_tint_strength': bgTintStrength,
      if (darkMode != null) 'dark_mode': darkMode,
      if (presenceMode != null) 'presence_mode': presenceMode,
      if (widgetColorMode != null) 'widget_color_mode': widgetColorMode,
      if (widgetShowCount != null) 'widget_show_count': widgetShowCount,
      if (buddyOrderJson != null) 'buddy_order_json': buddyOrderJson,
      if (customSoundsEnabled != null)
        'custom_sounds_enabled': customSoundsEnabled,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfileTableCompanion copyWith({
    Value<int>? id,
    Value<String>? tonePreference,
    Value<int>? dailyNotifBudget,
    Value<String>? wakingWindowJson,
    Value<String>? slotPreferencesJson,
    Value<String>? weekdayOverridesJson,
    Value<String>? goalsJson,
    Value<bool>? followUpEnabled,
    Value<bool>? popupEnabled,
    Value<bool>? vibrationEnabled,
    Value<bool>? soundEnabled,
    Value<int>? ttlMinutes,
    Value<bool>? onboarded,
    Value<String?>? selectedBuddy,
    Value<String>? themeId,
    Value<int?>? customPrimaryColor,
    Value<int?>? customAccentColor,
    Value<int?>? customBackgroundColor,
    Value<String>? bgBase,
    Value<int>? bgTintColor,
    Value<int>? bgTintStrength,
    Value<String>? darkMode,
    Value<String>? presenceMode,
    Value<String>? widgetColorMode,
    Value<bool>? widgetShowCount,
    Value<String>? buddyOrderJson,
    Value<bool>? customSoundsEnabled,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfileTableCompanion(
      id: id ?? this.id,
      tonePreference: tonePreference ?? this.tonePreference,
      dailyNotifBudget: dailyNotifBudget ?? this.dailyNotifBudget,
      wakingWindowJson: wakingWindowJson ?? this.wakingWindowJson,
      slotPreferencesJson: slotPreferencesJson ?? this.slotPreferencesJson,
      weekdayOverridesJson: weekdayOverridesJson ?? this.weekdayOverridesJson,
      goalsJson: goalsJson ?? this.goalsJson,
      followUpEnabled: followUpEnabled ?? this.followUpEnabled,
      popupEnabled: popupEnabled ?? this.popupEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      ttlMinutes: ttlMinutes ?? this.ttlMinutes,
      onboarded: onboarded ?? this.onboarded,
      selectedBuddy: selectedBuddy ?? this.selectedBuddy,
      themeId: themeId ?? this.themeId,
      customPrimaryColor: customPrimaryColor ?? this.customPrimaryColor,
      customAccentColor: customAccentColor ?? this.customAccentColor,
      customBackgroundColor:
          customBackgroundColor ?? this.customBackgroundColor,
      bgBase: bgBase ?? this.bgBase,
      bgTintColor: bgTintColor ?? this.bgTintColor,
      bgTintStrength: bgTintStrength ?? this.bgTintStrength,
      darkMode: darkMode ?? this.darkMode,
      presenceMode: presenceMode ?? this.presenceMode,
      widgetColorMode: widgetColorMode ?? this.widgetColorMode,
      widgetShowCount: widgetShowCount ?? this.widgetShowCount,
      buddyOrderJson: buddyOrderJson ?? this.buddyOrderJson,
      customSoundsEnabled: customSoundsEnabled ?? this.customSoundsEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tonePreference.present) {
      map['tone_preference'] = Variable<String>(tonePreference.value);
    }
    if (dailyNotifBudget.present) {
      map['daily_notif_budget'] = Variable<int>(dailyNotifBudget.value);
    }
    if (wakingWindowJson.present) {
      map['waking_window_json'] = Variable<String>(wakingWindowJson.value);
    }
    if (slotPreferencesJson.present) {
      map['slot_preferences_json'] = Variable<String>(
        slotPreferencesJson.value,
      );
    }
    if (weekdayOverridesJson.present) {
      map['weekday_overrides_json'] = Variable<String>(
        weekdayOverridesJson.value,
      );
    }
    if (goalsJson.present) {
      map['goals_json'] = Variable<String>(goalsJson.value);
    }
    if (followUpEnabled.present) {
      map['follow_up_enabled'] = Variable<bool>(followUpEnabled.value);
    }
    if (popupEnabled.present) {
      map['popup_enabled'] = Variable<bool>(popupEnabled.value);
    }
    if (vibrationEnabled.present) {
      map['vibration_enabled'] = Variable<bool>(vibrationEnabled.value);
    }
    if (soundEnabled.present) {
      map['sound_enabled'] = Variable<bool>(soundEnabled.value);
    }
    if (ttlMinutes.present) {
      map['ttl_minutes'] = Variable<int>(ttlMinutes.value);
    }
    if (onboarded.present) {
      map['onboarded'] = Variable<bool>(onboarded.value);
    }
    if (selectedBuddy.present) {
      map['selected_buddy'] = Variable<String>(selectedBuddy.value);
    }
    if (themeId.present) {
      map['theme_id'] = Variable<String>(themeId.value);
    }
    if (customPrimaryColor.present) {
      map['custom_primary_color'] = Variable<int>(customPrimaryColor.value);
    }
    if (customAccentColor.present) {
      map['custom_accent_color'] = Variable<int>(customAccentColor.value);
    }
    if (customBackgroundColor.present) {
      map['custom_background_color'] = Variable<int>(
        customBackgroundColor.value,
      );
    }
    if (bgBase.present) {
      map['bg_base'] = Variable<String>(bgBase.value);
    }
    if (bgTintColor.present) {
      map['bg_tint_color'] = Variable<int>(bgTintColor.value);
    }
    if (bgTintStrength.present) {
      map['bg_tint_strength'] = Variable<int>(bgTintStrength.value);
    }
    if (darkMode.present) {
      map['dark_mode'] = Variable<String>(darkMode.value);
    }
    if (presenceMode.present) {
      map['presence_mode'] = Variable<String>(presenceMode.value);
    }
    if (widgetColorMode.present) {
      map['widget_color_mode'] = Variable<String>(widgetColorMode.value);
    }
    if (widgetShowCount.present) {
      map['widget_show_count'] = Variable<bool>(widgetShowCount.value);
    }
    if (buddyOrderJson.present) {
      map['buddy_order_json'] = Variable<String>(buddyOrderJson.value);
    }
    if (customSoundsEnabled.present) {
      map['custom_sounds_enabled'] = Variable<bool>(customSoundsEnabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileTableCompanion(')
          ..write('id: $id, ')
          ..write('tonePreference: $tonePreference, ')
          ..write('dailyNotifBudget: $dailyNotifBudget, ')
          ..write('wakingWindowJson: $wakingWindowJson, ')
          ..write('slotPreferencesJson: $slotPreferencesJson, ')
          ..write('weekdayOverridesJson: $weekdayOverridesJson, ')
          ..write('goalsJson: $goalsJson, ')
          ..write('followUpEnabled: $followUpEnabled, ')
          ..write('popupEnabled: $popupEnabled, ')
          ..write('vibrationEnabled: $vibrationEnabled, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('ttlMinutes: $ttlMinutes, ')
          ..write('onboarded: $onboarded, ')
          ..write('selectedBuddy: $selectedBuddy, ')
          ..write('themeId: $themeId, ')
          ..write('customPrimaryColor: $customPrimaryColor, ')
          ..write('customAccentColor: $customAccentColor, ')
          ..write('customBackgroundColor: $customBackgroundColor, ')
          ..write('bgBase: $bgBase, ')
          ..write('bgTintColor: $bgTintColor, ')
          ..write('bgTintStrength: $bgTintStrength, ')
          ..write('darkMode: $darkMode, ')
          ..write('presenceMode: $presenceMode, ')
          ..write('widgetColorMode: $widgetColorMode, ')
          ..write('widgetShowCount: $widgetShowCount, ')
          ..write('buddyOrderJson: $buddyOrderJson, ')
          ..write('customSoundsEnabled: $customSoundsEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ProfileSignalsTable extends ProfileSignals
    with TableInfo<$ProfileSignalsTable, ProfileSignal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileSignalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ts, kind, payloadJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_signals';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileSignal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileSignal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileSignal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ts'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
    );
  }

  @override
  $ProfileSignalsTable createAlias(String alias) {
    return $ProfileSignalsTable(attachedDatabase, alias);
  }
}

class ProfileSignal extends DataClass implements Insertable<ProfileSignal> {
  final int id;
  final DateTime ts;
  final String kind;
  final String payloadJson;
  const ProfileSignal({
    required this.id,
    required this.ts,
    required this.kind,
    required this.payloadJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ts'] = Variable<DateTime>(ts);
    map['kind'] = Variable<String>(kind);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  ProfileSignalsCompanion toCompanion(bool nullToAbsent) {
    return ProfileSignalsCompanion(
      id: Value(id),
      ts: Value(ts),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
    );
  }

  factory ProfileSignal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileSignal(
      id: serializer.fromJson<int>(json['id']),
      ts: serializer.fromJson<DateTime>(json['ts']),
      kind: serializer.fromJson<String>(json['kind']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ts': serializer.toJson<DateTime>(ts),
      'kind': serializer.toJson<String>(kind),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  ProfileSignal copyWith({
    int? id,
    DateTime? ts,
    String? kind,
    String? payloadJson,
  }) => ProfileSignal(
    id: id ?? this.id,
    ts: ts ?? this.ts,
    kind: kind ?? this.kind,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  ProfileSignal copyWithCompanion(ProfileSignalsCompanion data) {
    return ProfileSignal(
      id: data.id.present ? data.id.value : this.id,
      ts: data.ts.present ? data.ts.value : this.ts,
      kind: data.kind.present ? data.kind.value : this.kind,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileSignal(')
          ..write('id: $id, ')
          ..write('ts: $ts, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ts, kind, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileSignal &&
          other.id == this.id &&
          other.ts == this.ts &&
          other.kind == this.kind &&
          other.payloadJson == this.payloadJson);
}

class ProfileSignalsCompanion extends UpdateCompanion<ProfileSignal> {
  final Value<int> id;
  final Value<DateTime> ts;
  final Value<String> kind;
  final Value<String> payloadJson;
  const ProfileSignalsCompanion({
    this.id = const Value.absent(),
    this.ts = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
  });
  ProfileSignalsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime ts,
    required String kind,
    required String payloadJson,
  }) : ts = Value(ts),
       kind = Value(kind),
       payloadJson = Value(payloadJson);
  static Insertable<ProfileSignal> custom({
    Expression<int>? id,
    Expression<DateTime>? ts,
    Expression<String>? kind,
    Expression<String>? payloadJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ts != null) 'ts': ts,
      if (kind != null) 'kind': kind,
      if (payloadJson != null) 'payload_json': payloadJson,
    });
  }

  ProfileSignalsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? ts,
    Value<String>? kind,
    Value<String>? payloadJson,
  }) {
    return ProfileSignalsCompanion(
      id: id ?? this.id,
      ts: ts ?? this.ts,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileSignalsCompanion(')
          ..write('id: $id, ')
          ..write('ts: $ts, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }
}

class $AdaptiveStateTable extends AdaptiveState
    with TableInfo<$AdaptiveStateTable, AdaptiveStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdaptiveStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id)',
    ),
  );
  static const VerificationMeta _lastEvaluatedAtMeta = const VerificationMeta(
    'lastEvaluatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastEvaluatedAt =
      GeneratedColumn<DateTime>(
        'last_evaluated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _responseWindowJsonMeta =
      const VerificationMeta('responseWindowJson');
  @override
  late final GeneratedColumn<String> responseWindowJson =
      GeneratedColumn<String>(
        'response_window_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _currentOffsetsJsonMeta =
      const VerificationMeta('currentOffsetsJson');
  @override
  late final GeneratedColumn<String> currentOffsetsJson =
      GeneratedColumn<String>(
        'current_offsets_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _streakCountMeta = const VerificationMeta(
    'streakCount',
  );
  @override
  late final GeneratedColumn<int> streakCount = GeneratedColumn<int>(
    'streak_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastMissAtMeta = const VerificationMeta(
    'lastMissAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastMissAt = GeneratedColumn<DateTime>(
    'last_miss_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentToneKeyMeta = const VerificationMeta(
    'currentToneKey',
  );
  @override
  late final GeneratedColumn<String> currentToneKey = GeneratedColumn<String>(
    'current_tone_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    habitId,
    lastEvaluatedAt,
    responseWindowJson,
    currentOffsetsJson,
    streakCount,
    lastMissAt,
    currentToneKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adaptive_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdaptiveStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('last_evaluated_at')) {
      context.handle(
        _lastEvaluatedAtMeta,
        lastEvaluatedAt.isAcceptableOrUnknown(
          data['last_evaluated_at']!,
          _lastEvaluatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastEvaluatedAtMeta);
    }
    if (data.containsKey('response_window_json')) {
      context.handle(
        _responseWindowJsonMeta,
        responseWindowJson.isAcceptableOrUnknown(
          data['response_window_json']!,
          _responseWindowJsonMeta,
        ),
      );
    }
    if (data.containsKey('current_offsets_json')) {
      context.handle(
        _currentOffsetsJsonMeta,
        currentOffsetsJson.isAcceptableOrUnknown(
          data['current_offsets_json']!,
          _currentOffsetsJsonMeta,
        ),
      );
    }
    if (data.containsKey('streak_count')) {
      context.handle(
        _streakCountMeta,
        streakCount.isAcceptableOrUnknown(
          data['streak_count']!,
          _streakCountMeta,
        ),
      );
    }
    if (data.containsKey('last_miss_at')) {
      context.handle(
        _lastMissAtMeta,
        lastMissAt.isAcceptableOrUnknown(
          data['last_miss_at']!,
          _lastMissAtMeta,
        ),
      );
    }
    if (data.containsKey('current_tone_key')) {
      context.handle(
        _currentToneKeyMeta,
        currentToneKey.isAcceptableOrUnknown(
          data['current_tone_key']!,
          _currentToneKeyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId};
  @override
  AdaptiveStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdaptiveStateData(
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      lastEvaluatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_evaluated_at'],
      )!,
      responseWindowJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_window_json'],
      )!,
      currentOffsetsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_offsets_json'],
      )!,
      streakCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_count'],
      )!,
      lastMissAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_miss_at'],
      ),
      currentToneKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_tone_key'],
      ),
    );
  }

  @override
  $AdaptiveStateTable createAlias(String alias) {
    return $AdaptiveStateTable(attachedDatabase, alias);
  }
}

class AdaptiveStateData extends DataClass
    implements Insertable<AdaptiveStateData> {
  final String habitId;
  final DateTime lastEvaluatedAt;
  final String responseWindowJson;
  final String currentOffsetsJson;
  final int streakCount;
  final DateTime? lastMissAt;
  final String? currentToneKey;
  const AdaptiveStateData({
    required this.habitId,
    required this.lastEvaluatedAt,
    required this.responseWindowJson,
    required this.currentOffsetsJson,
    required this.streakCount,
    this.lastMissAt,
    this.currentToneKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<String>(habitId);
    map['last_evaluated_at'] = Variable<DateTime>(lastEvaluatedAt);
    map['response_window_json'] = Variable<String>(responseWindowJson);
    map['current_offsets_json'] = Variable<String>(currentOffsetsJson);
    map['streak_count'] = Variable<int>(streakCount);
    if (!nullToAbsent || lastMissAt != null) {
      map['last_miss_at'] = Variable<DateTime>(lastMissAt);
    }
    if (!nullToAbsent || currentToneKey != null) {
      map['current_tone_key'] = Variable<String>(currentToneKey);
    }
    return map;
  }

  AdaptiveStateCompanion toCompanion(bool nullToAbsent) {
    return AdaptiveStateCompanion(
      habitId: Value(habitId),
      lastEvaluatedAt: Value(lastEvaluatedAt),
      responseWindowJson: Value(responseWindowJson),
      currentOffsetsJson: Value(currentOffsetsJson),
      streakCount: Value(streakCount),
      lastMissAt: lastMissAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMissAt),
      currentToneKey: currentToneKey == null && nullToAbsent
          ? const Value.absent()
          : Value(currentToneKey),
    );
  }

  factory AdaptiveStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdaptiveStateData(
      habitId: serializer.fromJson<String>(json['habitId']),
      lastEvaluatedAt: serializer.fromJson<DateTime>(json['lastEvaluatedAt']),
      responseWindowJson: serializer.fromJson<String>(
        json['responseWindowJson'],
      ),
      currentOffsetsJson: serializer.fromJson<String>(
        json['currentOffsetsJson'],
      ),
      streakCount: serializer.fromJson<int>(json['streakCount']),
      lastMissAt: serializer.fromJson<DateTime?>(json['lastMissAt']),
      currentToneKey: serializer.fromJson<String?>(json['currentToneKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<String>(habitId),
      'lastEvaluatedAt': serializer.toJson<DateTime>(lastEvaluatedAt),
      'responseWindowJson': serializer.toJson<String>(responseWindowJson),
      'currentOffsetsJson': serializer.toJson<String>(currentOffsetsJson),
      'streakCount': serializer.toJson<int>(streakCount),
      'lastMissAt': serializer.toJson<DateTime?>(lastMissAt),
      'currentToneKey': serializer.toJson<String?>(currentToneKey),
    };
  }

  AdaptiveStateData copyWith({
    String? habitId,
    DateTime? lastEvaluatedAt,
    String? responseWindowJson,
    String? currentOffsetsJson,
    int? streakCount,
    Value<DateTime?> lastMissAt = const Value.absent(),
    Value<String?> currentToneKey = const Value.absent(),
  }) => AdaptiveStateData(
    habitId: habitId ?? this.habitId,
    lastEvaluatedAt: lastEvaluatedAt ?? this.lastEvaluatedAt,
    responseWindowJson: responseWindowJson ?? this.responseWindowJson,
    currentOffsetsJson: currentOffsetsJson ?? this.currentOffsetsJson,
    streakCount: streakCount ?? this.streakCount,
    lastMissAt: lastMissAt.present ? lastMissAt.value : this.lastMissAt,
    currentToneKey: currentToneKey.present
        ? currentToneKey.value
        : this.currentToneKey,
  );
  AdaptiveStateData copyWithCompanion(AdaptiveStateCompanion data) {
    return AdaptiveStateData(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      lastEvaluatedAt: data.lastEvaluatedAt.present
          ? data.lastEvaluatedAt.value
          : this.lastEvaluatedAt,
      responseWindowJson: data.responseWindowJson.present
          ? data.responseWindowJson.value
          : this.responseWindowJson,
      currentOffsetsJson: data.currentOffsetsJson.present
          ? data.currentOffsetsJson.value
          : this.currentOffsetsJson,
      streakCount: data.streakCount.present
          ? data.streakCount.value
          : this.streakCount,
      lastMissAt: data.lastMissAt.present
          ? data.lastMissAt.value
          : this.lastMissAt,
      currentToneKey: data.currentToneKey.present
          ? data.currentToneKey.value
          : this.currentToneKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdaptiveStateData(')
          ..write('habitId: $habitId, ')
          ..write('lastEvaluatedAt: $lastEvaluatedAt, ')
          ..write('responseWindowJson: $responseWindowJson, ')
          ..write('currentOffsetsJson: $currentOffsetsJson, ')
          ..write('streakCount: $streakCount, ')
          ..write('lastMissAt: $lastMissAt, ')
          ..write('currentToneKey: $currentToneKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    habitId,
    lastEvaluatedAt,
    responseWindowJson,
    currentOffsetsJson,
    streakCount,
    lastMissAt,
    currentToneKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdaptiveStateData &&
          other.habitId == this.habitId &&
          other.lastEvaluatedAt == this.lastEvaluatedAt &&
          other.responseWindowJson == this.responseWindowJson &&
          other.currentOffsetsJson == this.currentOffsetsJson &&
          other.streakCount == this.streakCount &&
          other.lastMissAt == this.lastMissAt &&
          other.currentToneKey == this.currentToneKey);
}

class AdaptiveStateCompanion extends UpdateCompanion<AdaptiveStateData> {
  final Value<String> habitId;
  final Value<DateTime> lastEvaluatedAt;
  final Value<String> responseWindowJson;
  final Value<String> currentOffsetsJson;
  final Value<int> streakCount;
  final Value<DateTime?> lastMissAt;
  final Value<String?> currentToneKey;
  final Value<int> rowid;
  const AdaptiveStateCompanion({
    this.habitId = const Value.absent(),
    this.lastEvaluatedAt = const Value.absent(),
    this.responseWindowJson = const Value.absent(),
    this.currentOffsetsJson = const Value.absent(),
    this.streakCount = const Value.absent(),
    this.lastMissAt = const Value.absent(),
    this.currentToneKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdaptiveStateCompanion.insert({
    required String habitId,
    required DateTime lastEvaluatedAt,
    this.responseWindowJson = const Value.absent(),
    this.currentOffsetsJson = const Value.absent(),
    this.streakCount = const Value.absent(),
    this.lastMissAt = const Value.absent(),
    this.currentToneKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId),
       lastEvaluatedAt = Value(lastEvaluatedAt);
  static Insertable<AdaptiveStateData> custom({
    Expression<String>? habitId,
    Expression<DateTime>? lastEvaluatedAt,
    Expression<String>? responseWindowJson,
    Expression<String>? currentOffsetsJson,
    Expression<int>? streakCount,
    Expression<DateTime>? lastMissAt,
    Expression<String>? currentToneKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (lastEvaluatedAt != null) 'last_evaluated_at': lastEvaluatedAt,
      if (responseWindowJson != null)
        'response_window_json': responseWindowJson,
      if (currentOffsetsJson != null)
        'current_offsets_json': currentOffsetsJson,
      if (streakCount != null) 'streak_count': streakCount,
      if (lastMissAt != null) 'last_miss_at': lastMissAt,
      if (currentToneKey != null) 'current_tone_key': currentToneKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdaptiveStateCompanion copyWith({
    Value<String>? habitId,
    Value<DateTime>? lastEvaluatedAt,
    Value<String>? responseWindowJson,
    Value<String>? currentOffsetsJson,
    Value<int>? streakCount,
    Value<DateTime?>? lastMissAt,
    Value<String?>? currentToneKey,
    Value<int>? rowid,
  }) {
    return AdaptiveStateCompanion(
      habitId: habitId ?? this.habitId,
      lastEvaluatedAt: lastEvaluatedAt ?? this.lastEvaluatedAt,
      responseWindowJson: responseWindowJson ?? this.responseWindowJson,
      currentOffsetsJson: currentOffsetsJson ?? this.currentOffsetsJson,
      streakCount: streakCount ?? this.streakCount,
      lastMissAt: lastMissAt ?? this.lastMissAt,
      currentToneKey: currentToneKey ?? this.currentToneKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (lastEvaluatedAt.present) {
      map['last_evaluated_at'] = Variable<DateTime>(lastEvaluatedAt.value);
    }
    if (responseWindowJson.present) {
      map['response_window_json'] = Variable<String>(responseWindowJson.value);
    }
    if (currentOffsetsJson.present) {
      map['current_offsets_json'] = Variable<String>(currentOffsetsJson.value);
    }
    if (streakCount.present) {
      map['streak_count'] = Variable<int>(streakCount.value);
    }
    if (lastMissAt.present) {
      map['last_miss_at'] = Variable<DateTime>(lastMissAt.value);
    }
    if (currentToneKey.present) {
      map['current_tone_key'] = Variable<String>(currentToneKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdaptiveStateCompanion(')
          ..write('habitId: $habitId, ')
          ..write('lastEvaluatedAt: $lastEvaluatedAt, ')
          ..write('responseWindowJson: $responseWindowJson, ')
          ..write('currentOffsetsJson: $currentOffsetsJson, ')
          ..write('streakCount: $streakCount, ')
          ..write('lastMissAt: $lastMissAt, ')
          ..write('currentToneKey: $currentToneKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserCategoriesTable extends UserCategories
    with TableInfo<$UserCategoriesTable, UserCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
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
  @override
  List<GeneratedColumn> get $columns => [id, label, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserCategoriesTable createAlias(String alias) {
    return $UserCategoriesTable(attachedDatabase, alias);
  }
}

class UserCategory extends DataClass implements Insertable<UserCategory> {
  final String id;
  final String label;
  final DateTime createdAt;
  const UserCategory({
    required this.id,
    required this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserCategoriesCompanion toCompanion(bool nullToAbsent) {
    return UserCategoriesCompanion(
      id: Value(id),
      label: Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory UserCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCategory(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserCategory copyWith({String? id, String? label, DateTime? createdAt}) =>
      UserCategory(
        id: id ?? this.id,
        label: label ?? this.label,
        createdAt: createdAt ?? this.createdAt,
      );
  UserCategory copyWithCompanion(UserCategoriesCompanion data) {
    return UserCategory(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCategory(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCategory &&
          other.id == this.id &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class UserCategoriesCompanion extends UpdateCompanion<UserCategory> {
  final Value<String> id;
  final Value<String> label;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserCategoriesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserCategoriesCompanion.insert({
    required String id,
    required String label,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       createdAt = Value(createdAt);
  static Insertable<UserCategory> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UserCategoriesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BuddyProgressTable extends BuddyProgress
    with TableInfo<$BuddyProgressTable, BuddyProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuddyProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _buddyIdMeta = const VerificationMeta(
    'buddyId',
  );
  @override
  late final GeneratedColumn<String> buddyId = GeneratedColumn<String>(
    'buddy_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalScoreMeta = const VerificationMeta(
    'totalScore',
  );
  @override
  late final GeneratedColumn<int> totalScore = GeneratedColumn<int>(
    'total_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastScoredDayEpochMeta =
      const VerificationMeta('lastScoredDayEpoch');
  @override
  late final GeneratedColumn<int> lastScoredDayEpoch = GeneratedColumn<int>(
    'last_scored_day_epoch',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxStageReachedMeta = const VerificationMeta(
    'maxStageReached',
  );
  @override
  late final GeneratedColumn<int> maxStageReached = GeneratedColumn<int>(
    'max_stage_reached',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    buddyId,
    totalScore,
    lastScoredDayEpoch,
    maxStageReached,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'buddy_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<BuddyProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('buddy_id')) {
      context.handle(
        _buddyIdMeta,
        buddyId.isAcceptableOrUnknown(data['buddy_id']!, _buddyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_buddyIdMeta);
    }
    if (data.containsKey('total_score')) {
      context.handle(
        _totalScoreMeta,
        totalScore.isAcceptableOrUnknown(data['total_score']!, _totalScoreMeta),
      );
    }
    if (data.containsKey('last_scored_day_epoch')) {
      context.handle(
        _lastScoredDayEpochMeta,
        lastScoredDayEpoch.isAcceptableOrUnknown(
          data['last_scored_day_epoch']!,
          _lastScoredDayEpochMeta,
        ),
      );
    }
    if (data.containsKey('max_stage_reached')) {
      context.handle(
        _maxStageReachedMeta,
        maxStageReached.isAcceptableOrUnknown(
          data['max_stage_reached']!,
          _maxStageReachedMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {buddyId};
  @override
  BuddyProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BuddyProgressData(
      buddyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buddy_id'],
      )!,
      totalScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_score'],
      )!,
      lastScoredDayEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_scored_day_epoch'],
      ),
      maxStageReached: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_stage_reached'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BuddyProgressTable createAlias(String alias) {
    return $BuddyProgressTable(attachedDatabase, alias);
  }
}

class BuddyProgressData extends DataClass
    implements Insertable<BuddyProgressData> {
  final String buddyId;
  final int totalScore;
  final int? lastScoredDayEpoch;
  final int maxStageReached;
  final DateTime updatedAt;
  const BuddyProgressData({
    required this.buddyId,
    required this.totalScore,
    this.lastScoredDayEpoch,
    required this.maxStageReached,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['buddy_id'] = Variable<String>(buddyId);
    map['total_score'] = Variable<int>(totalScore);
    if (!nullToAbsent || lastScoredDayEpoch != null) {
      map['last_scored_day_epoch'] = Variable<int>(lastScoredDayEpoch);
    }
    map['max_stage_reached'] = Variable<int>(maxStageReached);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BuddyProgressCompanion toCompanion(bool nullToAbsent) {
    return BuddyProgressCompanion(
      buddyId: Value(buddyId),
      totalScore: Value(totalScore),
      lastScoredDayEpoch: lastScoredDayEpoch == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScoredDayEpoch),
      maxStageReached: Value(maxStageReached),
      updatedAt: Value(updatedAt),
    );
  }

  factory BuddyProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BuddyProgressData(
      buddyId: serializer.fromJson<String>(json['buddyId']),
      totalScore: serializer.fromJson<int>(json['totalScore']),
      lastScoredDayEpoch: serializer.fromJson<int?>(json['lastScoredDayEpoch']),
      maxStageReached: serializer.fromJson<int>(json['maxStageReached']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'buddyId': serializer.toJson<String>(buddyId),
      'totalScore': serializer.toJson<int>(totalScore),
      'lastScoredDayEpoch': serializer.toJson<int?>(lastScoredDayEpoch),
      'maxStageReached': serializer.toJson<int>(maxStageReached),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BuddyProgressData copyWith({
    String? buddyId,
    int? totalScore,
    Value<int?> lastScoredDayEpoch = const Value.absent(),
    int? maxStageReached,
    DateTime? updatedAt,
  }) => BuddyProgressData(
    buddyId: buddyId ?? this.buddyId,
    totalScore: totalScore ?? this.totalScore,
    lastScoredDayEpoch: lastScoredDayEpoch.present
        ? lastScoredDayEpoch.value
        : this.lastScoredDayEpoch,
    maxStageReached: maxStageReached ?? this.maxStageReached,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BuddyProgressData copyWithCompanion(BuddyProgressCompanion data) {
    return BuddyProgressData(
      buddyId: data.buddyId.present ? data.buddyId.value : this.buddyId,
      totalScore: data.totalScore.present
          ? data.totalScore.value
          : this.totalScore,
      lastScoredDayEpoch: data.lastScoredDayEpoch.present
          ? data.lastScoredDayEpoch.value
          : this.lastScoredDayEpoch,
      maxStageReached: data.maxStageReached.present
          ? data.maxStageReached.value
          : this.maxStageReached,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BuddyProgressData(')
          ..write('buddyId: $buddyId, ')
          ..write('totalScore: $totalScore, ')
          ..write('lastScoredDayEpoch: $lastScoredDayEpoch, ')
          ..write('maxStageReached: $maxStageReached, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    buddyId,
    totalScore,
    lastScoredDayEpoch,
    maxStageReached,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BuddyProgressData &&
          other.buddyId == this.buddyId &&
          other.totalScore == this.totalScore &&
          other.lastScoredDayEpoch == this.lastScoredDayEpoch &&
          other.maxStageReached == this.maxStageReached &&
          other.updatedAt == this.updatedAt);
}

class BuddyProgressCompanion extends UpdateCompanion<BuddyProgressData> {
  final Value<String> buddyId;
  final Value<int> totalScore;
  final Value<int?> lastScoredDayEpoch;
  final Value<int> maxStageReached;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BuddyProgressCompanion({
    this.buddyId = const Value.absent(),
    this.totalScore = const Value.absent(),
    this.lastScoredDayEpoch = const Value.absent(),
    this.maxStageReached = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BuddyProgressCompanion.insert({
    required String buddyId,
    this.totalScore = const Value.absent(),
    this.lastScoredDayEpoch = const Value.absent(),
    this.maxStageReached = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : buddyId = Value(buddyId),
       updatedAt = Value(updatedAt);
  static Insertable<BuddyProgressData> custom({
    Expression<String>? buddyId,
    Expression<int>? totalScore,
    Expression<int>? lastScoredDayEpoch,
    Expression<int>? maxStageReached,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (buddyId != null) 'buddy_id': buddyId,
      if (totalScore != null) 'total_score': totalScore,
      if (lastScoredDayEpoch != null)
        'last_scored_day_epoch': lastScoredDayEpoch,
      if (maxStageReached != null) 'max_stage_reached': maxStageReached,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BuddyProgressCompanion copyWith({
    Value<String>? buddyId,
    Value<int>? totalScore,
    Value<int?>? lastScoredDayEpoch,
    Value<int>? maxStageReached,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BuddyProgressCompanion(
      buddyId: buddyId ?? this.buddyId,
      totalScore: totalScore ?? this.totalScore,
      lastScoredDayEpoch: lastScoredDayEpoch ?? this.lastScoredDayEpoch,
      maxStageReached: maxStageReached ?? this.maxStageReached,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (buddyId.present) {
      map['buddy_id'] = Variable<String>(buddyId.value);
    }
    if (totalScore.present) {
      map['total_score'] = Variable<int>(totalScore.value);
    }
    if (lastScoredDayEpoch.present) {
      map['last_scored_day_epoch'] = Variable<int>(lastScoredDayEpoch.value);
    }
    if (maxStageReached.present) {
      map['max_stage_reached'] = Variable<int>(maxStageReached.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuddyProgressCompanion(')
          ..write('buddyId: $buddyId, ')
          ..write('totalScore: $totalScore, ')
          ..write('lastScoredDayEpoch: $lastScoredDayEpoch, ')
          ..write('maxStageReached: $maxStageReached, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $ScheduleSlotsTable scheduleSlots = $ScheduleSlotsTable(this);
  late final $NotificationLogTable notificationLog = $NotificationLogTable(
    this,
  );
  late final $UserProfileTableTable userProfileTable = $UserProfileTableTable(
    this,
  );
  late final $ProfileSignalsTable profileSignals = $ProfileSignalsTable(this);
  late final $AdaptiveStateTable adaptiveState = $AdaptiveStateTable(this);
  late final $UserCategoriesTable userCategories = $UserCategoriesTable(this);
  late final $BuddyProgressTable buddyProgress = $BuddyProgressTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    goals,
    habits,
    scheduleSlots,
    notificationLog,
    userProfileTable,
    profileSignals,
    adaptiveState,
    userCategories,
    buddyProgress,
  ];
}

typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<DateTime?> archivedAt,
      Value<int> displayOrder,
      Value<int> rowid,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<DateTime?> archivedAt,
      Value<int> displayOrder,
      Value<int> rowid,
    });

final class $$GoalsTableReferences
    extends BaseReferences<_$AppDb, $GoalsTable, Goal> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitsTable, List<Habit>> _habitsRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.habits,
    aliasName: $_aliasNameGenerator(db.goals.id, db.habits.goalId),
  );

  $$HabitsTableProcessedTableManager get habitsRefs {
    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDb, $GoalsTable> {
  $$GoalsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> habitsRefs(
    Expression<bool> Function($$HabitsTableFilterComposer f) f,
  ) {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer extends Composer<_$AppDb, $GoalsTable> {
  $$GoalsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer extends Composer<_$AppDb, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  Expression<T> habitsRefs<T extends Object>(
    Expression<T> Function($$HabitsTableAnnotationComposer a) f,
  ) {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, $$GoalsTableReferences),
          Goal,
          PrefetchHooks Function({bool habitsRefs})
        > {
  $$GoalsTableTableManager(_$AppDb db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                title: title,
                description: description,
                createdAt: createdAt,
                completedAt: completedAt,
                archivedAt: archivedAt,
                displayOrder: displayOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                title: title,
                description: description,
                createdAt: createdAt,
                completedAt: completedAt,
                archivedAt: archivedAt,
                displayOrder: displayOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GoalsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({habitsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (habitsRefs) db.habits],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (habitsRefs)
                    await $_getPrefetchedData<Goal, $GoalsTable, Habit>(
                      currentTable: table,
                      referencedTable: $$GoalsTableReferences._habitsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$GoalsTableReferences(db, table, p0).habitsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.goalId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, $$GoalsTableReferences),
      Goal,
      PrefetchHooks Function({bool habitsRefs})
    >;
typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      required String id,
      Value<String?> goalId,
      required String name,
      required String category,
      Value<String?> customMessage,
      required String kind,
      Value<String> alarmStyle,
      Value<bool> active,
      Value<DateTime?> completedAt,
      Value<String> timeWindow,
      Value<String> timeWindowsJson,
      Value<int?> customStartMinutes,
      Value<int?> customEndMinutes,
      Value<int?> targetPerWeek,
      Value<int?> preferredWeekday,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<String> id,
      Value<String?> goalId,
      Value<String> name,
      Value<String> category,
      Value<String?> customMessage,
      Value<String> kind,
      Value<String> alarmStyle,
      Value<bool> active,
      Value<DateTime?> completedAt,
      Value<String> timeWindow,
      Value<String> timeWindowsJson,
      Value<int?> customStartMinutes,
      Value<int?> customEndMinutes,
      Value<int?> targetPerWeek,
      Value<int?> preferredWeekday,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDb, $HabitsTable, Habit> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GoalsTable _goalIdTable(_$AppDb db) =>
      db.goals.createAlias($_aliasNameGenerator(db.habits.goalId, db.goals.id));

  $$GoalsTableProcessedTableManager? get goalId {
    final $_column = $_itemColumn<String>('goal_id');
    if ($_column == null) return null;
    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ScheduleSlotsTable, List<ScheduleSlot>>
  _scheduleSlotsRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.scheduleSlots,
    aliasName: $_aliasNameGenerator(db.habits.id, db.scheduleSlots.habitId),
  );

  $$ScheduleSlotsTableProcessedTableManager get scheduleSlotsRefs {
    final manager = $$ScheduleSlotsTableTableManager(
      $_db,
      $_db.scheduleSlots,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scheduleSlotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotificationLogTable, List<NotificationLogData>>
  _notificationLogRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.notificationLog,
    aliasName: $_aliasNameGenerator(db.habits.id, db.notificationLog.habitId),
  );

  $$NotificationLogTableProcessedTableManager get notificationLogRefs {
    final manager = $$NotificationLogTableTableManager(
      $_db,
      $_db.notificationLog,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _notificationLogRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AdaptiveStateTable, List<AdaptiveStateData>>
  _adaptiveStateRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.adaptiveState,
    aliasName: $_aliasNameGenerator(db.habits.id, db.adaptiveState.habitId),
  );

  $$AdaptiveStateTableProcessedTableManager get adaptiveStateRefs {
    final manager = $$AdaptiveStateTableTableManager(
      $_db,
      $_db.adaptiveState,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_adaptiveStateRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer extends Composer<_$AppDb, $HabitsTable> {
  $$HabitsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customMessage => $composableBuilder(
    column: $table.customMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alarmStyle => $composableBuilder(
    column: $table.alarmStyle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeWindow => $composableBuilder(
    column: $table.timeWindow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeWindowsJson => $composableBuilder(
    column: $table.timeWindowsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customStartMinutes => $composableBuilder(
    column: $table.customStartMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customEndMinutes => $composableBuilder(
    column: $table.customEndMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetPerWeek => $composableBuilder(
    column: $table.targetPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preferredWeekday => $composableBuilder(
    column: $table.preferredWeekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> scheduleSlotsRefs(
    Expression<bool> Function($$ScheduleSlotsTableFilterComposer f) f,
  ) {
    final $$ScheduleSlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleSlots,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleSlotsTableFilterComposer(
            $db: $db,
            $table: $db.scheduleSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notificationLogRefs(
    Expression<bool> Function($$NotificationLogTableFilterComposer f) f,
  ) {
    final $$NotificationLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notificationLog,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotificationLogTableFilterComposer(
            $db: $db,
            $table: $db.notificationLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> adaptiveStateRefs(
    Expression<bool> Function($$AdaptiveStateTableFilterComposer f) f,
  ) {
    final $$AdaptiveStateTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adaptiveState,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdaptiveStateTableFilterComposer(
            $db: $db,
            $table: $db.adaptiveState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer extends Composer<_$AppDb, $HabitsTable> {
  $$HabitsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customMessage => $composableBuilder(
    column: $table.customMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alarmStyle => $composableBuilder(
    column: $table.alarmStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeWindow => $composableBuilder(
    column: $table.timeWindow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeWindowsJson => $composableBuilder(
    column: $table.timeWindowsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customStartMinutes => $composableBuilder(
    column: $table.customStartMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customEndMinutes => $composableBuilder(
    column: $table.customEndMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPerWeek => $composableBuilder(
    column: $table.targetPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preferredWeekday => $composableBuilder(
    column: $table.preferredWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitsTableAnnotationComposer extends Composer<_$AppDb, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get customMessage => $composableBuilder(
    column: $table.customMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get alarmStyle => $composableBuilder(
    column: $table.alarmStyle,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeWindow => $composableBuilder(
    column: $table.timeWindow,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeWindowsJson => $composableBuilder(
    column: $table.timeWindowsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customStartMinutes => $composableBuilder(
    column: $table.customStartMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customEndMinutes => $composableBuilder(
    column: $table.customEndMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetPerWeek => $composableBuilder(
    column: $table.targetPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preferredWeekday => $composableBuilder(
    column: $table.preferredWeekday,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> scheduleSlotsRefs<T extends Object>(
    Expression<T> Function($$ScheduleSlotsTableAnnotationComposer a) f,
  ) {
    final $$ScheduleSlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleSlots,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleSlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.scheduleSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notificationLogRefs<T extends Object>(
    Expression<T> Function($$NotificationLogTableAnnotationComposer a) f,
  ) {
    final $$NotificationLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notificationLog,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotificationLogTableAnnotationComposer(
            $db: $db,
            $table: $db.notificationLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> adaptiveStateRefs<T extends Object>(
    Expression<T> Function($$AdaptiveStateTableAnnotationComposer a) f,
  ) {
    final $$AdaptiveStateTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adaptiveState,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdaptiveStateTableAnnotationComposer(
            $db: $db,
            $table: $db.adaptiveState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, $$HabitsTableReferences),
          Habit,
          PrefetchHooks Function({
            bool goalId,
            bool scheduleSlotsRefs,
            bool notificationLogRefs,
            bool adaptiveStateRefs,
          })
        > {
  $$HabitsTableTableManager(_$AppDb db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> goalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> customMessage = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> alarmStyle = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> timeWindow = const Value.absent(),
                Value<String> timeWindowsJson = const Value.absent(),
                Value<int?> customStartMinutes = const Value.absent(),
                Value<int?> customEndMinutes = const Value.absent(),
                Value<int?> targetPerWeek = const Value.absent(),
                Value<int?> preferredWeekday = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                goalId: goalId,
                name: name,
                category: category,
                customMessage: customMessage,
                kind: kind,
                alarmStyle: alarmStyle,
                active: active,
                completedAt: completedAt,
                timeWindow: timeWindow,
                timeWindowsJson: timeWindowsJson,
                customStartMinutes: customStartMinutes,
                customEndMinutes: customEndMinutes,
                targetPerWeek: targetPerWeek,
                preferredWeekday: preferredWeekday,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> goalId = const Value.absent(),
                required String name,
                required String category,
                Value<String?> customMessage = const Value.absent(),
                required String kind,
                Value<String> alarmStyle = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> timeWindow = const Value.absent(),
                Value<String> timeWindowsJson = const Value.absent(),
                Value<int?> customStartMinutes = const Value.absent(),
                Value<int?> customEndMinutes = const Value.absent(),
                Value<int?> targetPerWeek = const Value.absent(),
                Value<int?> preferredWeekday = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                goalId: goalId,
                name: name,
                category: category,
                customMessage: customMessage,
                kind: kind,
                alarmStyle: alarmStyle,
                active: active,
                completedAt: completedAt,
                timeWindow: timeWindow,
                timeWindowsJson: timeWindowsJson,
                customStartMinutes: customStartMinutes,
                customEndMinutes: customEndMinutes,
                targetPerWeek: targetPerWeek,
                preferredWeekday: preferredWeekday,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HabitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                goalId = false,
                scheduleSlotsRefs = false,
                notificationLogRefs = false,
                adaptiveStateRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scheduleSlotsRefs) db.scheduleSlots,
                    if (notificationLogRefs) db.notificationLog,
                    if (adaptiveStateRefs) db.adaptiveState,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (goalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.goalId,
                                    referencedTable: $$HabitsTableReferences
                                        ._goalIdTable(db),
                                    referencedColumn: $$HabitsTableReferences
                                        ._goalIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scheduleSlotsRefs)
                        await $_getPrefetchedData<
                          Habit,
                          $HabitsTable,
                          ScheduleSlot
                        >(
                          currentTable: table,
                          referencedTable: $$HabitsTableReferences
                              ._scheduleSlotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitsTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduleSlotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notificationLogRefs)
                        await $_getPrefetchedData<
                          Habit,
                          $HabitsTable,
                          NotificationLogData
                        >(
                          currentTable: table,
                          referencedTable: $$HabitsTableReferences
                              ._notificationLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitsTableReferences(
                                db,
                                table,
                                p0,
                              ).notificationLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (adaptiveStateRefs)
                        await $_getPrefetchedData<
                          Habit,
                          $HabitsTable,
                          AdaptiveStateData
                        >(
                          currentTable: table,
                          referencedTable: $$HabitsTableReferences
                              ._adaptiveStateRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitsTableReferences(
                                db,
                                table,
                                p0,
                              ).adaptiveStateRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, $$HabitsTableReferences),
      Habit,
      PrefetchHooks Function({
        bool goalId,
        bool scheduleSlotsRefs,
        bool notificationLogRefs,
        bool adaptiveStateRefs,
      })
    >;
typedef $$ScheduleSlotsTableCreateCompanionBuilder =
    ScheduleSlotsCompanion Function({
      Value<int> id,
      required String habitId,
      required String kind,
      required int timeOfDay,
      Value<int> weekdayMask,
      Value<bool> enabled,
    });
typedef $$ScheduleSlotsTableUpdateCompanionBuilder =
    ScheduleSlotsCompanion Function({
      Value<int> id,
      Value<String> habitId,
      Value<String> kind,
      Value<int> timeOfDay,
      Value<int> weekdayMask,
      Value<bool> enabled,
    });

final class $$ScheduleSlotsTableReferences
    extends BaseReferences<_$AppDb, $ScheduleSlotsTable, ScheduleSlot> {
  $$ScheduleSlotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitsTable _habitIdTable(_$AppDb db) => db.habits.createAlias(
    $_aliasNameGenerator(db.scheduleSlots.habitId, db.habits.id),
  );

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<String>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScheduleSlotsTableFilterComposer
    extends Composer<_$AppDb, $ScheduleSlotsTable> {
  $$ScheduleSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeOfDay => $composableBuilder(
    column: $table.timeOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleSlotsTableOrderingComposer
    extends Composer<_$AppDb, $ScheduleSlotsTable> {
  $$ScheduleSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeOfDay => $composableBuilder(
    column: $table.timeOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleSlotsTableAnnotationComposer
    extends Composer<_$AppDb, $ScheduleSlotsTable> {
  $$ScheduleSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get timeOfDay =>
      $composableBuilder(column: $table.timeOfDay, builder: (column) => column);

  GeneratedColumn<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleSlotsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ScheduleSlotsTable,
          ScheduleSlot,
          $$ScheduleSlotsTableFilterComposer,
          $$ScheduleSlotsTableOrderingComposer,
          $$ScheduleSlotsTableAnnotationComposer,
          $$ScheduleSlotsTableCreateCompanionBuilder,
          $$ScheduleSlotsTableUpdateCompanionBuilder,
          (ScheduleSlot, $$ScheduleSlotsTableReferences),
          ScheduleSlot,
          PrefetchHooks Function({bool habitId})
        > {
  $$ScheduleSlotsTableTableManager(_$AppDb db, $ScheduleSlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> timeOfDay = const Value.absent(),
                Value<int> weekdayMask = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => ScheduleSlotsCompanion(
                id: id,
                habitId: habitId,
                kind: kind,
                timeOfDay: timeOfDay,
                weekdayMask: weekdayMask,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String habitId,
                required String kind,
                required int timeOfDay,
                Value<int> weekdayMask = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => ScheduleSlotsCompanion.insert(
                id: id,
                habitId: habitId,
                kind: kind,
                timeOfDay: timeOfDay,
                weekdayMask: weekdayMask,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScheduleSlotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$ScheduleSlotsTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$ScheduleSlotsTableReferences
                                    ._habitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScheduleSlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ScheduleSlotsTable,
      ScheduleSlot,
      $$ScheduleSlotsTableFilterComposer,
      $$ScheduleSlotsTableOrderingComposer,
      $$ScheduleSlotsTableAnnotationComposer,
      $$ScheduleSlotsTableCreateCompanionBuilder,
      $$ScheduleSlotsTableUpdateCompanionBuilder,
      (ScheduleSlot, $$ScheduleSlotsTableReferences),
      ScheduleSlot,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$NotificationLogTableCreateCompanionBuilder =
    NotificationLogCompanion Function({
      Value<int> id,
      required String habitId,
      required DateTime scheduledFor,
      Value<DateTime?> firedAt,
      required String response,
      Value<DateTime?> respondedAt,
      required String source,
      Value<String?> toneUsed,
    });
typedef $$NotificationLogTableUpdateCompanionBuilder =
    NotificationLogCompanion Function({
      Value<int> id,
      Value<String> habitId,
      Value<DateTime> scheduledFor,
      Value<DateTime?> firedAt,
      Value<String> response,
      Value<DateTime?> respondedAt,
      Value<String> source,
      Value<String?> toneUsed,
    });

final class $$NotificationLogTableReferences
    extends
        BaseReferences<_$AppDb, $NotificationLogTable, NotificationLogData> {
  $$NotificationLogTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitsTable _habitIdTable(_$AppDb db) => db.habits.createAlias(
    $_aliasNameGenerator(db.notificationLog.habitId, db.habits.id),
  );

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<String>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotificationLogTableFilterComposer
    extends Composer<_$AppDb, $NotificationLogTable> {
  $$NotificationLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firedAt => $composableBuilder(
    column: $table.firedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get response => $composableBuilder(
    column: $table.response,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get respondedAt => $composableBuilder(
    column: $table.respondedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toneUsed => $composableBuilder(
    column: $table.toneUsed,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationLogTableOrderingComposer
    extends Composer<_$AppDb, $NotificationLogTable> {
  $$NotificationLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firedAt => $composableBuilder(
    column: $table.firedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get response => $composableBuilder(
    column: $table.response,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get respondedAt => $composableBuilder(
    column: $table.respondedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toneUsed => $composableBuilder(
    column: $table.toneUsed,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationLogTableAnnotationComposer
    extends Composer<_$AppDb, $NotificationLogTable> {
  $$NotificationLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firedAt =>
      $composableBuilder(column: $table.firedAt, builder: (column) => column);

  GeneratedColumn<String> get response =>
      $composableBuilder(column: $table.response, builder: (column) => column);

  GeneratedColumn<DateTime> get respondedAt => $composableBuilder(
    column: $table.respondedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get toneUsed =>
      $composableBuilder(column: $table.toneUsed, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationLogTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $NotificationLogTable,
          NotificationLogData,
          $$NotificationLogTableFilterComposer,
          $$NotificationLogTableOrderingComposer,
          $$NotificationLogTableAnnotationComposer,
          $$NotificationLogTableCreateCompanionBuilder,
          $$NotificationLogTableUpdateCompanionBuilder,
          (NotificationLogData, $$NotificationLogTableReferences),
          NotificationLogData,
          PrefetchHooks Function({bool habitId})
        > {
  $$NotificationLogTableTableManager(_$AppDb db, $NotificationLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<DateTime> scheduledFor = const Value.absent(),
                Value<DateTime?> firedAt = const Value.absent(),
                Value<String> response = const Value.absent(),
                Value<DateTime?> respondedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> toneUsed = const Value.absent(),
              }) => NotificationLogCompanion(
                id: id,
                habitId: habitId,
                scheduledFor: scheduledFor,
                firedAt: firedAt,
                response: response,
                respondedAt: respondedAt,
                source: source,
                toneUsed: toneUsed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String habitId,
                required DateTime scheduledFor,
                Value<DateTime?> firedAt = const Value.absent(),
                required String response,
                Value<DateTime?> respondedAt = const Value.absent(),
                required String source,
                Value<String?> toneUsed = const Value.absent(),
              }) => NotificationLogCompanion.insert(
                id: id,
                habitId: habitId,
                scheduledFor: scheduledFor,
                firedAt: firedAt,
                response: response,
                respondedAt: respondedAt,
                source: source,
                toneUsed: toneUsed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NotificationLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable:
                                    $$NotificationLogTableReferences
                                        ._habitIdTable(db),
                                referencedColumn:
                                    $$NotificationLogTableReferences
                                        ._habitIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotificationLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $NotificationLogTable,
      NotificationLogData,
      $$NotificationLogTableFilterComposer,
      $$NotificationLogTableOrderingComposer,
      $$NotificationLogTableAnnotationComposer,
      $$NotificationLogTableCreateCompanionBuilder,
      $$NotificationLogTableUpdateCompanionBuilder,
      (NotificationLogData, $$NotificationLogTableReferences),
      NotificationLogData,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$UserProfileTableTableCreateCompanionBuilder =
    UserProfileTableCompanion Function({
      Value<int> id,
      Value<String> tonePreference,
      Value<int> dailyNotifBudget,
      Value<String> wakingWindowJson,
      Value<String> slotPreferencesJson,
      Value<String> weekdayOverridesJson,
      Value<String> goalsJson,
      Value<bool> followUpEnabled,
      Value<bool> popupEnabled,
      Value<bool> vibrationEnabled,
      Value<bool> soundEnabled,
      Value<int> ttlMinutes,
      Value<bool> onboarded,
      Value<String?> selectedBuddy,
      Value<String> themeId,
      Value<int?> customPrimaryColor,
      Value<int?> customAccentColor,
      Value<int?> customBackgroundColor,
      Value<String> bgBase,
      Value<int> bgTintColor,
      Value<int> bgTintStrength,
      Value<String> darkMode,
      Value<String> presenceMode,
      Value<String> widgetColorMode,
      Value<bool> widgetShowCount,
      Value<String> buddyOrderJson,
      Value<bool> customSoundsEnabled,
      required DateTime updatedAt,
    });
typedef $$UserProfileTableTableUpdateCompanionBuilder =
    UserProfileTableCompanion Function({
      Value<int> id,
      Value<String> tonePreference,
      Value<int> dailyNotifBudget,
      Value<String> wakingWindowJson,
      Value<String> slotPreferencesJson,
      Value<String> weekdayOverridesJson,
      Value<String> goalsJson,
      Value<bool> followUpEnabled,
      Value<bool> popupEnabled,
      Value<bool> vibrationEnabled,
      Value<bool> soundEnabled,
      Value<int> ttlMinutes,
      Value<bool> onboarded,
      Value<String?> selectedBuddy,
      Value<String> themeId,
      Value<int?> customPrimaryColor,
      Value<int?> customAccentColor,
      Value<int?> customBackgroundColor,
      Value<String> bgBase,
      Value<int> bgTintColor,
      Value<int> bgTintStrength,
      Value<String> darkMode,
      Value<String> presenceMode,
      Value<String> widgetColorMode,
      Value<bool> widgetShowCount,
      Value<String> buddyOrderJson,
      Value<bool> customSoundsEnabled,
      Value<DateTime> updatedAt,
    });

class $$UserProfileTableTableFilterComposer
    extends Composer<_$AppDb, $UserProfileTableTable> {
  $$UserProfileTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tonePreference => $composableBuilder(
    column: $table.tonePreference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyNotifBudget => $composableBuilder(
    column: $table.dailyNotifBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wakingWindowJson => $composableBuilder(
    column: $table.wakingWindowJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slotPreferencesJson => $composableBuilder(
    column: $table.slotPreferencesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekdayOverridesJson => $composableBuilder(
    column: $table.weekdayOverridesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalsJson => $composableBuilder(
    column: $table.goalsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get followUpEnabled => $composableBuilder(
    column: $table.followUpEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get popupEnabled => $composableBuilder(
    column: $table.popupEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ttlMinutes => $composableBuilder(
    column: $table.ttlMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedBuddy => $composableBuilder(
    column: $table.selectedBuddy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeId => $composableBuilder(
    column: $table.themeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customPrimaryColor => $composableBuilder(
    column: $table.customPrimaryColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customAccentColor => $composableBuilder(
    column: $table.customAccentColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customBackgroundColor => $composableBuilder(
    column: $table.customBackgroundColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bgBase => $composableBuilder(
    column: $table.bgBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bgTintColor => $composableBuilder(
    column: $table.bgTintColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bgTintStrength => $composableBuilder(
    column: $table.bgTintStrength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get darkMode => $composableBuilder(
    column: $table.darkMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presenceMode => $composableBuilder(
    column: $table.presenceMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get widgetColorMode => $composableBuilder(
    column: $table.widgetColorMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get widgetShowCount => $composableBuilder(
    column: $table.widgetShowCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buddyOrderJson => $composableBuilder(
    column: $table.buddyOrderJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get customSoundsEnabled => $composableBuilder(
    column: $table.customSoundsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfileTableTableOrderingComposer
    extends Composer<_$AppDb, $UserProfileTableTable> {
  $$UserProfileTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tonePreference => $composableBuilder(
    column: $table.tonePreference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyNotifBudget => $composableBuilder(
    column: $table.dailyNotifBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wakingWindowJson => $composableBuilder(
    column: $table.wakingWindowJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slotPreferencesJson => $composableBuilder(
    column: $table.slotPreferencesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdayOverridesJson => $composableBuilder(
    column: $table.weekdayOverridesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalsJson => $composableBuilder(
    column: $table.goalsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get followUpEnabled => $composableBuilder(
    column: $table.followUpEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get popupEnabled => $composableBuilder(
    column: $table.popupEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ttlMinutes => $composableBuilder(
    column: $table.ttlMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedBuddy => $composableBuilder(
    column: $table.selectedBuddy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeId => $composableBuilder(
    column: $table.themeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customPrimaryColor => $composableBuilder(
    column: $table.customPrimaryColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customAccentColor => $composableBuilder(
    column: $table.customAccentColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customBackgroundColor => $composableBuilder(
    column: $table.customBackgroundColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bgBase => $composableBuilder(
    column: $table.bgBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bgTintColor => $composableBuilder(
    column: $table.bgTintColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bgTintStrength => $composableBuilder(
    column: $table.bgTintStrength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get darkMode => $composableBuilder(
    column: $table.darkMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presenceMode => $composableBuilder(
    column: $table.presenceMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get widgetColorMode => $composableBuilder(
    column: $table.widgetColorMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get widgetShowCount => $composableBuilder(
    column: $table.widgetShowCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buddyOrderJson => $composableBuilder(
    column: $table.buddyOrderJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get customSoundsEnabled => $composableBuilder(
    column: $table.customSoundsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfileTableTableAnnotationComposer
    extends Composer<_$AppDb, $UserProfileTableTable> {
  $$UserProfileTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tonePreference => $composableBuilder(
    column: $table.tonePreference,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyNotifBudget => $composableBuilder(
    column: $table.dailyNotifBudget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wakingWindowJson => $composableBuilder(
    column: $table.wakingWindowJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get slotPreferencesJson => $composableBuilder(
    column: $table.slotPreferencesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekdayOverridesJson => $composableBuilder(
    column: $table.weekdayOverridesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get goalsJson =>
      $composableBuilder(column: $table.goalsJson, builder: (column) => column);

  GeneratedColumn<bool> get followUpEnabled => $composableBuilder(
    column: $table.followUpEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get popupEnabled => $composableBuilder(
    column: $table.popupEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ttlMinutes => $composableBuilder(
    column: $table.ttlMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboarded =>
      $composableBuilder(column: $table.onboarded, builder: (column) => column);

  GeneratedColumn<String> get selectedBuddy => $composableBuilder(
    column: $table.selectedBuddy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeId =>
      $composableBuilder(column: $table.themeId, builder: (column) => column);

  GeneratedColumn<int> get customPrimaryColor => $composableBuilder(
    column: $table.customPrimaryColor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customAccentColor => $composableBuilder(
    column: $table.customAccentColor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customBackgroundColor => $composableBuilder(
    column: $table.customBackgroundColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bgBase =>
      $composableBuilder(column: $table.bgBase, builder: (column) => column);

  GeneratedColumn<int> get bgTintColor => $composableBuilder(
    column: $table.bgTintColor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bgTintStrength => $composableBuilder(
    column: $table.bgTintStrength,
    builder: (column) => column,
  );

  GeneratedColumn<String> get darkMode =>
      $composableBuilder(column: $table.darkMode, builder: (column) => column);

  GeneratedColumn<String> get presenceMode => $composableBuilder(
    column: $table.presenceMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get widgetColorMode => $composableBuilder(
    column: $table.widgetColorMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get widgetShowCount => $composableBuilder(
    column: $table.widgetShowCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get buddyOrderJson => $composableBuilder(
    column: $table.buddyOrderJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get customSoundsEnabled => $composableBuilder(
    column: $table.customSoundsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfileTableTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UserProfileTableTable,
          UserProfileTableData,
          $$UserProfileTableTableFilterComposer,
          $$UserProfileTableTableOrderingComposer,
          $$UserProfileTableTableAnnotationComposer,
          $$UserProfileTableTableCreateCompanionBuilder,
          $$UserProfileTableTableUpdateCompanionBuilder,
          (
            UserProfileTableData,
            BaseReferences<
              _$AppDb,
              $UserProfileTableTable,
              UserProfileTableData
            >,
          ),
          UserProfileTableData,
          PrefetchHooks Function()
        > {
  $$UserProfileTableTableTableManager(_$AppDb db, $UserProfileTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tonePreference = const Value.absent(),
                Value<int> dailyNotifBudget = const Value.absent(),
                Value<String> wakingWindowJson = const Value.absent(),
                Value<String> slotPreferencesJson = const Value.absent(),
                Value<String> weekdayOverridesJson = const Value.absent(),
                Value<String> goalsJson = const Value.absent(),
                Value<bool> followUpEnabled = const Value.absent(),
                Value<bool> popupEnabled = const Value.absent(),
                Value<bool> vibrationEnabled = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<int> ttlMinutes = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
                Value<String?> selectedBuddy = const Value.absent(),
                Value<String> themeId = const Value.absent(),
                Value<int?> customPrimaryColor = const Value.absent(),
                Value<int?> customAccentColor = const Value.absent(),
                Value<int?> customBackgroundColor = const Value.absent(),
                Value<String> bgBase = const Value.absent(),
                Value<int> bgTintColor = const Value.absent(),
                Value<int> bgTintStrength = const Value.absent(),
                Value<String> darkMode = const Value.absent(),
                Value<String> presenceMode = const Value.absent(),
                Value<String> widgetColorMode = const Value.absent(),
                Value<bool> widgetShowCount = const Value.absent(),
                Value<String> buddyOrderJson = const Value.absent(),
                Value<bool> customSoundsEnabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfileTableCompanion(
                id: id,
                tonePreference: tonePreference,
                dailyNotifBudget: dailyNotifBudget,
                wakingWindowJson: wakingWindowJson,
                slotPreferencesJson: slotPreferencesJson,
                weekdayOverridesJson: weekdayOverridesJson,
                goalsJson: goalsJson,
                followUpEnabled: followUpEnabled,
                popupEnabled: popupEnabled,
                vibrationEnabled: vibrationEnabled,
                soundEnabled: soundEnabled,
                ttlMinutes: ttlMinutes,
                onboarded: onboarded,
                selectedBuddy: selectedBuddy,
                themeId: themeId,
                customPrimaryColor: customPrimaryColor,
                customAccentColor: customAccentColor,
                customBackgroundColor: customBackgroundColor,
                bgBase: bgBase,
                bgTintColor: bgTintColor,
                bgTintStrength: bgTintStrength,
                darkMode: darkMode,
                presenceMode: presenceMode,
                widgetColorMode: widgetColorMode,
                widgetShowCount: widgetShowCount,
                buddyOrderJson: buddyOrderJson,
                customSoundsEnabled: customSoundsEnabled,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tonePreference = const Value.absent(),
                Value<int> dailyNotifBudget = const Value.absent(),
                Value<String> wakingWindowJson = const Value.absent(),
                Value<String> slotPreferencesJson = const Value.absent(),
                Value<String> weekdayOverridesJson = const Value.absent(),
                Value<String> goalsJson = const Value.absent(),
                Value<bool> followUpEnabled = const Value.absent(),
                Value<bool> popupEnabled = const Value.absent(),
                Value<bool> vibrationEnabled = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<int> ttlMinutes = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
                Value<String?> selectedBuddy = const Value.absent(),
                Value<String> themeId = const Value.absent(),
                Value<int?> customPrimaryColor = const Value.absent(),
                Value<int?> customAccentColor = const Value.absent(),
                Value<int?> customBackgroundColor = const Value.absent(),
                Value<String> bgBase = const Value.absent(),
                Value<int> bgTintColor = const Value.absent(),
                Value<int> bgTintStrength = const Value.absent(),
                Value<String> darkMode = const Value.absent(),
                Value<String> presenceMode = const Value.absent(),
                Value<String> widgetColorMode = const Value.absent(),
                Value<bool> widgetShowCount = const Value.absent(),
                Value<String> buddyOrderJson = const Value.absent(),
                Value<bool> customSoundsEnabled = const Value.absent(),
                required DateTime updatedAt,
              }) => UserProfileTableCompanion.insert(
                id: id,
                tonePreference: tonePreference,
                dailyNotifBudget: dailyNotifBudget,
                wakingWindowJson: wakingWindowJson,
                slotPreferencesJson: slotPreferencesJson,
                weekdayOverridesJson: weekdayOverridesJson,
                goalsJson: goalsJson,
                followUpEnabled: followUpEnabled,
                popupEnabled: popupEnabled,
                vibrationEnabled: vibrationEnabled,
                soundEnabled: soundEnabled,
                ttlMinutes: ttlMinutes,
                onboarded: onboarded,
                selectedBuddy: selectedBuddy,
                themeId: themeId,
                customPrimaryColor: customPrimaryColor,
                customAccentColor: customAccentColor,
                customBackgroundColor: customBackgroundColor,
                bgBase: bgBase,
                bgTintColor: bgTintColor,
                bgTintStrength: bgTintStrength,
                darkMode: darkMode,
                presenceMode: presenceMode,
                widgetColorMode: widgetColorMode,
                widgetShowCount: widgetShowCount,
                buddyOrderJson: buddyOrderJson,
                customSoundsEnabled: customSoundsEnabled,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfileTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UserProfileTableTable,
      UserProfileTableData,
      $$UserProfileTableTableFilterComposer,
      $$UserProfileTableTableOrderingComposer,
      $$UserProfileTableTableAnnotationComposer,
      $$UserProfileTableTableCreateCompanionBuilder,
      $$UserProfileTableTableUpdateCompanionBuilder,
      (
        UserProfileTableData,
        BaseReferences<_$AppDb, $UserProfileTableTable, UserProfileTableData>,
      ),
      UserProfileTableData,
      PrefetchHooks Function()
    >;
typedef $$ProfileSignalsTableCreateCompanionBuilder =
    ProfileSignalsCompanion Function({
      Value<int> id,
      required DateTime ts,
      required String kind,
      required String payloadJson,
    });
typedef $$ProfileSignalsTableUpdateCompanionBuilder =
    ProfileSignalsCompanion Function({
      Value<int> id,
      Value<DateTime> ts,
      Value<String> kind,
      Value<String> payloadJson,
    });

class $$ProfileSignalsTableFilterComposer
    extends Composer<_$AppDb, $ProfileSignalsTable> {
  $$ProfileSignalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfileSignalsTableOrderingComposer
    extends Composer<_$AppDb, $ProfileSignalsTable> {
  $$ProfileSignalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileSignalsTableAnnotationComposer
    extends Composer<_$AppDb, $ProfileSignalsTable> {
  $$ProfileSignalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );
}

class $$ProfileSignalsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ProfileSignalsTable,
          ProfileSignal,
          $$ProfileSignalsTableFilterComposer,
          $$ProfileSignalsTableOrderingComposer,
          $$ProfileSignalsTableAnnotationComposer,
          $$ProfileSignalsTableCreateCompanionBuilder,
          $$ProfileSignalsTableUpdateCompanionBuilder,
          (
            ProfileSignal,
            BaseReferences<_$AppDb, $ProfileSignalsTable, ProfileSignal>,
          ),
          ProfileSignal,
          PrefetchHooks Function()
        > {
  $$ProfileSignalsTableTableManager(_$AppDb db, $ProfileSignalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileSignalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileSignalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileSignalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> ts = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
              }) => ProfileSignalsCompanion(
                id: id,
                ts: ts,
                kind: kind,
                payloadJson: payloadJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime ts,
                required String kind,
                required String payloadJson,
              }) => ProfileSignalsCompanion.insert(
                id: id,
                ts: ts,
                kind: kind,
                payloadJson: payloadJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileSignalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ProfileSignalsTable,
      ProfileSignal,
      $$ProfileSignalsTableFilterComposer,
      $$ProfileSignalsTableOrderingComposer,
      $$ProfileSignalsTableAnnotationComposer,
      $$ProfileSignalsTableCreateCompanionBuilder,
      $$ProfileSignalsTableUpdateCompanionBuilder,
      (
        ProfileSignal,
        BaseReferences<_$AppDb, $ProfileSignalsTable, ProfileSignal>,
      ),
      ProfileSignal,
      PrefetchHooks Function()
    >;
typedef $$AdaptiveStateTableCreateCompanionBuilder =
    AdaptiveStateCompanion Function({
      required String habitId,
      required DateTime lastEvaluatedAt,
      Value<String> responseWindowJson,
      Value<String> currentOffsetsJson,
      Value<int> streakCount,
      Value<DateTime?> lastMissAt,
      Value<String?> currentToneKey,
      Value<int> rowid,
    });
typedef $$AdaptiveStateTableUpdateCompanionBuilder =
    AdaptiveStateCompanion Function({
      Value<String> habitId,
      Value<DateTime> lastEvaluatedAt,
      Value<String> responseWindowJson,
      Value<String> currentOffsetsJson,
      Value<int> streakCount,
      Value<DateTime?> lastMissAt,
      Value<String?> currentToneKey,
      Value<int> rowid,
    });

final class $$AdaptiveStateTableReferences
    extends BaseReferences<_$AppDb, $AdaptiveStateTable, AdaptiveStateData> {
  $$AdaptiveStateTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitsTable _habitIdTable(_$AppDb db) => db.habits.createAlias(
    $_aliasNameGenerator(db.adaptiveState.habitId, db.habits.id),
  );

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<String>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AdaptiveStateTableFilterComposer
    extends Composer<_$AppDb, $AdaptiveStateTable> {
  $$AdaptiveStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get lastEvaluatedAt => $composableBuilder(
    column: $table.lastEvaluatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseWindowJson => $composableBuilder(
    column: $table.responseWindowJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentOffsetsJson => $composableBuilder(
    column: $table.currentOffsetsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakCount => $composableBuilder(
    column: $table.streakCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMissAt => $composableBuilder(
    column: $table.lastMissAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentToneKey => $composableBuilder(
    column: $table.currentToneKey,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdaptiveStateTableOrderingComposer
    extends Composer<_$AppDb, $AdaptiveStateTable> {
  $$AdaptiveStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get lastEvaluatedAt => $composableBuilder(
    column: $table.lastEvaluatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseWindowJson => $composableBuilder(
    column: $table.responseWindowJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentOffsetsJson => $composableBuilder(
    column: $table.currentOffsetsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakCount => $composableBuilder(
    column: $table.streakCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMissAt => $composableBuilder(
    column: $table.lastMissAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentToneKey => $composableBuilder(
    column: $table.currentToneKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdaptiveStateTableAnnotationComposer
    extends Composer<_$AppDb, $AdaptiveStateTable> {
  $$AdaptiveStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get lastEvaluatedAt => $composableBuilder(
    column: $table.lastEvaluatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseWindowJson => $composableBuilder(
    column: $table.responseWindowJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentOffsetsJson => $composableBuilder(
    column: $table.currentOffsetsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streakCount => $composableBuilder(
    column: $table.streakCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMissAt => $composableBuilder(
    column: $table.lastMissAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentToneKey => $composableBuilder(
    column: $table.currentToneKey,
    builder: (column) => column,
  );

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdaptiveStateTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $AdaptiveStateTable,
          AdaptiveStateData,
          $$AdaptiveStateTableFilterComposer,
          $$AdaptiveStateTableOrderingComposer,
          $$AdaptiveStateTableAnnotationComposer,
          $$AdaptiveStateTableCreateCompanionBuilder,
          $$AdaptiveStateTableUpdateCompanionBuilder,
          (AdaptiveStateData, $$AdaptiveStateTableReferences),
          AdaptiveStateData,
          PrefetchHooks Function({bool habitId})
        > {
  $$AdaptiveStateTableTableManager(_$AppDb db, $AdaptiveStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdaptiveStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdaptiveStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdaptiveStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> habitId = const Value.absent(),
                Value<DateTime> lastEvaluatedAt = const Value.absent(),
                Value<String> responseWindowJson = const Value.absent(),
                Value<String> currentOffsetsJson = const Value.absent(),
                Value<int> streakCount = const Value.absent(),
                Value<DateTime?> lastMissAt = const Value.absent(),
                Value<String?> currentToneKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdaptiveStateCompanion(
                habitId: habitId,
                lastEvaluatedAt: lastEvaluatedAt,
                responseWindowJson: responseWindowJson,
                currentOffsetsJson: currentOffsetsJson,
                streakCount: streakCount,
                lastMissAt: lastMissAt,
                currentToneKey: currentToneKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String habitId,
                required DateTime lastEvaluatedAt,
                Value<String> responseWindowJson = const Value.absent(),
                Value<String> currentOffsetsJson = const Value.absent(),
                Value<int> streakCount = const Value.absent(),
                Value<DateTime?> lastMissAt = const Value.absent(),
                Value<String?> currentToneKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdaptiveStateCompanion.insert(
                habitId: habitId,
                lastEvaluatedAt: lastEvaluatedAt,
                responseWindowJson: responseWindowJson,
                currentOffsetsJson: currentOffsetsJson,
                streakCount: streakCount,
                lastMissAt: lastMissAt,
                currentToneKey: currentToneKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AdaptiveStateTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$AdaptiveStateTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$AdaptiveStateTableReferences
                                    ._habitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AdaptiveStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $AdaptiveStateTable,
      AdaptiveStateData,
      $$AdaptiveStateTableFilterComposer,
      $$AdaptiveStateTableOrderingComposer,
      $$AdaptiveStateTableAnnotationComposer,
      $$AdaptiveStateTableCreateCompanionBuilder,
      $$AdaptiveStateTableUpdateCompanionBuilder,
      (AdaptiveStateData, $$AdaptiveStateTableReferences),
      AdaptiveStateData,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$UserCategoriesTableCreateCompanionBuilder =
    UserCategoriesCompanion Function({
      required String id,
      required String label,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$UserCategoriesTableUpdateCompanionBuilder =
    UserCategoriesCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UserCategoriesTableFilterComposer
    extends Composer<_$AppDb, $UserCategoriesTable> {
  $$UserCategoriesTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserCategoriesTableOrderingComposer
    extends Composer<_$AppDb, $UserCategoriesTable> {
  $$UserCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserCategoriesTableAnnotationComposer
    extends Composer<_$AppDb, $UserCategoriesTable> {
  $$UserCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UserCategoriesTable,
          UserCategory,
          $$UserCategoriesTableFilterComposer,
          $$UserCategoriesTableOrderingComposer,
          $$UserCategoriesTableAnnotationComposer,
          $$UserCategoriesTableCreateCompanionBuilder,
          $$UserCategoriesTableUpdateCompanionBuilder,
          (
            UserCategory,
            BaseReferences<_$AppDb, $UserCategoriesTable, UserCategory>,
          ),
          UserCategory,
          PrefetchHooks Function()
        > {
  $$UserCategoriesTableTableManager(_$AppDb db, $UserCategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserCategoriesCompanion(
                id: id,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UserCategoriesCompanion.insert(
                id: id,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UserCategoriesTable,
      UserCategory,
      $$UserCategoriesTableFilterComposer,
      $$UserCategoriesTableOrderingComposer,
      $$UserCategoriesTableAnnotationComposer,
      $$UserCategoriesTableCreateCompanionBuilder,
      $$UserCategoriesTableUpdateCompanionBuilder,
      (
        UserCategory,
        BaseReferences<_$AppDb, $UserCategoriesTable, UserCategory>,
      ),
      UserCategory,
      PrefetchHooks Function()
    >;
typedef $$BuddyProgressTableCreateCompanionBuilder =
    BuddyProgressCompanion Function({
      required String buddyId,
      Value<int> totalScore,
      Value<int?> lastScoredDayEpoch,
      Value<int> maxStageReached,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BuddyProgressTableUpdateCompanionBuilder =
    BuddyProgressCompanion Function({
      Value<String> buddyId,
      Value<int> totalScore,
      Value<int?> lastScoredDayEpoch,
      Value<int> maxStageReached,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BuddyProgressTableFilterComposer
    extends Composer<_$AppDb, $BuddyProgressTable> {
  $$BuddyProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get buddyId => $composableBuilder(
    column: $table.buddyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastScoredDayEpoch => $composableBuilder(
    column: $table.lastScoredDayEpoch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxStageReached => $composableBuilder(
    column: $table.maxStageReached,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BuddyProgressTableOrderingComposer
    extends Composer<_$AppDb, $BuddyProgressTable> {
  $$BuddyProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get buddyId => $composableBuilder(
    column: $table.buddyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastScoredDayEpoch => $composableBuilder(
    column: $table.lastScoredDayEpoch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxStageReached => $composableBuilder(
    column: $table.maxStageReached,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BuddyProgressTableAnnotationComposer
    extends Composer<_$AppDb, $BuddyProgressTable> {
  $$BuddyProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get buddyId =>
      $composableBuilder(column: $table.buddyId, builder: (column) => column);

  GeneratedColumn<int> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastScoredDayEpoch => $composableBuilder(
    column: $table.lastScoredDayEpoch,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxStageReached => $composableBuilder(
    column: $table.maxStageReached,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BuddyProgressTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $BuddyProgressTable,
          BuddyProgressData,
          $$BuddyProgressTableFilterComposer,
          $$BuddyProgressTableOrderingComposer,
          $$BuddyProgressTableAnnotationComposer,
          $$BuddyProgressTableCreateCompanionBuilder,
          $$BuddyProgressTableUpdateCompanionBuilder,
          (
            BuddyProgressData,
            BaseReferences<_$AppDb, $BuddyProgressTable, BuddyProgressData>,
          ),
          BuddyProgressData,
          PrefetchHooks Function()
        > {
  $$BuddyProgressTableTableManager(_$AppDb db, $BuddyProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuddyProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuddyProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuddyProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> buddyId = const Value.absent(),
                Value<int> totalScore = const Value.absent(),
                Value<int?> lastScoredDayEpoch = const Value.absent(),
                Value<int> maxStageReached = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuddyProgressCompanion(
                buddyId: buddyId,
                totalScore: totalScore,
                lastScoredDayEpoch: lastScoredDayEpoch,
                maxStageReached: maxStageReached,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String buddyId,
                Value<int> totalScore = const Value.absent(),
                Value<int?> lastScoredDayEpoch = const Value.absent(),
                Value<int> maxStageReached = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BuddyProgressCompanion.insert(
                buddyId: buddyId,
                totalScore: totalScore,
                lastScoredDayEpoch: lastScoredDayEpoch,
                maxStageReached: maxStageReached,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BuddyProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $BuddyProgressTable,
      BuddyProgressData,
      $$BuddyProgressTableFilterComposer,
      $$BuddyProgressTableOrderingComposer,
      $$BuddyProgressTableAnnotationComposer,
      $$BuddyProgressTableCreateCompanionBuilder,
      $$BuddyProgressTableUpdateCompanionBuilder,
      (
        BuddyProgressData,
        BaseReferences<_$AppDb, $BuddyProgressTable, BuddyProgressData>,
      ),
      BuddyProgressData,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$ScheduleSlotsTableTableManager get scheduleSlots =>
      $$ScheduleSlotsTableTableManager(_db, _db.scheduleSlots);
  $$NotificationLogTableTableManager get notificationLog =>
      $$NotificationLogTableTableManager(_db, _db.notificationLog);
  $$UserProfileTableTableTableManager get userProfileTable =>
      $$UserProfileTableTableTableManager(_db, _db.userProfileTable);
  $$ProfileSignalsTableTableManager get profileSignals =>
      $$ProfileSignalsTableTableManager(_db, _db.profileSignals);
  $$AdaptiveStateTableTableManager get adaptiveState =>
      $$AdaptiveStateTableTableManager(_db, _db.adaptiveState);
  $$UserCategoriesTableTableManager get userCategories =>
      $$UserCategoriesTableTableManager(_db, _db.userCategories);
  $$BuddyProgressTableTableManager get buddyProgress =>
      $$BuddyProgressTableTableManager(_db, _db.buddyProgress);
}
