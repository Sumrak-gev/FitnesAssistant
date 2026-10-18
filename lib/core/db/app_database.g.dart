// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalProfilesTable extends LocalProfiles
    with TableInfo<$LocalProfilesTable, LocalProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 80),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activityMeta = const VerificationMeta(
    'activity',
  );
  @override
  late final GeneratedColumn<String> activity = GeneratedColumn<String>(
    'activity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<String> programId = GeneratedColumn<String>(
    'program_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    name,
    birthDate,
    sex,
    heightCm,
    weightKg,
    targetWeightKg,
    activity,
    goal,
    programId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('activity')) {
      context.handle(
        _activityMeta,
        activity.isAcceptableOrUnknown(data['activity']!, _activityMeta),
      );
    } else if (isInserting) {
      context.missing(_activityMeta);
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
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
  LocalProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      ),
      activity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalProfilesTable createAlias(String alias) {
    return $LocalProfilesTable(attachedDatabase, alias);
  }
}

class LocalProfile extends DataClass implements Insertable<LocalProfile> {
  final int id;
  final String name;
  final DateTime? birthDate;
  final String sex;
  final double? heightCm;
  final double? weightKg;
  final double? targetWeightKg;
  final String activity;
  final String goal;
  final String? programId;
  final DateTime updatedAt;
  const LocalProfile({
    required this.id,
    required this.name,
    this.birthDate,
    required this.sex,
    this.heightCm,
    this.weightKg,
    this.targetWeightKg,
    required this.activity,
    required this.goal,
    this.programId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    map['sex'] = Variable<String>(sex);
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || targetWeightKg != null) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg);
    }
    map['activity'] = Variable<String>(activity);
    map['goal'] = Variable<String>(goal);
    if (!nullToAbsent || programId != null) {
      map['program_id'] = Variable<String>(programId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalProfilesCompanion(
      id: Value(id),
      name: Value(name),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      sex: Value(sex),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      targetWeightKg: targetWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeightKg),
      activity: Value(activity),
      goal: Value(goal),
      programId: programId == null && nullToAbsent
          ? const Value.absent()
          : Value(programId),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      sex: serializer.fromJson<String>(json['sex']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      targetWeightKg: serializer.fromJson<double?>(json['targetWeightKg']),
      activity: serializer.fromJson<String>(json['activity']),
      goal: serializer.fromJson<String>(json['goal']),
      programId: serializer.fromJson<String?>(json['programId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'sex': serializer.toJson<String>(sex),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'targetWeightKg': serializer.toJson<double?>(targetWeightKg),
      'activity': serializer.toJson<String>(activity),
      'goal': serializer.toJson<String>(goal),
      'programId': serializer.toJson<String?>(programId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalProfile copyWith({
    int? id,
    String? name,
    Value<DateTime?> birthDate = const Value.absent(),
    String? sex,
    Value<double?> heightCm = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<double?> targetWeightKg = const Value.absent(),
    String? activity,
    String? goal,
    Value<String?> programId = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    sex: sex ?? this.sex,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    targetWeightKg: targetWeightKg.present
        ? targetWeightKg.value
        : this.targetWeightKg,
    activity: activity ?? this.activity,
    goal: goal ?? this.goal,
    programId: programId.present ? programId.value : this.programId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalProfile copyWithCompanion(LocalProfilesCompanion data) {
    return LocalProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      sex: data.sex.present ? data.sex.value : this.sex,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      activity: data.activity.present ? data.activity.value : this.activity,
      goal: data.goal.present ? data.goal.value : this.goal,
      programId: data.programId.present ? data.programId.value : this.programId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('sex: $sex, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('activity: $activity, ')
          ..write('goal: $goal, ')
          ..write('programId: $programId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    birthDate,
    sex,
    heightCm,
    weightKg,
    targetWeightKg,
    activity,
    goal,
    programId,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthDate == this.birthDate &&
          other.sex == this.sex &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.targetWeightKg == this.targetWeightKg &&
          other.activity == this.activity &&
          other.goal == this.goal &&
          other.programId == this.programId &&
          other.updatedAt == this.updatedAt);
}

class LocalProfilesCompanion extends UpdateCompanion<LocalProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime?> birthDate;
  final Value<String> sex;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<double?> targetWeightKg;
  final Value<String> activity;
  final Value<String> goal;
  final Value<String?> programId;
  final Value<DateTime> updatedAt;
  const LocalProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.sex = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.activity = const Value.absent(),
    this.goal = const Value.absent(),
    this.programId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.birthDate = const Value.absent(),
    required String sex,
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    required String activity,
    required String goal,
    this.programId = const Value.absent(),
    required DateTime updatedAt,
  }) : name = Value(name),
       sex = Value(sex),
       activity = Value(activity),
       goal = Value(goal),
       updatedAt = Value(updatedAt);
  static Insertable<LocalProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? birthDate,
    Expression<String>? sex,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<double>? targetWeightKg,
    Expression<String>? activity,
    Expression<String>? goal,
    Expression<String>? programId,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthDate != null) 'birth_date': birthDate,
      if (sex != null) 'sex': sex,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (activity != null) 'activity': activity,
      if (goal != null) 'goal': goal,
      if (programId != null) 'program_id': programId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime?>? birthDate,
    Value<String>? sex,
    Value<double?>? heightCm,
    Value<double?>? weightKg,
    Value<double?>? targetWeightKg,
    Value<String>? activity,
    Value<String>? goal,
    Value<String?>? programId,
    Value<DateTime>? updatedAt,
  }) {
    return LocalProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      activity: activity ?? this.activity,
      goal: goal ?? this.goal,
      programId: programId ?? this.programId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (activity.present) {
      map['activity'] = Variable<String>(activity.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<String>(programId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('sex: $sex, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('activity: $activity, ')
          ..write('goal: $goal, ')
          ..write('programId: $programId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalRemindersTable extends LocalReminders
    with TableInfo<$LocalRemindersTable, LocalReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    check: () => ComparableExpr(hour).isBetweenValues(0, 23),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    check: () => ComparableExpr(minute).isBetweenValues(0, 59),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    check: () => ComparableExpr(weekday).isBetweenValues(1, 7),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthDayMeta = const VerificationMeta(
    'monthDay',
  );
  @override
  late final GeneratedColumn<int> monthDay = GeneratedColumn<int>(
    'month_day',
    aliasedName,
    false,
    check: () => ComparableExpr(monthDay).isBetweenValues(1, 28),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    frequency,
    hour,
    minute,
    weekday,
    monthDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    } else if (isInserting) {
      context.missing(_minuteMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('month_day')) {
      context.handle(
        _monthDayMeta,
        monthDay.isAcceptableOrUnknown(data['month_day']!, _monthDayMeta),
      );
    } else if (isInserting) {
      context.missing(_monthDayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalReminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      monthDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_day'],
      )!,
    );
  }

  @override
  $LocalRemindersTable createAlias(String alias) {
    return $LocalRemindersTable(attachedDatabase, alias);
  }
}

class LocalReminder extends DataClass implements Insertable<LocalReminder> {
  final int id;
  final String frequency;
  final int hour;
  final int minute;
  final int weekday;
  final int monthDay;
  const LocalReminder({
    required this.id,
    required this.frequency,
    required this.hour,
    required this.minute,
    required this.weekday,
    required this.monthDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['frequency'] = Variable<String>(frequency);
    map['hour'] = Variable<int>(hour);
    map['minute'] = Variable<int>(minute);
    map['weekday'] = Variable<int>(weekday);
    map['month_day'] = Variable<int>(monthDay);
    return map;
  }

  LocalRemindersCompanion toCompanion(bool nullToAbsent) {
    return LocalRemindersCompanion(
      id: Value(id),
      frequency: Value(frequency),
      hour: Value(hour),
      minute: Value(minute),
      weekday: Value(weekday),
      monthDay: Value(monthDay),
    );
  }

  factory LocalReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalReminder(
      id: serializer.fromJson<int>(json['id']),
      frequency: serializer.fromJson<String>(json['frequency']),
      hour: serializer.fromJson<int>(json['hour']),
      minute: serializer.fromJson<int>(json['minute']),
      weekday: serializer.fromJson<int>(json['weekday']),
      monthDay: serializer.fromJson<int>(json['monthDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'frequency': serializer.toJson<String>(frequency),
      'hour': serializer.toJson<int>(hour),
      'minute': serializer.toJson<int>(minute),
      'weekday': serializer.toJson<int>(weekday),
      'monthDay': serializer.toJson<int>(monthDay),
    };
  }

  LocalReminder copyWith({
    int? id,
    String? frequency,
    int? hour,
    int? minute,
    int? weekday,
    int? monthDay,
  }) => LocalReminder(
    id: id ?? this.id,
    frequency: frequency ?? this.frequency,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    weekday: weekday ?? this.weekday,
    monthDay: monthDay ?? this.monthDay,
  );
  LocalReminder copyWithCompanion(LocalRemindersCompanion data) {
    return LocalReminder(
      id: data.id.present ? data.id.value : this.id,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      hour: data.hour.present ? data.hour.value : this.hour,
      minute: data.minute.present ? data.minute.value : this.minute,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      monthDay: data.monthDay.present ? data.monthDay.value : this.monthDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalReminder(')
          ..write('id: $id, ')
          ..write('frequency: $frequency, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('weekday: $weekday, ')
          ..write('monthDay: $monthDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, frequency, hour, minute, weekday, monthDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalReminder &&
          other.id == this.id &&
          other.frequency == this.frequency &&
          other.hour == this.hour &&
          other.minute == this.minute &&
          other.weekday == this.weekday &&
          other.monthDay == this.monthDay);
}

class LocalRemindersCompanion extends UpdateCompanion<LocalReminder> {
  final Value<int> id;
  final Value<String> frequency;
  final Value<int> hour;
  final Value<int> minute;
  final Value<int> weekday;
  final Value<int> monthDay;
  const LocalRemindersCompanion({
    this.id = const Value.absent(),
    this.frequency = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.weekday = const Value.absent(),
    this.monthDay = const Value.absent(),
  });
  LocalRemindersCompanion.insert({
    this.id = const Value.absent(),
    required String frequency,
    required int hour,
    required int minute,
    required int weekday,
    required int monthDay,
  }) : frequency = Value(frequency),
       hour = Value(hour),
       minute = Value(minute),
       weekday = Value(weekday),
       monthDay = Value(monthDay);
  static Insertable<LocalReminder> custom({
    Expression<int>? id,
    Expression<String>? frequency,
    Expression<int>? hour,
    Expression<int>? minute,
    Expression<int>? weekday,
    Expression<int>? monthDay,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (frequency != null) 'frequency': frequency,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (weekday != null) 'weekday': weekday,
      if (monthDay != null) 'month_day': monthDay,
    });
  }

  LocalRemindersCompanion copyWith({
    Value<int>? id,
    Value<String>? frequency,
    Value<int>? hour,
    Value<int>? minute,
    Value<int>? weekday,
    Value<int>? monthDay,
  }) {
    return LocalRemindersCompanion(
      id: id ?? this.id,
      frequency: frequency ?? this.frequency,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekday: weekday ?? this.weekday,
      monthDay: monthDay ?? this.monthDay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (monthDay.present) {
      map['month_day'] = Variable<int>(monthDay.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRemindersCompanion(')
          ..write('id: $id, ')
          ..write('frequency: $frequency, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('weekday: $weekday, ')
          ..write('monthDay: $monthDay')
          ..write(')'))
        .toString();
  }
}

class $NutritionUsersTable extends NutritionUsers
    with TableInfo<$NutritionUsersTable, NutritionUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localSlotMeta = const VerificationMeta(
    'localSlot',
  );
  @override
  late final GeneratedColumn<int> localSlot = GeneratedColumn<int>(
    'local_slot',
    aliasedName,
    true,
    check: () => localSlot.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, localSlot, profileId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<NutritionUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_slot')) {
      context.handle(
        _localSlotMeta,
        localSlot.isAcceptableOrUnknown(data['local_slot']!, _localSlotMeta),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NutritionUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutritionUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_slot'],
      ),
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      ),
    );
  }

  @override
  $NutritionUsersTable createAlias(String alias) {
    return $NutritionUsersTable(attachedDatabase, alias);
  }
}

class NutritionUser extends DataClass implements Insertable<NutritionUser> {
  final String id;
  final int? localSlot;
  final int? profileId;
  const NutritionUser({required this.id, this.localSlot, this.profileId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || localSlot != null) {
      map['local_slot'] = Variable<int>(localSlot);
    }
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    return map;
  }

  NutritionUsersCompanion toCompanion(bool nullToAbsent) {
    return NutritionUsersCompanion(
      id: Value(id),
      localSlot: localSlot == null && nullToAbsent
          ? const Value.absent()
          : Value(localSlot),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
    );
  }

  factory NutritionUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutritionUser(
      id: serializer.fromJson<String>(json['id']),
      localSlot: serializer.fromJson<int?>(json['localSlot']),
      profileId: serializer.fromJson<int?>(json['profileId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localSlot': serializer.toJson<int?>(localSlot),
      'profileId': serializer.toJson<int?>(profileId),
    };
  }

  NutritionUser copyWith({
    String? id,
    Value<int?> localSlot = const Value.absent(),
    Value<int?> profileId = const Value.absent(),
  }) => NutritionUser(
    id: id ?? this.id,
    localSlot: localSlot.present ? localSlot.value : this.localSlot,
    profileId: profileId.present ? profileId.value : this.profileId,
  );
  NutritionUser copyWithCompanion(NutritionUsersCompanion data) {
    return NutritionUser(
      id: data.id.present ? data.id.value : this.id,
      localSlot: data.localSlot.present ? data.localSlot.value : this.localSlot,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutritionUser(')
          ..write('id: $id, ')
          ..write('localSlot: $localSlot, ')
          ..write('profileId: $profileId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, localSlot, profileId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutritionUser &&
          other.id == this.id &&
          other.localSlot == this.localSlot &&
          other.profileId == this.profileId);
}

class NutritionUsersCompanion extends UpdateCompanion<NutritionUser> {
  final Value<String> id;
  final Value<int?> localSlot;
  final Value<int?> profileId;
  final Value<int> rowid;
  const NutritionUsersCompanion({
    this.id = const Value.absent(),
    this.localSlot = const Value.absent(),
    this.profileId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionUsersCompanion.insert({
    required String id,
    this.localSlot = const Value.absent(),
    this.profileId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<NutritionUser> custom({
    Expression<String>? id,
    Expression<int>? localSlot,
    Expression<int>? profileId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localSlot != null) 'local_slot': localSlot,
      if (profileId != null) 'profile_id': profileId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionUsersCompanion copyWith({
    Value<String>? id,
    Value<int?>? localSlot,
    Value<int?>? profileId,
    Value<int>? rowid,
  }) {
    return NutritionUsersCompanion(
      id: id ?? this.id,
      localSlot: localSlot ?? this.localSlot,
      profileId: profileId ?? this.profileId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localSlot.present) {
      map['local_slot'] = Variable<int>(localSlot.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionUsersCompanion(')
          ..write('id: $id, ')
          ..write('localSlot: $localSlot, ')
          ..write('profileId: $profileId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NutritionProductsTable extends NutritionProducts
    with TableInfo<$NutritionProductsTable, NutritionProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nutrition_users (id)',
    ),
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
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  @override
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    check: () => ComparableExpr(localRevision).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    false,
    check: () => ComparableExpr(serverVersion).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    check: () => ComparableExpr(calories).isBetweenValues(0, 900),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    check: () => ComparableExpr(protein).isBetweenValues(0, 100.1),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    false,
    check: () => ComparableExpr(fat).isBetweenValues(0, 100.1),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    false,
    check: () => ComparableExpr(carbs).isBetweenValues(0, 100.1),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    updatedAt,
    deletedAt,
    localRevision,
    serverVersion,
    id,
    name,
    calories,
    protein,
    fat,
    carbs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_products';
  @override
  VerificationContext validateIntegrity(
    Insertable<NutritionProduct> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
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
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, userId},
  ];
  @override
  NutritionProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutritionProduct(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      )!,
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      )!,
    );
  }

  @override
  $NutritionProductsTable createAlias(String alias) {
    return $NutritionProductsTable(attachedDatabase, alias);
  }
}

class NutritionProduct extends DataClass
    implements Insertable<NutritionProduct> {
  final String userId;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRevision;
  final int serverVersion;
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  const NutritionProduct({
    required this.userId,
    required this.updatedAt,
    this.deletedAt,
    required this.localRevision,
    required this.serverVersion,
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_revision'] = Variable<int>(localRevision);
    map['server_version'] = Variable<int>(serverVersion);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['calories'] = Variable<double>(calories);
    map['protein'] = Variable<double>(protein);
    map['fat'] = Variable<double>(fat);
    map['carbs'] = Variable<double>(carbs);
    return map;
  }

  NutritionProductsCompanion toCompanion(bool nullToAbsent) {
    return NutritionProductsCompanion(
      userId: Value(userId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRevision: Value(localRevision),
      serverVersion: Value(serverVersion),
      id: Value(id),
      name: Value(name),
      calories: Value(calories),
      protein: Value(protein),
      fat: Value(fat),
      carbs: Value(carbs),
    );
  }

  factory NutritionProduct.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutritionProduct(
      userId: serializer.fromJson<String>(json['userId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRevision: serializer.fromJson<int>(json['localRevision']),
      serverVersion: serializer.fromJson<int>(json['serverVersion']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      calories: serializer.fromJson<double>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      fat: serializer.fromJson<double>(json['fat']),
      carbs: serializer.fromJson<double>(json['carbs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRevision': serializer.toJson<int>(localRevision),
      'serverVersion': serializer.toJson<int>(serverVersion),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'calories': serializer.toJson<double>(calories),
      'protein': serializer.toJson<double>(protein),
      'fat': serializer.toJson<double>(fat),
      'carbs': serializer.toJson<double>(carbs),
    };
  }

  NutritionProduct copyWith({
    String? userId,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? localRevision,
    int? serverVersion,
    String? id,
    String? name,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
  }) => NutritionProduct(
    userId: userId ?? this.userId,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRevision: localRevision ?? this.localRevision,
    serverVersion: serverVersion ?? this.serverVersion,
    id: id ?? this.id,
    name: name ?? this.name,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    fat: fat ?? this.fat,
    carbs: carbs ?? this.carbs,
  );
  NutritionProduct copyWithCompanion(NutritionProductsCompanion data) {
    return NutritionProduct(
      userId: data.userId.present ? data.userId.value : this.userId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      fat: data.fat.present ? data.fat.value : this.fat,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutritionProduct(')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    updatedAt,
    deletedAt,
    localRevision,
    serverVersion,
    id,
    name,
    calories,
    protein,
    fat,
    carbs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutritionProduct &&
          other.userId == this.userId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRevision == this.localRevision &&
          other.serverVersion == this.serverVersion &&
          other.id == this.id &&
          other.name == this.name &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.fat == this.fat &&
          other.carbs == this.carbs);
}

class NutritionProductsCompanion extends UpdateCompanion<NutritionProduct> {
  final Value<String> userId;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRevision;
  final Value<int> serverVersion;
  final Value<String> id;
  final Value<String> name;
  final Value<double> calories;
  final Value<double> protein;
  final Value<double> fat;
  final Value<double> carbs;
  final Value<int> rowid;
  const NutritionProductsCompanion({
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.fat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionProductsCompanion.insert({
    required String userId,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String id,
    required String name,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       calories = Value(calories),
       protein = Value(protein),
       fat = Value(fat),
       carbs = Value(carbs);
  static Insertable<NutritionProduct> custom({
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRevision,
    Expression<int>? serverVersion,
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<double>? fat,
    Expression<double>? carbs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRevision != null) 'local_revision': localRevision,
      if (serverVersion != null) 'server_version': serverVersion,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (fat != null) 'fat': fat,
      if (carbs != null) 'carbs': carbs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionProductsCompanion copyWith({
    Value<String>? userId,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? localRevision,
    Value<int>? serverVersion,
    Value<String>? id,
    Value<String>? name,
    Value<double>? calories,
    Value<double>? protein,
    Value<double>? fat,
    Value<double>? carbs,
    Value<int>? rowid,
  }) {
    return NutritionProductsCompanion(
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRevision: localRevision ?? this.localRevision,
      serverVersion: serverVersion ?? this.serverVersion,
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionProductsCompanion(')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NutritionMealsTable extends NutritionMeals
    with TableInfo<$NutritionMealsTable, NutritionMeal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionMealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nutrition_users (id)',
    ),
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
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  @override
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    check: () => ComparableExpr(localRevision).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    false,
    check: () => ComparableExpr(serverVersion).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    check: () => kind.isIn(['breakfast', 'lunch', 'dinner', 'snack']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    updatedAt,
    deletedAt,
    localRevision,
    serverVersion,
    id,
    day,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_meals';
  @override
  VerificationContext validateIntegrity(
    Insertable<NutritionMeal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
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
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, userId},
    {userId, day, kind},
  ];
  @override
  NutritionMeal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutritionMeal(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $NutritionMealsTable createAlias(String alias) {
    return $NutritionMealsTable(attachedDatabase, alias);
  }
}

class NutritionMeal extends DataClass implements Insertable<NutritionMeal> {
  final String userId;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRevision;
  final int serverVersion;
  final String id;
  final String day;
  final String kind;
  const NutritionMeal({
    required this.userId,
    required this.updatedAt,
    this.deletedAt,
    required this.localRevision,
    required this.serverVersion,
    required this.id,
    required this.day,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_revision'] = Variable<int>(localRevision);
    map['server_version'] = Variable<int>(serverVersion);
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  NutritionMealsCompanion toCompanion(bool nullToAbsent) {
    return NutritionMealsCompanion(
      userId: Value(userId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRevision: Value(localRevision),
      serverVersion: Value(serverVersion),
      id: Value(id),
      day: Value(day),
      kind: Value(kind),
    );
  }

  factory NutritionMeal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutritionMeal(
      userId: serializer.fromJson<String>(json['userId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRevision: serializer.fromJson<int>(json['localRevision']),
      serverVersion: serializer.fromJson<int>(json['serverVersion']),
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRevision': serializer.toJson<int>(localRevision),
      'serverVersion': serializer.toJson<int>(serverVersion),
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'kind': serializer.toJson<String>(kind),
    };
  }

  NutritionMeal copyWith({
    String? userId,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? localRevision,
    int? serverVersion,
    String? id,
    String? day,
    String? kind,
  }) => NutritionMeal(
    userId: userId ?? this.userId,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRevision: localRevision ?? this.localRevision,
    serverVersion: serverVersion ?? this.serverVersion,
    id: id ?? this.id,
    day: day ?? this.day,
    kind: kind ?? this.kind,
  );
  NutritionMeal copyWithCompanion(NutritionMealsCompanion data) {
    return NutritionMeal(
      userId: data.userId.present ? data.userId.value : this.userId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutritionMeal(')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    updatedAt,
    deletedAt,
    localRevision,
    serverVersion,
    id,
    day,
    kind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutritionMeal &&
          other.userId == this.userId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRevision == this.localRevision &&
          other.serverVersion == this.serverVersion &&
          other.id == this.id &&
          other.day == this.day &&
          other.kind == this.kind);
}

class NutritionMealsCompanion extends UpdateCompanion<NutritionMeal> {
  final Value<String> userId;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRevision;
  final Value<int> serverVersion;
  final Value<String> id;
  final Value<String> day;
  final Value<String> kind;
  final Value<int> rowid;
  const NutritionMealsCompanion({
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionMealsCompanion.insert({
    required String userId,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String id,
    required String day,
    required String kind,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       updatedAt = Value(updatedAt),
       id = Value(id),
       day = Value(day),
       kind = Value(kind);
  static Insertable<NutritionMeal> custom({
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRevision,
    Expression<int>? serverVersion,
    Expression<String>? id,
    Expression<String>? day,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRevision != null) 'local_revision': localRevision,
      if (serverVersion != null) 'server_version': serverVersion,
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionMealsCompanion copyWith({
    Value<String>? userId,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? localRevision,
    Value<int>? serverVersion,
    Value<String>? id,
    Value<String>? day,
    Value<String>? kind,
    Value<int>? rowid,
  }) {
    return NutritionMealsCompanion(
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRevision: localRevision ?? this.localRevision,
      serverVersion: serverVersion ?? this.serverVersion,
      id: id ?? this.id,
      day: day ?? this.day,
      kind: kind ?? this.kind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionMealsCompanion(')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NutritionEntriesTable extends NutritionEntries
    with TableInfo<$NutritionEntriesTable, NutritionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nutrition_users (id)',
    ),
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
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  @override
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    check: () => ComparableExpr(localRevision).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    false,
    check: () => ComparableExpr(serverVersion).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<String> mealId = GeneratedColumn<String>(
    'meal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    check: () =>
        ComparableExpr(grams).isBiggerThanValue(0) &
        ComparableExpr(grams).isSmallerOrEqualValue(10000),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    check: () => ComparableExpr(calories).isBetweenValues(0, 900),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    check: () => ComparableExpr(protein).isBetweenValues(0, 100.1),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    false,
    check: () => ComparableExpr(fat).isBetweenValues(0, 100.1),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    false,
    check: () => ComparableExpr(carbs).isBetweenValues(0, 100.1),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    updatedAt,
    deletedAt,
    localRevision,
    serverVersion,
    id,
    mealId,
    productId,
    grams,
    productName,
    calories,
    protein,
    fat,
    carbs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<NutritionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
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
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('meal_id')) {
      context.handle(
        _mealIdMeta,
        mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NutritionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutritionEntry(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mealId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      )!,
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      )!,
    );
  }

  @override
  $NutritionEntriesTable createAlias(String alias) {
    return $NutritionEntriesTable(attachedDatabase, alias);
  }
}

class NutritionEntry extends DataClass implements Insertable<NutritionEntry> {
  final String userId;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRevision;
  final int serverVersion;
  final String id;
  final String mealId;
  final String productId;
  final double grams;
  final String productName;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  const NutritionEntry({
    required this.userId,
    required this.updatedAt,
    this.deletedAt,
    required this.localRevision,
    required this.serverVersion,
    required this.id,
    required this.mealId,
    required this.productId,
    required this.grams,
    required this.productName,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_revision'] = Variable<int>(localRevision);
    map['server_version'] = Variable<int>(serverVersion);
    map['id'] = Variable<String>(id);
    map['meal_id'] = Variable<String>(mealId);
    map['product_id'] = Variable<String>(productId);
    map['grams'] = Variable<double>(grams);
    map['product_name'] = Variable<String>(productName);
    map['calories'] = Variable<double>(calories);
    map['protein'] = Variable<double>(protein);
    map['fat'] = Variable<double>(fat);
    map['carbs'] = Variable<double>(carbs);
    return map;
  }

  NutritionEntriesCompanion toCompanion(bool nullToAbsent) {
    return NutritionEntriesCompanion(
      userId: Value(userId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRevision: Value(localRevision),
      serverVersion: Value(serverVersion),
      id: Value(id),
      mealId: Value(mealId),
      productId: Value(productId),
      grams: Value(grams),
      productName: Value(productName),
      calories: Value(calories),
      protein: Value(protein),
      fat: Value(fat),
      carbs: Value(carbs),
    );
  }

  factory NutritionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutritionEntry(
      userId: serializer.fromJson<String>(json['userId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRevision: serializer.fromJson<int>(json['localRevision']),
      serverVersion: serializer.fromJson<int>(json['serverVersion']),
      id: serializer.fromJson<String>(json['id']),
      mealId: serializer.fromJson<String>(json['mealId']),
      productId: serializer.fromJson<String>(json['productId']),
      grams: serializer.fromJson<double>(json['grams']),
      productName: serializer.fromJson<String>(json['productName']),
      calories: serializer.fromJson<double>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      fat: serializer.fromJson<double>(json['fat']),
      carbs: serializer.fromJson<double>(json['carbs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRevision': serializer.toJson<int>(localRevision),
      'serverVersion': serializer.toJson<int>(serverVersion),
      'id': serializer.toJson<String>(id),
      'mealId': serializer.toJson<String>(mealId),
      'productId': serializer.toJson<String>(productId),
      'grams': serializer.toJson<double>(grams),
      'productName': serializer.toJson<String>(productName),
      'calories': serializer.toJson<double>(calories),
      'protein': serializer.toJson<double>(protein),
      'fat': serializer.toJson<double>(fat),
      'carbs': serializer.toJson<double>(carbs),
    };
  }

  NutritionEntry copyWith({
    String? userId,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? localRevision,
    int? serverVersion,
    String? id,
    String? mealId,
    String? productId,
    double? grams,
    String? productName,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
  }) => NutritionEntry(
    userId: userId ?? this.userId,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRevision: localRevision ?? this.localRevision,
    serverVersion: serverVersion ?? this.serverVersion,
    id: id ?? this.id,
    mealId: mealId ?? this.mealId,
    productId: productId ?? this.productId,
    grams: grams ?? this.grams,
    productName: productName ?? this.productName,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    fat: fat ?? this.fat,
    carbs: carbs ?? this.carbs,
  );
  NutritionEntry copyWithCompanion(NutritionEntriesCompanion data) {
    return NutritionEntry(
      userId: data.userId.present ? data.userId.value : this.userId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      id: data.id.present ? data.id.value : this.id,
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      productId: data.productId.present ? data.productId.value : this.productId,
      grams: data.grams.present ? data.grams.value : this.grams,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      fat: data.fat.present ? data.fat.value : this.fat,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutritionEntry(')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('productId: $productId, ')
          ..write('grams: $grams, ')
          ..write('productName: $productName, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    updatedAt,
    deletedAt,
    localRevision,
    serverVersion,
    id,
    mealId,
    productId,
    grams,
    productName,
    calories,
    protein,
    fat,
    carbs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutritionEntry &&
          other.userId == this.userId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRevision == this.localRevision &&
          other.serverVersion == this.serverVersion &&
          other.id == this.id &&
          other.mealId == this.mealId &&
          other.productId == this.productId &&
          other.grams == this.grams &&
          other.productName == this.productName &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.fat == this.fat &&
          other.carbs == this.carbs);
}

class NutritionEntriesCompanion extends UpdateCompanion<NutritionEntry> {
  final Value<String> userId;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRevision;
  final Value<int> serverVersion;
  final Value<String> id;
  final Value<String> mealId;
  final Value<String> productId;
  final Value<double> grams;
  final Value<String> productName;
  final Value<double> calories;
  final Value<double> protein;
  final Value<double> fat;
  final Value<double> carbs;
  final Value<int> rowid;
  const NutritionEntriesCompanion({
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.id = const Value.absent(),
    this.mealId = const Value.absent(),
    this.productId = const Value.absent(),
    this.grams = const Value.absent(),
    this.productName = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.fat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionEntriesCompanion.insert({
    required String userId,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String id,
    required String mealId,
    required String productId,
    required double grams,
    required String productName,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       updatedAt = Value(updatedAt),
       id = Value(id),
       mealId = Value(mealId),
       productId = Value(productId),
       grams = Value(grams),
       productName = Value(productName),
       calories = Value(calories),
       protein = Value(protein),
       fat = Value(fat),
       carbs = Value(carbs);
  static Insertable<NutritionEntry> custom({
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRevision,
    Expression<int>? serverVersion,
    Expression<String>? id,
    Expression<String>? mealId,
    Expression<String>? productId,
    Expression<double>? grams,
    Expression<String>? productName,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<double>? fat,
    Expression<double>? carbs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRevision != null) 'local_revision': localRevision,
      if (serverVersion != null) 'server_version': serverVersion,
      if (id != null) 'id': id,
      if (mealId != null) 'meal_id': mealId,
      if (productId != null) 'product_id': productId,
      if (grams != null) 'grams': grams,
      if (productName != null) 'product_name': productName,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (fat != null) 'fat': fat,
      if (carbs != null) 'carbs': carbs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionEntriesCompanion copyWith({
    Value<String>? userId,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? localRevision,
    Value<int>? serverVersion,
    Value<String>? id,
    Value<String>? mealId,
    Value<String>? productId,
    Value<double>? grams,
    Value<String>? productName,
    Value<double>? calories,
    Value<double>? protein,
    Value<double>? fat,
    Value<double>? carbs,
    Value<int>? rowid,
  }) {
    return NutritionEntriesCompanion(
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRevision: localRevision ?? this.localRevision,
      serverVersion: serverVersion ?? this.serverVersion,
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      productId: productId ?? this.productId,
      grams: grams ?? this.grams,
      productName: productName ?? this.productName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mealId.present) {
      map['meal_id'] = Variable<String>(mealId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionEntriesCompanion(')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('productId: $productId, ')
          ..write('grams: $grams, ')
          ..write('productName: $productName, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NutritionOutboxTable extends NutritionOutbox
    with TableInfo<$NutritionOutboxTable, NutritionOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nutrition_users (id)',
    ),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    check: () => entity.isIn(['product', 'meal', 'entry']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    check: () => operation.isIn(['upsert', 'delete']),
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
  @override
  List<GeneratedColumn> get $columns => [
    sequence,
    mutationId,
    userId,
    entity,
    entityId,
    operation,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<NutritionOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sequence};
  @override
  NutritionOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutritionOutboxData(
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NutritionOutboxTable createAlias(String alias) {
    return $NutritionOutboxTable(attachedDatabase, alias);
  }
}

class NutritionOutboxData extends DataClass
    implements Insertable<NutritionOutboxData> {
  final int sequence;
  final String mutationId;
  final String userId;
  final String entity;
  final String entityId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  const NutritionOutboxData({
    required this.sequence,
    required this.mutationId,
    required this.userId,
    required this.entity,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sequence'] = Variable<int>(sequence);
    map['mutation_id'] = Variable<String>(mutationId);
    map['user_id'] = Variable<String>(userId);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NutritionOutboxCompanion toCompanion(bool nullToAbsent) {
    return NutritionOutboxCompanion(
      sequence: Value(sequence),
      mutationId: Value(mutationId),
      userId: Value(userId),
      entity: Value(entity),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory NutritionOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutritionOutboxData(
      sequence: serializer.fromJson<int>(json['sequence']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
      userId: serializer.fromJson<String>(json['userId']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sequence': serializer.toJson<int>(sequence),
      'mutationId': serializer.toJson<String>(mutationId),
      'userId': serializer.toJson<String>(userId),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NutritionOutboxData copyWith({
    int? sequence,
    String? mutationId,
    String? userId,
    String? entity,
    String? entityId,
    String? operation,
    String? payload,
    DateTime? createdAt,
  }) => NutritionOutboxData(
    sequence: sequence ?? this.sequence,
    mutationId: mutationId ?? this.mutationId,
    userId: userId ?? this.userId,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  NutritionOutboxData copyWithCompanion(NutritionOutboxCompanion data) {
    return NutritionOutboxData(
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
      userId: data.userId.present ? data.userId.value : this.userId,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutritionOutboxData(')
          ..write('sequence: $sequence, ')
          ..write('mutationId: $mutationId, ')
          ..write('userId: $userId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sequence,
    mutationId,
    userId,
    entity,
    entityId,
    operation,
    payload,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutritionOutboxData &&
          other.sequence == this.sequence &&
          other.mutationId == this.mutationId &&
          other.userId == this.userId &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class NutritionOutboxCompanion extends UpdateCompanion<NutritionOutboxData> {
  final Value<int> sequence;
  final Value<String> mutationId;
  final Value<String> userId;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  const NutritionOutboxCompanion({
    this.sequence = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.userId = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NutritionOutboxCompanion.insert({
    this.sequence = const Value.absent(),
    required String mutationId,
    required String userId,
    required String entity,
    required String entityId,
    required String operation,
    required String payload,
    required DateTime createdAt,
  }) : mutationId = Value(mutationId),
       userId = Value(userId),
       entity = Value(entity),
       entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<NutritionOutboxData> custom({
    Expression<int>? sequence,
    Expression<String>? mutationId,
    Expression<String>? userId,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (sequence != null) 'sequence': sequence,
      if (mutationId != null) 'mutation_id': mutationId,
      if (userId != null) 'user_id': userId,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NutritionOutboxCompanion copyWith({
    Value<int>? sequence,
    Value<String>? mutationId,
    Value<String>? userId,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? createdAt,
  }) {
    return NutritionOutboxCompanion(
      sequence: sequence ?? this.sequence,
      mutationId: mutationId ?? this.mutationId,
      userId: userId ?? this.userId,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionOutboxCompanion(')
          ..write('sequence: $sequence, ')
          ..write('mutationId: $mutationId, ')
          ..write('userId: $userId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalProfilesTable localProfiles = $LocalProfilesTable(this);
  late final $LocalRemindersTable localReminders = $LocalRemindersTable(this);
  late final $NutritionUsersTable nutritionUsers = $NutritionUsersTable(this);
  late final $NutritionProductsTable nutritionProducts =
      $NutritionProductsTable(this);
  late final $NutritionMealsTable nutritionMeals = $NutritionMealsTable(this);
  late final $NutritionEntriesTable nutritionEntries = $NutritionEntriesTable(
    this,
  );
  late final $NutritionOutboxTable nutritionOutbox = $NutritionOutboxTable(
    this,
  );
  late final Index nutritionLocalUser = Index(
    'nutrition_local_user',
    'CREATE UNIQUE INDEX nutrition_local_user ON nutrition_users (local_slot) WHERE local_slot IS NOT NULL',
  );
  late final Index nutritionProductsOwnerName = Index(
    'nutrition_products_owner_name',
    'CREATE INDEX nutrition_products_owner_name ON nutrition_products (user_id, deleted_at, name)',
  );
  late final Index nutritionMealsOwnerDay = Index(
    'nutrition_meals_owner_day',
    'CREATE INDEX nutrition_meals_owner_day ON nutrition_meals (user_id, day, deleted_at)',
  );
  late final Index nutritionEntriesMeal = Index(
    'nutrition_entries_meal',
    'CREATE INDEX nutrition_entries_meal ON nutrition_entries (user_id, meal_id, deleted_at)',
  );
  late final Index nutritionEntriesProduct = Index(
    'nutrition_entries_product',
    'CREATE INDEX nutrition_entries_product ON nutrition_entries (user_id, product_id)',
  );
  late final Index nutritionOutboxOrder = Index(
    'nutrition_outbox_order',
    'CREATE INDEX nutrition_outbox_order ON nutrition_outbox (sequence)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localProfiles,
    localReminders,
    nutritionUsers,
    nutritionProducts,
    nutritionMeals,
    nutritionEntries,
    nutritionOutbox,
    nutritionLocalUser,
    nutritionProductsOwnerName,
    nutritionMealsOwnerDay,
    nutritionEntriesMeal,
    nutritionEntriesProduct,
    nutritionOutboxOrder,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('nutrition_users', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$LocalProfilesTableCreateCompanionBuilder =
    LocalProfilesCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime?> birthDate,
      required String sex,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<double?> targetWeightKg,
      required String activity,
      required String goal,
      Value<String?> programId,
      required DateTime updatedAt,
    });
typedef $$LocalProfilesTableUpdateCompanionBuilder =
    LocalProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime?> birthDate,
      Value<String> sex,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<double?> targetWeightKg,
      Value<String> activity,
      Value<String> goal,
      Value<String?> programId,
      Value<DateTime> updatedAt,
    });

final class $$LocalProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $LocalProfilesTable, LocalProfile> {
  $$LocalProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$NutritionUsersTable, List<NutritionUser>>
  _nutritionUsersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.nutritionUsers,
    aliasName: 'local_profiles__id__nutrition_users__profile_id',
  );

  $$NutritionUsersTableProcessedTableManager get nutritionUsersRefs {
    final manager = $$NutritionUsersTableTableManager(
      $_db,
      $_db.nutritionUsers,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_nutritionUsersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get programId => $composableBuilder(
    column: $table.programId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> nutritionUsersRefs(
    Expression<bool> Function($$NutritionUsersTableFilterComposer f) f,
  ) {
    final $$NutritionUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableFilterComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get programId => $composableBuilder(
    column: $table.programId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get programId =>
      $composableBuilder(column: $table.programId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> nutritionUsersRefs<T extends Object>(
    Expression<T> Function($$NutritionUsersTableAnnotationComposer a) f,
  ) {
    final $$NutritionUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProfilesTable,
          LocalProfile,
          $$LocalProfilesTableFilterComposer,
          $$LocalProfilesTableOrderingComposer,
          $$LocalProfilesTableAnnotationComposer,
          $$LocalProfilesTableCreateCompanionBuilder,
          $$LocalProfilesTableUpdateCompanionBuilder,
          (LocalProfile, $$LocalProfilesTableReferences),
          LocalProfile,
          PrefetchHooks Function({bool nutritionUsersRefs})
        > {
  $$LocalProfilesTableTableManager(_$AppDatabase db, $LocalProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<String> activity = const Value.absent(),
                Value<String> goal = const Value.absent(),
                Value<String?> programId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalProfilesCompanion(
                id: id,
                name: name,
                birthDate: birthDate,
                sex: sex,
                heightCm: heightCm,
                weightKg: weightKg,
                targetWeightKg: targetWeightKg,
                activity: activity,
                goal: goal,
                programId: programId,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime?> birthDate = const Value.absent(),
                required String sex,
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                required String activity,
                required String goal,
                Value<String?> programId = const Value.absent(),
                required DateTime updatedAt,
              }) => LocalProfilesCompanion.insert(
                id: id,
                name: name,
                birthDate: birthDate,
                sex: sex,
                heightCm: heightCm,
                weightKg: weightKg,
                targetWeightKg: targetWeightKg,
                activity: activity,
                goal: goal,
                programId: programId,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalProfilesTable, LocalProfile>(table),
                  $$LocalProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({nutritionUsersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (nutritionUsersRefs) db.nutritionUsers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (nutritionUsersRefs)
                    await $_getPrefetchedData<
                      LocalProfile,
                      $LocalProfilesTable,
                      NutritionUser
                    >(
                      currentTable: table,
                      referencedTable: $$LocalProfilesTableReferences
                          ._nutritionUsersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LocalProfilesTableReferences(
                            db,
                            table,
                            p0,
                          ).nutritionUsersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.profileId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocalProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProfilesTable,
      LocalProfile,
      $$LocalProfilesTableFilterComposer,
      $$LocalProfilesTableOrderingComposer,
      $$LocalProfilesTableAnnotationComposer,
      $$LocalProfilesTableCreateCompanionBuilder,
      $$LocalProfilesTableUpdateCompanionBuilder,
      (LocalProfile, $$LocalProfilesTableReferences),
      LocalProfile,
      PrefetchHooks Function({bool nutritionUsersRefs})
    >;
typedef $$LocalRemindersTableCreateCompanionBuilder =
    LocalRemindersCompanion Function({
      Value<int> id,
      required String frequency,
      required int hour,
      required int minute,
      required int weekday,
      required int monthDay,
    });
typedef $$LocalRemindersTableUpdateCompanionBuilder =
    LocalRemindersCompanion Function({
      Value<int> id,
      Value<String> frequency,
      Value<int> hour,
      Value<int> minute,
      Value<int> weekday,
      Value<int> monthDay,
    });

class $$LocalRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRemindersTable> {
  $$LocalRemindersTableFilterComposer({
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

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthDay => $composableBuilder(
    column: $table.monthDay,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRemindersTable> {
  $$LocalRemindersTableOrderingComposer({
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

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthDay => $composableBuilder(
    column: $table.monthDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRemindersTable> {
  $$LocalRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<int> get monthDay =>
      $composableBuilder(column: $table.monthDay, builder: (column) => column);
}

class $$LocalRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRemindersTable,
          LocalReminder,
          $$LocalRemindersTableFilterComposer,
          $$LocalRemindersTableOrderingComposer,
          $$LocalRemindersTableAnnotationComposer,
          $$LocalRemindersTableCreateCompanionBuilder,
          $$LocalRemindersTableUpdateCompanionBuilder,
          (
            LocalReminder,
            BaseReferences<_$AppDatabase, $LocalRemindersTable, LocalReminder>,
          ),
          LocalReminder,
          PrefetchHooks Function()
        > {
  $$LocalRemindersTableTableManager(
    _$AppDatabase db,
    $LocalRemindersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<int> monthDay = const Value.absent(),
              }) => LocalRemindersCompanion(
                id: id,
                frequency: frequency,
                hour: hour,
                minute: minute,
                weekday: weekday,
                monthDay: monthDay,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String frequency,
                required int hour,
                required int minute,
                required int weekday,
                required int monthDay,
              }) => LocalRemindersCompanion.insert(
                id: id,
                frequency: frequency,
                hour: hour,
                minute: minute,
                weekday: weekday,
                monthDay: monthDay,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalRemindersTable, LocalReminder>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalRemindersTable,
                    LocalReminder
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRemindersTable,
      LocalReminder,
      $$LocalRemindersTableFilterComposer,
      $$LocalRemindersTableOrderingComposer,
      $$LocalRemindersTableAnnotationComposer,
      $$LocalRemindersTableCreateCompanionBuilder,
      $$LocalRemindersTableUpdateCompanionBuilder,
      (
        LocalReminder,
        BaseReferences<_$AppDatabase, $LocalRemindersTable, LocalReminder>,
      ),
      LocalReminder,
      PrefetchHooks Function()
    >;
typedef $$NutritionUsersTableCreateCompanionBuilder =
    NutritionUsersCompanion Function({
      required String id,
      Value<int?> localSlot,
      Value<int?> profileId,
      Value<int> rowid,
    });
typedef $$NutritionUsersTableUpdateCompanionBuilder =
    NutritionUsersCompanion Function({
      Value<String> id,
      Value<int?> localSlot,
      Value<int?> profileId,
      Value<int> rowid,
    });

final class $$NutritionUsersTableReferences
    extends BaseReferences<_$AppDatabase, $NutritionUsersTable, NutritionUser> {
  $$NutritionUsersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalProfilesTable _profileIdTable(_$AppDatabase db) => db
      .localProfiles
      .createAlias('nutrition_users__profile_id__local_profiles__id');

  $$LocalProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$NutritionProductsTable, List<NutritionProduct>>
  _nutritionProductsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.nutritionProducts,
        aliasName: 'nutrition_users__id__nutrition_products__user_id',
      );

  $$NutritionProductsTableProcessedTableManager get nutritionProductsRefs {
    final manager = $$NutritionProductsTableTableManager(
      $_db,
      $_db.nutritionProducts,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _nutritionProductsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NutritionMealsTable, List<NutritionMeal>>
  _nutritionMealsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.nutritionMeals,
    aliasName: 'nutrition_users__id__nutrition_meals__user_id',
  );

  $$NutritionMealsTableProcessedTableManager get nutritionMealsRefs {
    final manager = $$NutritionMealsTableTableManager(
      $_db,
      $_db.nutritionMeals,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_nutritionMealsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NutritionEntriesTable, List<NutritionEntry>>
  _nutritionEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.nutritionEntries,
    aliasName: 'nutrition_users__id__nutrition_entries__user_id',
  );

  $$NutritionEntriesTableProcessedTableManager get nutritionEntriesRefs {
    final manager = $$NutritionEntriesTableTableManager(
      $_db,
      $_db.nutritionEntries,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _nutritionEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NutritionOutboxTable, List<NutritionOutboxData>>
  _nutritionOutboxRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.nutritionOutbox,
    aliasName: 'nutrition_users__id__nutrition_outbox__user_id',
  );

  $$NutritionOutboxTableProcessedTableManager get nutritionOutboxRefs {
    final manager = $$NutritionOutboxTableTableManager(
      $_db,
      $_db.nutritionOutbox,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _nutritionOutboxRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NutritionUsersTableFilterComposer
    extends Composer<_$AppDatabase, $NutritionUsersTable> {
  $$NutritionUsersTableFilterComposer({
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

  ColumnFilters<int> get localSlot => $composableBuilder(
    column: $table.localSlot,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> nutritionProductsRefs(
    Expression<bool> Function($$NutritionProductsTableFilterComposer f) f,
  ) {
    final $$NutritionProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nutritionProducts,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionProductsTableFilterComposer(
            $db: $db,
            $table: $db.nutritionProducts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> nutritionMealsRefs(
    Expression<bool> Function($$NutritionMealsTableFilterComposer f) f,
  ) {
    final $$NutritionMealsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nutritionMeals,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionMealsTableFilterComposer(
            $db: $db,
            $table: $db.nutritionMeals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> nutritionEntriesRefs(
    Expression<bool> Function($$NutritionEntriesTableFilterComposer f) f,
  ) {
    final $$NutritionEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nutritionEntries,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionEntriesTableFilterComposer(
            $db: $db,
            $table: $db.nutritionEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> nutritionOutboxRefs(
    Expression<bool> Function($$NutritionOutboxTableFilterComposer f) f,
  ) {
    final $$NutritionOutboxTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nutritionOutbox,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionOutboxTableFilterComposer(
            $db: $db,
            $table: $db.nutritionOutbox,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NutritionUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $NutritionUsersTable> {
  $$NutritionUsersTableOrderingComposer({
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

  ColumnOrderings<int> get localSlot => $composableBuilder(
    column: $table.localSlot,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutritionUsersTable> {
  $$NutritionUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get localSlot =>
      $composableBuilder(column: $table.localSlot, builder: (column) => column);

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> nutritionProductsRefs<T extends Object>(
    Expression<T> Function($$NutritionProductsTableAnnotationComposer a) f,
  ) {
    final $$NutritionProductsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.nutritionProducts,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NutritionProductsTableAnnotationComposer(
                $db: $db,
                $table: $db.nutritionProducts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> nutritionMealsRefs<T extends Object>(
    Expression<T> Function($$NutritionMealsTableAnnotationComposer a) f,
  ) {
    final $$NutritionMealsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nutritionMeals,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionMealsTableAnnotationComposer(
            $db: $db,
            $table: $db.nutritionMeals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> nutritionEntriesRefs<T extends Object>(
    Expression<T> Function($$NutritionEntriesTableAnnotationComposer a) f,
  ) {
    final $$NutritionEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nutritionEntries,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.nutritionEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> nutritionOutboxRefs<T extends Object>(
    Expression<T> Function($$NutritionOutboxTableAnnotationComposer a) f,
  ) {
    final $$NutritionOutboxTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nutritionOutbox,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionOutboxTableAnnotationComposer(
            $db: $db,
            $table: $db.nutritionOutbox,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NutritionUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutritionUsersTable,
          NutritionUser,
          $$NutritionUsersTableFilterComposer,
          $$NutritionUsersTableOrderingComposer,
          $$NutritionUsersTableAnnotationComposer,
          $$NutritionUsersTableCreateCompanionBuilder,
          $$NutritionUsersTableUpdateCompanionBuilder,
          (NutritionUser, $$NutritionUsersTableReferences),
          NutritionUser,
          PrefetchHooks Function({
            bool profileId,
            bool nutritionProductsRefs,
            bool nutritionMealsRefs,
            bool nutritionEntriesRefs,
            bool nutritionOutboxRefs,
          })
        > {
  $$NutritionUsersTableTableManager(
    _$AppDatabase db,
    $NutritionUsersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutritionUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> localSlot = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionUsersCompanion(
                id: id,
                localSlot: localSlot,
                profileId: profileId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> localSlot = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionUsersCompanion.insert(
                id: id,
                localSlot: localSlot,
                profileId: profileId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NutritionUsersTable, NutritionUser>(table),
                  $$NutritionUsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileId = false,
                nutritionProductsRefs = false,
                nutritionMealsRefs = false,
                nutritionEntriesRefs = false,
                nutritionOutboxRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (nutritionProductsRefs) db.nutritionProducts,
                    if (nutritionMealsRefs) db.nutritionMeals,
                    if (nutritionEntriesRefs) db.nutritionEntries,
                    if (nutritionOutboxRefs) db.nutritionOutbox,
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
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable:
                                        $$NutritionUsersTableReferences
                                            ._profileIdTable(db),
                                    referencedColumn:
                                        $$NutritionUsersTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (nutritionProductsRefs)
                        await $_getPrefetchedData<
                          NutritionUser,
                          $NutritionUsersTable,
                          NutritionProduct
                        >(
                          currentTable: table,
                          referencedTable: $$NutritionUsersTableReferences
                              ._nutritionProductsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NutritionUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).nutritionProductsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (nutritionMealsRefs)
                        await $_getPrefetchedData<
                          NutritionUser,
                          $NutritionUsersTable,
                          NutritionMeal
                        >(
                          currentTable: table,
                          referencedTable: $$NutritionUsersTableReferences
                              ._nutritionMealsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NutritionUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).nutritionMealsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (nutritionEntriesRefs)
                        await $_getPrefetchedData<
                          NutritionUser,
                          $NutritionUsersTable,
                          NutritionEntry
                        >(
                          currentTable: table,
                          referencedTable: $$NutritionUsersTableReferences
                              ._nutritionEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NutritionUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).nutritionEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (nutritionOutboxRefs)
                        await $_getPrefetchedData<
                          NutritionUser,
                          $NutritionUsersTable,
                          NutritionOutboxData
                        >(
                          currentTable: table,
                          referencedTable: $$NutritionUsersTableReferences
                              ._nutritionOutboxRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NutritionUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).nutritionOutboxRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
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

typedef $$NutritionUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutritionUsersTable,
      NutritionUser,
      $$NutritionUsersTableFilterComposer,
      $$NutritionUsersTableOrderingComposer,
      $$NutritionUsersTableAnnotationComposer,
      $$NutritionUsersTableCreateCompanionBuilder,
      $$NutritionUsersTableUpdateCompanionBuilder,
      (NutritionUser, $$NutritionUsersTableReferences),
      NutritionUser,
      PrefetchHooks Function({
        bool profileId,
        bool nutritionProductsRefs,
        bool nutritionMealsRefs,
        bool nutritionEntriesRefs,
        bool nutritionOutboxRefs,
      })
    >;
typedef $$NutritionProductsTableCreateCompanionBuilder =
    NutritionProductsCompanion Function({
      required String userId,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRevision,
      Value<int> serverVersion,
      required String id,
      required String name,
      required double calories,
      required double protein,
      required double fat,
      required double carbs,
      Value<int> rowid,
    });
typedef $$NutritionProductsTableUpdateCompanionBuilder =
    NutritionProductsCompanion Function({
      Value<String> userId,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRevision,
      Value<int> serverVersion,
      Value<String> id,
      Value<String> name,
      Value<double> calories,
      Value<double> protein,
      Value<double> fat,
      Value<double> carbs,
      Value<int> rowid,
    });

final class $$NutritionProductsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NutritionProductsTable,
          NutritionProduct
        > {
  $$NutritionProductsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NutritionUsersTable _userIdTable(_$AppDatabase db) => db
      .nutritionUsers
      .createAlias('nutrition_products__user_id__nutrition_users__id');

  $$NutritionUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$NutritionUsersTableTableManager(
      $_db,
      $_db.nutritionUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NutritionProductsTableFilterComposer
    extends Composer<_$AppDatabase, $NutritionProductsTable> {
  $$NutritionProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  $$NutritionUsersTableFilterComposer get userId {
    final $$NutritionUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableFilterComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $NutritionProductsTable> {
  $$NutritionProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  $$NutritionUsersTableOrderingComposer get userId {
    final $$NutritionUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableOrderingComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutritionProductsTable> {
  $$NutritionProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  $$NutritionUsersTableAnnotationComposer get userId {
    final $$NutritionUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutritionProductsTable,
          NutritionProduct,
          $$NutritionProductsTableFilterComposer,
          $$NutritionProductsTableOrderingComposer,
          $$NutritionProductsTableAnnotationComposer,
          $$NutritionProductsTableCreateCompanionBuilder,
          $$NutritionProductsTableUpdateCompanionBuilder,
          (NutritionProduct, $$NutritionProductsTableReferences),
          NutritionProduct,
          PrefetchHooks Function({bool userId})
        > {
  $$NutritionProductsTableTableManager(
    _$AppDatabase db,
    $NutritionProductsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutritionProductsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionProductsCompanion(
                userId: userId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                serverVersion: serverVersion,
                id: id,
                name: name,
                calories: calories,
                protein: protein,
                fat: fat,
                carbs: carbs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                required String id,
                required String name,
                required double calories,
                required double protein,
                required double fat,
                required double carbs,
                Value<int> rowid = const Value.absent(),
              }) => NutritionProductsCompanion.insert(
                userId: userId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                serverVersion: serverVersion,
                id: id,
                name: name,
                calories: calories,
                protein: protein,
                fat: fat,
                carbs: carbs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NutritionProductsTable, NutritionProduct>(table),
                  $$NutritionProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$NutritionProductsTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$NutritionProductsTableReferences
                                        ._userIdTable(db)
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

typedef $$NutritionProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutritionProductsTable,
      NutritionProduct,
      $$NutritionProductsTableFilterComposer,
      $$NutritionProductsTableOrderingComposer,
      $$NutritionProductsTableAnnotationComposer,
      $$NutritionProductsTableCreateCompanionBuilder,
      $$NutritionProductsTableUpdateCompanionBuilder,
      (NutritionProduct, $$NutritionProductsTableReferences),
      NutritionProduct,
      PrefetchHooks Function({bool userId})
    >;
typedef $$NutritionMealsTableCreateCompanionBuilder =
    NutritionMealsCompanion Function({
      required String userId,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRevision,
      Value<int> serverVersion,
      required String id,
      required String day,
      required String kind,
      Value<int> rowid,
    });
typedef $$NutritionMealsTableUpdateCompanionBuilder =
    NutritionMealsCompanion Function({
      Value<String> userId,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRevision,
      Value<int> serverVersion,
      Value<String> id,
      Value<String> day,
      Value<String> kind,
      Value<int> rowid,
    });

final class $$NutritionMealsTableReferences
    extends BaseReferences<_$AppDatabase, $NutritionMealsTable, NutritionMeal> {
  $$NutritionMealsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NutritionUsersTable _userIdTable(_$AppDatabase db) => db
      .nutritionUsers
      .createAlias('nutrition_meals__user_id__nutrition_users__id');

  $$NutritionUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$NutritionUsersTableTableManager(
      $_db,
      $_db.nutritionUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NutritionMealsTableFilterComposer
    extends Composer<_$AppDatabase, $NutritionMealsTable> {
  $$NutritionMealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  $$NutritionUsersTableFilterComposer get userId {
    final $$NutritionUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableFilterComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionMealsTableOrderingComposer
    extends Composer<_$AppDatabase, $NutritionMealsTable> {
  $$NutritionMealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  $$NutritionUsersTableOrderingComposer get userId {
    final $$NutritionUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableOrderingComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionMealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutritionMealsTable> {
  $$NutritionMealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$NutritionUsersTableAnnotationComposer get userId {
    final $$NutritionUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionMealsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutritionMealsTable,
          NutritionMeal,
          $$NutritionMealsTableFilterComposer,
          $$NutritionMealsTableOrderingComposer,
          $$NutritionMealsTableAnnotationComposer,
          $$NutritionMealsTableCreateCompanionBuilder,
          $$NutritionMealsTableUpdateCompanionBuilder,
          (NutritionMeal, $$NutritionMealsTableReferences),
          NutritionMeal,
          PrefetchHooks Function({bool userId})
        > {
  $$NutritionMealsTableTableManager(
    _$AppDatabase db,
    $NutritionMealsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionMealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionMealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutritionMealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionMealsCompanion(
                userId: userId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                serverVersion: serverVersion,
                id: id,
                day: day,
                kind: kind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                required String id,
                required String day,
                required String kind,
                Value<int> rowid = const Value.absent(),
              }) => NutritionMealsCompanion.insert(
                userId: userId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                serverVersion: serverVersion,
                id: id,
                day: day,
                kind: kind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NutritionMealsTable, NutritionMeal>(table),
                  $$NutritionMealsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$NutritionMealsTableReferences
                                    ._userIdTable(db),
                                referencedColumn:
                                    $$NutritionMealsTableReferences
                                        ._userIdTable(db)
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

typedef $$NutritionMealsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutritionMealsTable,
      NutritionMeal,
      $$NutritionMealsTableFilterComposer,
      $$NutritionMealsTableOrderingComposer,
      $$NutritionMealsTableAnnotationComposer,
      $$NutritionMealsTableCreateCompanionBuilder,
      $$NutritionMealsTableUpdateCompanionBuilder,
      (NutritionMeal, $$NutritionMealsTableReferences),
      NutritionMeal,
      PrefetchHooks Function({bool userId})
    >;
typedef $$NutritionEntriesTableCreateCompanionBuilder =
    NutritionEntriesCompanion Function({
      required String userId,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRevision,
      Value<int> serverVersion,
      required String id,
      required String mealId,
      required String productId,
      required double grams,
      required String productName,
      required double calories,
      required double protein,
      required double fat,
      required double carbs,
      Value<int> rowid,
    });
typedef $$NutritionEntriesTableUpdateCompanionBuilder =
    NutritionEntriesCompanion Function({
      Value<String> userId,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRevision,
      Value<int> serverVersion,
      Value<String> id,
      Value<String> mealId,
      Value<String> productId,
      Value<double> grams,
      Value<String> productName,
      Value<double> calories,
      Value<double> protein,
      Value<double> fat,
      Value<double> carbs,
      Value<int> rowid,
    });

final class $$NutritionEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $NutritionEntriesTable, NutritionEntry> {
  $$NutritionEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NutritionUsersTable _userIdTable(_$AppDatabase db) => db
      .nutritionUsers
      .createAlias('nutrition_entries__user_id__nutrition_users__id');

  $$NutritionUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$NutritionUsersTableTableManager(
      $_db,
      $_db.nutritionUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NutritionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $NutritionEntriesTable> {
  $$NutritionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealId => $composableBuilder(
    column: $table.mealId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  $$NutritionUsersTableFilterComposer get userId {
    final $$NutritionUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableFilterComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $NutritionEntriesTable> {
  $$NutritionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealId => $composableBuilder(
    column: $table.mealId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  $$NutritionUsersTableOrderingComposer get userId {
    final $$NutritionUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableOrderingComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutritionEntriesTable> {
  $$NutritionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mealId =>
      $composableBuilder(column: $table.mealId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  $$NutritionUsersTableAnnotationComposer get userId {
    final $$NutritionUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutritionEntriesTable,
          NutritionEntry,
          $$NutritionEntriesTableFilterComposer,
          $$NutritionEntriesTableOrderingComposer,
          $$NutritionEntriesTableAnnotationComposer,
          $$NutritionEntriesTableCreateCompanionBuilder,
          $$NutritionEntriesTableUpdateCompanionBuilder,
          (NutritionEntry, $$NutritionEntriesTableReferences),
          NutritionEntry,
          PrefetchHooks Function({bool userId})
        > {
  $$NutritionEntriesTableTableManager(
    _$AppDatabase db,
    $NutritionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutritionEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> mealId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionEntriesCompanion(
                userId: userId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                serverVersion: serverVersion,
                id: id,
                mealId: mealId,
                productId: productId,
                grams: grams,
                productName: productName,
                calories: calories,
                protein: protein,
                fat: fat,
                carbs: carbs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                required String id,
                required String mealId,
                required String productId,
                required double grams,
                required String productName,
                required double calories,
                required double protein,
                required double fat,
                required double carbs,
                Value<int> rowid = const Value.absent(),
              }) => NutritionEntriesCompanion.insert(
                userId: userId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                serverVersion: serverVersion,
                id: id,
                mealId: mealId,
                productId: productId,
                grams: grams,
                productName: productName,
                calories: calories,
                protein: protein,
                fat: fat,
                carbs: carbs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NutritionEntriesTable, NutritionEntry>(table),
                  $$NutritionEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$NutritionEntriesTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$NutritionEntriesTableReferences
                                        ._userIdTable(db)
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

typedef $$NutritionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutritionEntriesTable,
      NutritionEntry,
      $$NutritionEntriesTableFilterComposer,
      $$NutritionEntriesTableOrderingComposer,
      $$NutritionEntriesTableAnnotationComposer,
      $$NutritionEntriesTableCreateCompanionBuilder,
      $$NutritionEntriesTableUpdateCompanionBuilder,
      (NutritionEntry, $$NutritionEntriesTableReferences),
      NutritionEntry,
      PrefetchHooks Function({bool userId})
    >;
typedef $$NutritionOutboxTableCreateCompanionBuilder =
    NutritionOutboxCompanion Function({
      Value<int> sequence,
      required String mutationId,
      required String userId,
      required String entity,
      required String entityId,
      required String operation,
      required String payload,
      required DateTime createdAt,
    });
typedef $$NutritionOutboxTableUpdateCompanionBuilder =
    NutritionOutboxCompanion Function({
      Value<int> sequence,
      Value<String> mutationId,
      Value<String> userId,
      Value<String> entity,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> createdAt,
    });

final class $$NutritionOutboxTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NutritionOutboxTable,
          NutritionOutboxData
        > {
  $$NutritionOutboxTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NutritionUsersTable _userIdTable(_$AppDatabase db) => db
      .nutritionUsers
      .createAlias('nutrition_outbox__user_id__nutrition_users__id');

  $$NutritionUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$NutritionUsersTableTableManager(
      $_db,
      $_db.nutritionUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NutritionOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $NutritionOutboxTable> {
  $$NutritionOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
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

  $$NutritionUsersTableFilterComposer get userId {
    final $$NutritionUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableFilterComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $NutritionOutboxTable> {
  $$NutritionOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
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

  $$NutritionUsersTableOrderingComposer get userId {
    final $$NutritionUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableOrderingComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutritionOutboxTable> {
  $$NutritionOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$NutritionUsersTableAnnotationComposer get userId {
    final $$NutritionUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.nutritionUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.nutritionUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutritionOutboxTable,
          NutritionOutboxData,
          $$NutritionOutboxTableFilterComposer,
          $$NutritionOutboxTableOrderingComposer,
          $$NutritionOutboxTableAnnotationComposer,
          $$NutritionOutboxTableCreateCompanionBuilder,
          $$NutritionOutboxTableUpdateCompanionBuilder,
          (NutritionOutboxData, $$NutritionOutboxTableReferences),
          NutritionOutboxData,
          PrefetchHooks Function({bool userId})
        > {
  $$NutritionOutboxTableTableManager(
    _$AppDatabase db,
    $NutritionOutboxTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutritionOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sequence = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NutritionOutboxCompanion(
                sequence: sequence,
                mutationId: mutationId,
                userId: userId,
                entity: entity,
                entityId: entityId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> sequence = const Value.absent(),
                required String mutationId,
                required String userId,
                required String entity,
                required String entityId,
                required String operation,
                required String payload,
                required DateTime createdAt,
              }) => NutritionOutboxCompanion.insert(
                sequence: sequence,
                mutationId: mutationId,
                userId: userId,
                entity: entity,
                entityId: entityId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NutritionOutboxTable, NutritionOutboxData>(
                    table,
                  ),
                  $$NutritionOutboxTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$NutritionOutboxTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$NutritionOutboxTableReferences
                                        ._userIdTable(db)
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

typedef $$NutritionOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutritionOutboxTable,
      NutritionOutboxData,
      $$NutritionOutboxTableFilterComposer,
      $$NutritionOutboxTableOrderingComposer,
      $$NutritionOutboxTableAnnotationComposer,
      $$NutritionOutboxTableCreateCompanionBuilder,
      $$NutritionOutboxTableUpdateCompanionBuilder,
      (NutritionOutboxData, $$NutritionOutboxTableReferences),
      NutritionOutboxData,
      PrefetchHooks Function({bool userId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalProfilesTableTableManager get localProfiles =>
      $$LocalProfilesTableTableManager(_db, _db.localProfiles);
  $$LocalRemindersTableTableManager get localReminders =>
      $$LocalRemindersTableTableManager(_db, _db.localReminders);
  $$NutritionUsersTableTableManager get nutritionUsers =>
      $$NutritionUsersTableTableManager(_db, _db.nutritionUsers);
  $$NutritionProductsTableTableManager get nutritionProducts =>
      $$NutritionProductsTableTableManager(_db, _db.nutritionProducts);
  $$NutritionMealsTableTableManager get nutritionMeals =>
      $$NutritionMealsTableTableManager(_db, _db.nutritionMeals);
  $$NutritionEntriesTableTableManager get nutritionEntries =>
      $$NutritionEntriesTableTableManager(_db, _db.nutritionEntries);
  $$NutritionOutboxTableTableManager get nutritionOutbox =>
      $$NutritionOutboxTableTableManager(_db, _db.nutritionOutbox);
}
