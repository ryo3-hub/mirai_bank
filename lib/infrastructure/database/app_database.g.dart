// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _hourlyRateMeta =
      const VerificationMeta('hourlyRate');
  @override
  late final GeneratedColumn<int> hourlyRate = GeneratedColumn<int>(
      'hourly_rate', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _colorCodeMeta =
      const VerificationMeta('colorCode');
  @override
  late final GeneratedColumn<String> colorCode = GeneratedColumn<String>(
      'color_code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 4, maxTextLength: 9),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _iconCodeMeta =
      const VerificationMeta('iconCode');
  @override
  late final GeneratedColumn<String> iconCode = GeneratedColumn<String>(
      'icon_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        hourlyRate,
        colorCode,
        iconCode,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('hourly_rate')) {
      context.handle(
          _hourlyRateMeta,
          hourlyRate.isAcceptableOrUnknown(
              data['hourly_rate']!, _hourlyRateMeta));
    } else if (isInserting) {
      context.missing(_hourlyRateMeta);
    }
    if (data.containsKey('color_code')) {
      context.handle(_colorCodeMeta,
          colorCode.isAcceptableOrUnknown(data['color_code']!, _colorCodeMeta));
    } else if (isInserting) {
      context.missing(_colorCodeMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(_iconCodeMeta,
          iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta));
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      hourlyRate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hourly_rate'])!,
      colorCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_code'])!,
      iconCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_code'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final int hourlyRate;
  final String colorCode;
  final String iconCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CategoryRow(
      {required this.id,
      required this.name,
      required this.hourlyRate,
      required this.colorCode,
      required this.iconCode,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['hourly_rate'] = Variable<int>(hourlyRate);
    map['color_code'] = Variable<String>(colorCode);
    map['icon_code'] = Variable<String>(iconCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      hourlyRate: Value(hourlyRate),
      colorCode: Value(colorCode),
      iconCode: Value(iconCode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CategoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      hourlyRate: serializer.fromJson<int>(json['hourlyRate']),
      colorCode: serializer.fromJson<String>(json['colorCode']),
      iconCode: serializer.fromJson<String>(json['iconCode']),
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
      'name': serializer.toJson<String>(name),
      'hourlyRate': serializer.toJson<int>(hourlyRate),
      'colorCode': serializer.toJson<String>(colorCode),
      'iconCode': serializer.toJson<String>(iconCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CategoryRow copyWith(
          {String? id,
          String? name,
          int? hourlyRate,
          String? colorCode,
          String? iconCode,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      CategoryRow(
        id: id ?? this.id,
        name: name ?? this.name,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        colorCode: colorCode ?? this.colorCode,
        iconCode: iconCode ?? this.iconCode,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      hourlyRate:
          data.hourlyRate.present ? data.hourlyRate.value : this.hourlyRate,
      colorCode: data.colorCode.present ? data.colorCode.value : this.colorCode,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hourlyRate: $hourlyRate, ')
          ..write('colorCode: $colorCode, ')
          ..write('iconCode: $iconCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, hourlyRate, colorCode, iconCode,
      createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.hourlyRate == this.hourlyRate &&
          other.colorCode == this.colorCode &&
          other.iconCode == this.iconCode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> hourlyRate;
  final Value<String> colorCode;
  final Value<String> iconCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.hourlyRate = const Value.absent(),
    this.colorCode = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required int hourlyRate,
    required String colorCode,
    required String iconCode,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        hourlyRate = Value(hourlyRate),
        colorCode = Value(colorCode),
        iconCode = Value(iconCode),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? hourlyRate,
    Expression<String>? colorCode,
    Expression<String>? iconCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (hourlyRate != null) 'hourly_rate': hourlyRate,
      if (colorCode != null) 'color_code': colorCode,
      if (iconCode != null) 'icon_code': iconCode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? hourlyRate,
      Value<String>? colorCode,
      Value<String>? iconCode,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      colorCode: colorCode ?? this.colorCode,
      iconCode: iconCode ?? this.iconCode,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (hourlyRate.present) {
      map['hourly_rate'] = Variable<int>(hourlyRate.value);
    }
    if (colorCode.present) {
      map['color_code'] = Variable<String>(colorCode.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<String>(iconCode.value);
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
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hourlyRate: $hourlyRate, ')
          ..write('colorCode: $colorCode, ')
          ..write('iconCode: $iconCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkSessionsTable extends WorkSessions
    with TableInfo<$WorkSessionsTable, WorkSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationSecMeta =
      const VerificationMeta('durationSec');
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
      'duration_sec', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _inputMethodMeta =
      const VerificationMeta('inputMethod');
  @override
  late final GeneratedColumn<String> inputMethod = GeneratedColumn<String>(
      'input_method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        startTime,
        endTime,
        durationSec,
        amount,
        memo,
        inputMethod,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<WorkSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
          _durationSecMeta,
          durationSec.isAcceptableOrUnknown(
              data['duration_sec']!, _durationSecMeta));
    } else if (isInserting) {
      context.missing(_durationSecMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('input_method')) {
      context.handle(
          _inputMethodMeta,
          inputMethod.isAcceptableOrUnknown(
              data['input_method']!, _inputMethodMeta));
    } else if (isInserting) {
      context.missing(_inputMethodMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time'])!,
      durationSec: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_sec'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
      inputMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}input_method'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $WorkSessionsTable createAlias(String alias) {
    return $WorkSessionsTable(attachedDatabase, alias);
  }
}

class WorkSessionRow extends DataClass implements Insertable<WorkSessionRow> {
  final String id;
  final String categoryId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSec;
  final int amount;
  final String? memo;
  final String inputMethod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const WorkSessionRow(
      {required this.id,
      required this.categoryId,
      required this.startTime,
      required this.endTime,
      required this.durationSec,
      required this.amount,
      this.memo,
      required this.inputMethod,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['duration_sec'] = Variable<int>(durationSec);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['input_method'] = Variable<String>(inputMethod);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  WorkSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkSessionsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      startTime: Value(startTime),
      endTime: Value(endTime),
      durationSec: Value(durationSec),
      amount: Value(amount),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      inputMethod: Value(inputMethod),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WorkSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkSessionRow(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
      amount: serializer.fromJson<int>(json['amount']),
      memo: serializer.fromJson<String?>(json['memo']),
      inputMethod: serializer.fromJson<String>(json['inputMethod']),
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
      'categoryId': serializer.toJson<String>(categoryId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'durationSec': serializer.toJson<int>(durationSec),
      'amount': serializer.toJson<int>(amount),
      'memo': serializer.toJson<String?>(memo),
      'inputMethod': serializer.toJson<String>(inputMethod),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  WorkSessionRow copyWith(
          {String? id,
          String? categoryId,
          DateTime? startTime,
          DateTime? endTime,
          int? durationSec,
          int? amount,
          Value<String?> memo = const Value.absent(),
          String? inputMethod,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      WorkSessionRow(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        durationSec: durationSec ?? this.durationSec,
        amount: amount ?? this.amount,
        memo: memo.present ? memo.value : this.memo,
        inputMethod: inputMethod ?? this.inputMethod,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  WorkSessionRow copyWithCompanion(WorkSessionsCompanion data) {
    return WorkSessionRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationSec:
          data.durationSec.present ? data.durationSec.value : this.durationSec,
      amount: data.amount.present ? data.amount.value : this.amount,
      memo: data.memo.present ? data.memo.value : this.memo,
      inputMethod:
          data.inputMethod.present ? data.inputMethod.value : this.inputMethod,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkSessionRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSec: $durationSec, ')
          ..write('amount: $amount, ')
          ..write('memo: $memo, ')
          ..write('inputMethod: $inputMethod, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, startTime, endTime,
      durationSec, amount, memo, inputMethod, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkSessionRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationSec == this.durationSec &&
          other.amount == this.amount &&
          other.memo == this.memo &&
          other.inputMethod == this.inputMethod &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WorkSessionsCompanion extends UpdateCompanion<WorkSessionRow> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<int> durationSec;
  final Value<int> amount;
  final Value<String?> memo;
  final Value<String> inputMethod;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const WorkSessionsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.amount = const Value.absent(),
    this.memo = const Value.absent(),
    this.inputMethod = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkSessionsCompanion.insert({
    required String id,
    required String categoryId,
    required DateTime startTime,
    required DateTime endTime,
    required int durationSec,
    required int amount,
    this.memo = const Value.absent(),
    required String inputMethod,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        categoryId = Value(categoryId),
        startTime = Value(startTime),
        endTime = Value(endTime),
        durationSec = Value(durationSec),
        amount = Value(amount),
        inputMethod = Value(inputMethod),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<WorkSessionRow> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationSec,
    Expression<int>? amount,
    Expression<String>? memo,
    Expression<String>? inputMethod,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationSec != null) 'duration_sec': durationSec,
      if (amount != null) 'amount': amount,
      if (memo != null) 'memo': memo,
      if (inputMethod != null) 'input_method': inputMethod,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? categoryId,
      Value<DateTime>? startTime,
      Value<DateTime>? endTime,
      Value<int>? durationSec,
      Value<int>? amount,
      Value<String?>? memo,
      Value<String>? inputMethod,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return WorkSessionsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSec: durationSec ?? this.durationSec,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      inputMethod: inputMethod ?? this.inputMethod,
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
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (inputMethod.present) {
      map['input_method'] = Variable<String>(inputMethod.value);
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
    return (StringBuffer('WorkSessionsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSec: $durationSec, ')
          ..write('amount: $amount, ')
          ..write('memo: $memo, ')
          ..write('inputMethod: $inputMethod, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActiveTimersTable extends ActiveTimers
    with TableInfo<$ActiveTimersTable, ActiveTimerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiveTimersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, categoryId, startTime, memo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_timers';
  @override
  VerificationContext validateIntegrity(Insertable<ActiveTimerRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActiveTimerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiveTimerRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
    );
  }

  @override
  $ActiveTimersTable createAlias(String alias) {
    return $ActiveTimersTable(attachedDatabase, alias);
  }
}

class ActiveTimerRow extends DataClass implements Insertable<ActiveTimerRow> {
  final int id;
  final String categoryId;
  final DateTime startTime;
  final String? memo;
  const ActiveTimerRow(
      {required this.id,
      required this.categoryId,
      required this.startTime,
      this.memo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    return map;
  }

  ActiveTimersCompanion toCompanion(bool nullToAbsent) {
    return ActiveTimersCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      startTime: Value(startTime),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
    );
  }

  factory ActiveTimerRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiveTimerRow(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      memo: serializer.fromJson<String?>(json['memo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'memo': serializer.toJson<String?>(memo),
    };
  }

  ActiveTimerRow copyWith(
          {int? id,
          String? categoryId,
          DateTime? startTime,
          Value<String?> memo = const Value.absent()}) =>
      ActiveTimerRow(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        startTime: startTime ?? this.startTime,
        memo: memo.present ? memo.value : this.memo,
      );
  ActiveTimerRow copyWithCompanion(ActiveTimersCompanion data) {
    return ActiveTimerRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      memo: data.memo.present ? data.memo.value : this.memo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimerRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('startTime: $startTime, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, startTime, memo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveTimerRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.startTime == this.startTime &&
          other.memo == this.memo);
}

class ActiveTimersCompanion extends UpdateCompanion<ActiveTimerRow> {
  final Value<int> id;
  final Value<String> categoryId;
  final Value<DateTime> startTime;
  final Value<String?> memo;
  const ActiveTimersCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.memo = const Value.absent(),
  });
  ActiveTimersCompanion.insert({
    this.id = const Value.absent(),
    required String categoryId,
    required DateTime startTime,
    this.memo = const Value.absent(),
  })  : categoryId = Value(categoryId),
        startTime = Value(startTime);
  static Insertable<ActiveTimerRow> custom({
    Expression<int>? id,
    Expression<String>? categoryId,
    Expression<DateTime>? startTime,
    Expression<String>? memo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (startTime != null) 'start_time': startTime,
      if (memo != null) 'memo': memo,
    });
  }

  ActiveTimersCompanion copyWith(
      {Value<int>? id,
      Value<String>? categoryId,
      Value<DateTime>? startTime,
      Value<String?>? memo}) {
    return ActiveTimersCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      startTime: startTime ?? this.startTime,
      memo: memo ?? this.memo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimersCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('startTime: $startTime, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<int> targetAmount = GeneratedColumn<int>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _periodStartMeta =
      const VerificationMeta('periodStart');
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
      'period_start', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _periodEndMeta =
      const VerificationMeta('periodEnd');
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
      'period_end', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _achievedAtMeta =
      const VerificationMeta('achievedAt');
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
      'achieved_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        targetAmount,
        categoryId,
        periodStart,
        periodEnd,
        achievedAt,
        sortOrder,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<GoalRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('period_start')) {
      context.handle(
          _periodStartMeta,
          periodStart.isAcceptableOrUnknown(
              data['period_start']!, _periodStartMeta));
    }
    if (data.containsKey('period_end')) {
      context.handle(_periodEndMeta,
          periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta));
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
          _achievedAtMeta,
          achievedAt.isAcceptableOrUnknown(
              data['achieved_at']!, _achievedAtMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_amount'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      periodStart: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_start']),
      periodEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_end']),
      achievedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}achieved_at']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class GoalRow extends DataClass implements Insertable<GoalRow> {
  final String id;
  final String type;
  final int targetAmount;
  final String? categoryId;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? achievedAt;

  /// ユーザーが任意に並び替えできる表示順。
  /// 新規追加時はアクティブ目標の現在の最大値+1 を割り当て、末尾に追加される。
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GoalRow(
      {required this.id,
      required this.type,
      required this.targetAmount,
      this.categoryId,
      this.periodStart,
      this.periodEnd,
      this.achievedAt,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['target_amount'] = Variable<int>(targetAmount);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || periodStart != null) {
      map['period_start'] = Variable<DateTime>(periodStart);
    }
    if (!nullToAbsent || periodEnd != null) {
      map['period_end'] = Variable<DateTime>(periodEnd);
    }
    if (!nullToAbsent || achievedAt != null) {
      map['achieved_at'] = Variable<DateTime>(achievedAt);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      type: Value(type),
      targetAmount: Value(targetAmount),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      periodStart: periodStart == null && nullToAbsent
          ? const Value.absent()
          : Value(periodStart),
      periodEnd: periodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(periodEnd),
      achievedAt: achievedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(achievedAt),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GoalRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      targetAmount: serializer.fromJson<int>(json['targetAmount']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      periodStart: serializer.fromJson<DateTime?>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime?>(json['periodEnd']),
      achievedAt: serializer.fromJson<DateTime?>(json['achievedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'targetAmount': serializer.toJson<int>(targetAmount),
      'categoryId': serializer.toJson<String?>(categoryId),
      'periodStart': serializer.toJson<DateTime?>(periodStart),
      'periodEnd': serializer.toJson<DateTime?>(periodEnd),
      'achievedAt': serializer.toJson<DateTime?>(achievedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GoalRow copyWith(
          {String? id,
          String? type,
          int? targetAmount,
          Value<String?> categoryId = const Value.absent(),
          Value<DateTime?> periodStart = const Value.absent(),
          Value<DateTime?> periodEnd = const Value.absent(),
          Value<DateTime?> achievedAt = const Value.absent(),
          int? sortOrder,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      GoalRow(
        id: id ?? this.id,
        type: type ?? this.type,
        targetAmount: targetAmount ?? this.targetAmount,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        periodStart: periodStart.present ? periodStart.value : this.periodStart,
        periodEnd: periodEnd.present ? periodEnd.value : this.periodEnd,
        achievedAt: achievedAt.present ? achievedAt.value : this.achievedAt,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GoalRow copyWithCompanion(GoalsCompanion data) {
    return GoalRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      periodStart:
          data.periodStart.present ? data.periodStart.value : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      achievedAt:
          data.achievedAt.present ? data.achievedAt.value : this.achievedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('categoryId: $categoryId, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, targetAmount, categoryId,
      periodStart, periodEnd, achievedAt, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.targetAmount == this.targetAmount &&
          other.categoryId == this.categoryId &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.achievedAt == this.achievedAt &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GoalsCompanion extends UpdateCompanion<GoalRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<int> targetAmount;
  final Value<String?> categoryId;
  final Value<DateTime?> periodStart;
  final Value<DateTime?> periodEnd;
  final Value<DateTime?> achievedAt;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String type,
    required int targetAmount,
    this.categoryId = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        targetAmount = Value(targetAmount),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<GoalRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<int>? targetAmount,
    Expression<String>? categoryId,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<DateTime>? achievedAt,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (categoryId != null) 'category_id': categoryId,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<int>? targetAmount,
      Value<String?>? categoryId,
      Value<DateTime?>? periodStart,
      Value<DateTime?>? periodEnd,
      Value<DateTime?>? achievedAt,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return GoalsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      categoryId: categoryId ?? this.categoryId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      achievedAt: achievedAt ?? this.achievedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<int>(targetAmount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('categoryId: $categoryId, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _reminderEnabledMeta =
      const VerificationMeta('reminderEnabled');
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
      'reminder_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reminder_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _reminderTimeMeta =
      const VerificationMeta('reminderTime');
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
      'reminder_time', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('21:00'));
  static const VerificationMeta _reminderWeekdaysCsvMeta =
      const VerificationMeta('reminderWeekdaysCsv');
  @override
  late final GeneratedColumn<String> reminderWeekdaysCsv =
      GeneratedColumn<String>('reminder_weekdays_csv', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('1,2,3,4,5,6,7'));
  static const VerificationMeta _achievementNotificationEnabledMeta =
      const VerificationMeta('achievementNotificationEnabled');
  @override
  late final GeneratedColumn<bool> achievementNotificationEnabled =
      GeneratedColumn<bool>(
          'achievement_notification_enabled', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("achievement_notification_enabled" IN (0, 1))'),
          defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        reminderEnabled,
        reminderTime,
        reminderWeekdaysCsv,
        achievementNotificationEnabled
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<SettingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
          _reminderEnabledMeta,
          reminderEnabled.isAcceptableOrUnknown(
              data['reminder_enabled']!, _reminderEnabledMeta));
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
          _reminderTimeMeta,
          reminderTime.isAcceptableOrUnknown(
              data['reminder_time']!, _reminderTimeMeta));
    }
    if (data.containsKey('reminder_weekdays_csv')) {
      context.handle(
          _reminderWeekdaysCsvMeta,
          reminderWeekdaysCsv.isAcceptableOrUnknown(
              data['reminder_weekdays_csv']!, _reminderWeekdaysCsvMeta));
    }
    if (data.containsKey('achievement_notification_enabled')) {
      context.handle(
          _achievementNotificationEnabledMeta,
          achievementNotificationEnabled.isAcceptableOrUnknown(
              data['achievement_notification_enabled']!,
              _achievementNotificationEnabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      reminderEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}reminder_enabled'])!,
      reminderTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reminder_time'])!,
      reminderWeekdaysCsv: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reminder_weekdays_csv'])!,
      achievementNotificationEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}achievement_notification_enabled'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final int id;
  final bool reminderEnabled;
  final String reminderTime;

  /// リマインダー通知する曜日のCSV（DateTime.weekday 形式: 1=月 .. 7=日）。
  /// デフォルトは毎日（"1,2,3,4,5,6,7"）。
  final String reminderWeekdaysCsv;
  final bool achievementNotificationEnabled;
  const SettingRow(
      {required this.id,
      required this.reminderEnabled,
      required this.reminderTime,
      required this.reminderWeekdaysCsv,
      required this.achievementNotificationEnabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['reminder_time'] = Variable<String>(reminderTime);
    map['reminder_weekdays_csv'] = Variable<String>(reminderWeekdaysCsv);
    map['achievement_notification_enabled'] =
        Variable<bool>(achievementNotificationEnabled);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      reminderEnabled: Value(reminderEnabled),
      reminderTime: Value(reminderTime),
      reminderWeekdaysCsv: Value(reminderWeekdaysCsv),
      achievementNotificationEnabled: Value(achievementNotificationEnabled),
    );
  }

  factory SettingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      id: serializer.fromJson<int>(json['id']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderTime: serializer.fromJson<String>(json['reminderTime']),
      reminderWeekdaysCsv:
          serializer.fromJson<String>(json['reminderWeekdaysCsv']),
      achievementNotificationEnabled:
          serializer.fromJson<bool>(json['achievementNotificationEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderTime': serializer.toJson<String>(reminderTime),
      'reminderWeekdaysCsv': serializer.toJson<String>(reminderWeekdaysCsv),
      'achievementNotificationEnabled':
          serializer.toJson<bool>(achievementNotificationEnabled),
    };
  }

  SettingRow copyWith(
          {int? id,
          bool? reminderEnabled,
          String? reminderTime,
          String? reminderWeekdaysCsv,
          bool? achievementNotificationEnabled}) =>
      SettingRow(
        id: id ?? this.id,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        reminderTime: reminderTime ?? this.reminderTime,
        reminderWeekdaysCsv: reminderWeekdaysCsv ?? this.reminderWeekdaysCsv,
        achievementNotificationEnabled: achievementNotificationEnabled ??
            this.achievementNotificationEnabled,
      );
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      id: data.id.present ? data.id.value : this.id,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      reminderWeekdaysCsv: data.reminderWeekdaysCsv.present
          ? data.reminderWeekdaysCsv.value
          : this.reminderWeekdaysCsv,
      achievementNotificationEnabled:
          data.achievementNotificationEnabled.present
              ? data.achievementNotificationEnabled.value
              : this.achievementNotificationEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('id: $id, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('reminderWeekdaysCsv: $reminderWeekdaysCsv, ')
          ..write(
              'achievementNotificationEnabled: $achievementNotificationEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, reminderEnabled, reminderTime,
      reminderWeekdaysCsv, achievementNotificationEnabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.id == this.id &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderTime == this.reminderTime &&
          other.reminderWeekdaysCsv == this.reminderWeekdaysCsv &&
          other.achievementNotificationEnabled ==
              this.achievementNotificationEnabled);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<int> id;
  final Value<bool> reminderEnabled;
  final Value<String> reminderTime;
  final Value<String> reminderWeekdaysCsv;
  final Value<bool> achievementNotificationEnabled;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.reminderWeekdaysCsv = const Value.absent(),
    this.achievementNotificationEnabled = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.reminderWeekdaysCsv = const Value.absent(),
    this.achievementNotificationEnabled = const Value.absent(),
  });
  static Insertable<SettingRow> custom({
    Expression<int>? id,
    Expression<bool>? reminderEnabled,
    Expression<String>? reminderTime,
    Expression<String>? reminderWeekdaysCsv,
    Expression<bool>? achievementNotificationEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (reminderWeekdaysCsv != null)
        'reminder_weekdays_csv': reminderWeekdaysCsv,
      if (achievementNotificationEnabled != null)
        'achievement_notification_enabled': achievementNotificationEnabled,
    });
  }

  SettingsCompanion copyWith(
      {Value<int>? id,
      Value<bool>? reminderEnabled,
      Value<String>? reminderTime,
      Value<String>? reminderWeekdaysCsv,
      Value<bool>? achievementNotificationEnabled}) {
    return SettingsCompanion(
      id: id ?? this.id,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderWeekdaysCsv: reminderWeekdaysCsv ?? this.reminderWeekdaysCsv,
      achievementNotificationEnabled:
          achievementNotificationEnabled ?? this.achievementNotificationEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (reminderWeekdaysCsv.present) {
      map['reminder_weekdays_csv'] =
          Variable<String>(reminderWeekdaysCsv.value);
    }
    if (achievementNotificationEnabled.present) {
      map['achievement_notification_enabled'] =
          Variable<bool>(achievementNotificationEnabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('reminderWeekdaysCsv: $reminderWeekdaysCsv, ')
          ..write(
              'achievementNotificationEnabled: $achievementNotificationEnabled')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $WorkSessionsTable workSessions = $WorkSessionsTable(this);
  late final $ActiveTimersTable activeTimers = $ActiveTimersTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [categories, workSessions, activeTimers, goals, settings];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  required int hourlyRate,
  required String colorCode,
  required String iconCode,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> hourlyRate,
  Value<String> colorCode,
  Value<String> iconCode,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkSessionsTable, List<WorkSessionRow>>
      _workSessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workSessions,
              aliasName: $_aliasNameGenerator(
                  db.categories.id, db.workSessions.categoryId));

  $$WorkSessionsTableProcessedTableManager get workSessionsRefs {
    final manager = $$WorkSessionsTableTableManager($_db, $_db.workSessions)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ActiveTimersTable, List<ActiveTimerRow>>
      _activeTimersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.activeTimers,
              aliasName: $_aliasNameGenerator(
                  db.categories.id, db.activeTimers.categoryId));

  $$ActiveTimersTableProcessedTableManager get activeTimersRefs {
    final manager = $$ActiveTimersTableTableManager($_db, $_db.activeTimers)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activeTimersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GoalsTable, List<GoalRow>> _goalsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.goals,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.goals.categoryId));

  $$GoalsTableProcessedTableManager get goalsRefs {
    final manager = $$GoalsTableTableManager($_db, $_db.goals)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hourlyRate => $composableBuilder(
      column: $table.hourlyRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorCode => $composableBuilder(
      column: $table.colorCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconCode => $composableBuilder(
      column: $table.iconCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> workSessionsRefs(
      Expression<bool> Function($$WorkSessionsTableFilterComposer f) f) {
    final $$WorkSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workSessions,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkSessionsTableFilterComposer(
              $db: $db,
              $table: $db.workSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> activeTimersRefs(
      Expression<bool> Function($$ActiveTimersTableFilterComposer f) f) {
    final $$ActiveTimersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activeTimers,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActiveTimersTableFilterComposer(
              $db: $db,
              $table: $db.activeTimers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> goalsRefs(
      Expression<bool> Function($$GoalsTableFilterComposer f) f) {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.goals,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalsTableFilterComposer(
              $db: $db,
              $table: $db.goals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hourlyRate => $composableBuilder(
      column: $table.hourlyRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorCode => $composableBuilder(
      column: $table.colorCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconCode => $composableBuilder(
      column: $table.iconCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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

  GeneratedColumn<int> get hourlyRate => $composableBuilder(
      column: $table.hourlyRate, builder: (column) => column);

  GeneratedColumn<String> get colorCode =>
      $composableBuilder(column: $table.colorCode, builder: (column) => column);

  GeneratedColumn<String> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> workSessionsRefs<T extends Object>(
      Expression<T> Function($$WorkSessionsTableAnnotationComposer a) f) {
    final $$WorkSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workSessions,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.workSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> activeTimersRefs<T extends Object>(
      Expression<T> Function($$ActiveTimersTableAnnotationComposer a) f) {
    final $$ActiveTimersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activeTimers,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActiveTimersTableAnnotationComposer(
              $db: $db,
              $table: $db.activeTimers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> goalsRefs<T extends Object>(
      Expression<T> Function($$GoalsTableAnnotationComposer a) f) {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.goals,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalsTableAnnotationComposer(
              $db: $db,
              $table: $db.goals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, $$CategoriesTableReferences),
    CategoryRow,
    PrefetchHooks Function(
        {bool workSessionsRefs, bool activeTimersRefs, bool goalsRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> hourlyRate = const Value.absent(),
            Value<String> colorCode = const Value.absent(),
            Value<String> iconCode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            hourlyRate: hourlyRate,
            colorCode: colorCode,
            iconCode: iconCode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int hourlyRate,
            required String colorCode,
            required String iconCode,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            hourlyRate: hourlyRate,
            colorCode: colorCode,
            iconCode: iconCode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {workSessionsRefs = false,
              activeTimersRefs = false,
              goalsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workSessionsRefs) db.workSessions,
                if (activeTimersRefs) db.activeTimers,
                if (goalsRefs) db.goals
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workSessionsRefs)
                    await $_getPrefetchedData<CategoryRow, $CategoriesTable,
                            WorkSessionRow>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._workSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .workSessionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (activeTimersRefs)
                    await $_getPrefetchedData<CategoryRow, $CategoriesTable,
                            ActiveTimerRow>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._activeTimersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .activeTimersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (goalsRefs)
                    await $_getPrefetchedData<CategoryRow, $CategoriesTable,
                            GoalRow>(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._goalsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .goalsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, $$CategoriesTableReferences),
    CategoryRow,
    PrefetchHooks Function(
        {bool workSessionsRefs, bool activeTimersRefs, bool goalsRefs})>;
typedef $$WorkSessionsTableCreateCompanionBuilder = WorkSessionsCompanion
    Function({
  required String id,
  required String categoryId,
  required DateTime startTime,
  required DateTime endTime,
  required int durationSec,
  required int amount,
  Value<String?> memo,
  required String inputMethod,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$WorkSessionsTableUpdateCompanionBuilder = WorkSessionsCompanion
    Function({
  Value<String> id,
  Value<String> categoryId,
  Value<DateTime> startTime,
  Value<DateTime> endTime,
  Value<int> durationSec,
  Value<int> amount,
  Value<String?> memo,
  Value<String> inputMethod,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$WorkSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkSessionsTable, WorkSessionRow> {
  $$WorkSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.workSessions.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WorkSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkSessionsTable> {
  $$WorkSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inputMethod => $composableBuilder(
      column: $table.inputMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkSessionsTable> {
  $$WorkSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inputMethod => $composableBuilder(
      column: $table.inputMethod, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkSessionsTable> {
  $$WorkSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get inputMethod => $composableBuilder(
      column: $table.inputMethod, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkSessionsTable,
    WorkSessionRow,
    $$WorkSessionsTableFilterComposer,
    $$WorkSessionsTableOrderingComposer,
    $$WorkSessionsTableAnnotationComposer,
    $$WorkSessionsTableCreateCompanionBuilder,
    $$WorkSessionsTableUpdateCompanionBuilder,
    (WorkSessionRow, $$WorkSessionsTableReferences),
    WorkSessionRow,
    PrefetchHooks Function({bool categoryId})> {
  $$WorkSessionsTableTableManager(_$AppDatabase db, $WorkSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime> endTime = const Value.absent(),
            Value<int> durationSec = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<String> inputMethod = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkSessionsCompanion(
            id: id,
            categoryId: categoryId,
            startTime: startTime,
            endTime: endTime,
            durationSec: durationSec,
            amount: amount,
            memo: memo,
            inputMethod: inputMethod,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String categoryId,
            required DateTime startTime,
            required DateTime endTime,
            required int durationSec,
            required int amount,
            Value<String?> memo = const Value.absent(),
            required String inputMethod,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkSessionsCompanion.insert(
            id: id,
            categoryId: categoryId,
            startTime: startTime,
            endTime: endTime,
            durationSec: durationSec,
            amount: amount,
            memo: memo,
            inputMethod: inputMethod,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$WorkSessionsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$WorkSessionsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WorkSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkSessionsTable,
    WorkSessionRow,
    $$WorkSessionsTableFilterComposer,
    $$WorkSessionsTableOrderingComposer,
    $$WorkSessionsTableAnnotationComposer,
    $$WorkSessionsTableCreateCompanionBuilder,
    $$WorkSessionsTableUpdateCompanionBuilder,
    (WorkSessionRow, $$WorkSessionsTableReferences),
    WorkSessionRow,
    PrefetchHooks Function({bool categoryId})>;
typedef $$ActiveTimersTableCreateCompanionBuilder = ActiveTimersCompanion
    Function({
  Value<int> id,
  required String categoryId,
  required DateTime startTime,
  Value<String?> memo,
});
typedef $$ActiveTimersTableUpdateCompanionBuilder = ActiveTimersCompanion
    Function({
  Value<int> id,
  Value<String> categoryId,
  Value<DateTime> startTime,
  Value<String?> memo,
});

final class $$ActiveTimersTableReferences
    extends BaseReferences<_$AppDatabase, $ActiveTimersTable, ActiveTimerRow> {
  $$ActiveTimersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.activeTimers.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ActiveTimersTableFilterComposer
    extends Composer<_$AppDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ActiveTimersTableOrderingComposer
    extends Composer<_$AppDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ActiveTimersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ActiveTimersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActiveTimersTable,
    ActiveTimerRow,
    $$ActiveTimersTableFilterComposer,
    $$ActiveTimersTableOrderingComposer,
    $$ActiveTimersTableAnnotationComposer,
    $$ActiveTimersTableCreateCompanionBuilder,
    $$ActiveTimersTableUpdateCompanionBuilder,
    (ActiveTimerRow, $$ActiveTimersTableReferences),
    ActiveTimerRow,
    PrefetchHooks Function({bool categoryId})> {
  $$ActiveTimersTableTableManager(_$AppDatabase db, $ActiveTimersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActiveTimersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActiveTimersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActiveTimersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<String?> memo = const Value.absent(),
          }) =>
              ActiveTimersCompanion(
            id: id,
            categoryId: categoryId,
            startTime: startTime,
            memo: memo,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String categoryId,
            required DateTime startTime,
            Value<String?> memo = const Value.absent(),
          }) =>
              ActiveTimersCompanion.insert(
            id: id,
            categoryId: categoryId,
            startTime: startTime,
            memo: memo,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ActiveTimersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$ActiveTimersTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$ActiveTimersTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ActiveTimersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActiveTimersTable,
    ActiveTimerRow,
    $$ActiveTimersTableFilterComposer,
    $$ActiveTimersTableOrderingComposer,
    $$ActiveTimersTableAnnotationComposer,
    $$ActiveTimersTableCreateCompanionBuilder,
    $$ActiveTimersTableUpdateCompanionBuilder,
    (ActiveTimerRow, $$ActiveTimersTableReferences),
    ActiveTimerRow,
    PrefetchHooks Function({bool categoryId})>;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  required String id,
  required String type,
  required int targetAmount,
  Value<String?> categoryId,
  Value<DateTime?> periodStart,
  Value<DateTime?> periodEnd,
  Value<DateTime?> achievedAt,
  Value<int> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<int> targetAmount,
  Value<String?> categoryId,
  Value<DateTime?> periodStart,
  Value<DateTime?> periodEnd,
  Value<DateTime?> achievedAt,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$GoalsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalsTable, GoalRow> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias($_aliasNameGenerator(db.goals.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
      column: $table.achievedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
      column: $table.achievedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => column);

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
      column: $table.achievedAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalsTable,
    GoalRow,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (GoalRow, $$GoalsTableReferences),
    GoalRow,
    PrefetchHooks Function({bool categoryId})> {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> targetAmount = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<DateTime?> periodStart = const Value.absent(),
            Value<DateTime?> periodEnd = const Value.absent(),
            Value<DateTime?> achievedAt = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalsCompanion(
            id: id,
            type: type,
            targetAmount: targetAmount,
            categoryId: categoryId,
            periodStart: periodStart,
            periodEnd: periodEnd,
            achievedAt: achievedAt,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required int targetAmount,
            Value<String?> categoryId = const Value.absent(),
            Value<DateTime?> periodStart = const Value.absent(),
            Value<DateTime?> periodEnd = const Value.absent(),
            Value<DateTime?> achievedAt = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalsCompanion.insert(
            id: id,
            type: type,
            targetAmount: targetAmount,
            categoryId: categoryId,
            periodStart: periodStart,
            periodEnd: periodEnd,
            achievedAt: achievedAt,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GoalsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$GoalsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$GoalsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalsTable,
    GoalRow,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (GoalRow, $$GoalsTableReferences),
    GoalRow,
    PrefetchHooks Function({bool categoryId})>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<bool> reminderEnabled,
  Value<String> reminderTime,
  Value<String> reminderWeekdaysCsv,
  Value<bool> achievementNotificationEnabled,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<bool> reminderEnabled,
  Value<String> reminderTime,
  Value<String> reminderWeekdaysCsv,
  Value<bool> achievementNotificationEnabled,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
      column: $table.reminderEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderTime => $composableBuilder(
      column: $table.reminderTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderWeekdaysCsv => $composableBuilder(
      column: $table.reminderWeekdaysCsv,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get achievementNotificationEnabled => $composableBuilder(
      column: $table.achievementNotificationEnabled,
      builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
      column: $table.reminderEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderTime => $composableBuilder(
      column: $table.reminderTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderWeekdaysCsv => $composableBuilder(
      column: $table.reminderWeekdaysCsv,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get achievementNotificationEnabled =>
      $composableBuilder(
          column: $table.achievementNotificationEnabled,
          builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
      column: $table.reminderEnabled, builder: (column) => column);

  GeneratedColumn<String> get reminderTime => $composableBuilder(
      column: $table.reminderTime, builder: (column) => column);

  GeneratedColumn<String> get reminderWeekdaysCsv => $composableBuilder(
      column: $table.reminderWeekdaysCsv, builder: (column) => column);

  GeneratedColumn<bool> get achievementNotificationEnabled =>
      $composableBuilder(
          column: $table.achievementNotificationEnabled,
          builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    SettingRow,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
    SettingRow,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<bool> reminderEnabled = const Value.absent(),
            Value<String> reminderTime = const Value.absent(),
            Value<String> reminderWeekdaysCsv = const Value.absent(),
            Value<bool> achievementNotificationEnabled = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            reminderEnabled: reminderEnabled,
            reminderTime: reminderTime,
            reminderWeekdaysCsv: reminderWeekdaysCsv,
            achievementNotificationEnabled: achievementNotificationEnabled,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<bool> reminderEnabled = const Value.absent(),
            Value<String> reminderTime = const Value.absent(),
            Value<String> reminderWeekdaysCsv = const Value.absent(),
            Value<bool> achievementNotificationEnabled = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            id: id,
            reminderEnabled: reminderEnabled,
            reminderTime: reminderTime,
            reminderWeekdaysCsv: reminderWeekdaysCsv,
            achievementNotificationEnabled: achievementNotificationEnabled,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    SettingRow,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
    SettingRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$WorkSessionsTableTableManager get workSessions =>
      $$WorkSessionsTableTableManager(_db, _db.workSessions);
  $$ActiveTimersTableTableManager get activeTimers =>
      $$ActiveTimersTableTableManager(_db, _db.activeTimers);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
