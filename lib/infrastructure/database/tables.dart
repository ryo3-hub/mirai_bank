import 'package:drift/drift.dart';

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get hourlyRate => integer()();
  TextColumn get colorCode => text().withLength(min: 4, max: 9)();
  TextColumn get iconCode => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkSessionRow')
class WorkSessions extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get durationSec => integer()();
  IntColumn get amount => integer()();
  TextColumn get memo => text().nullable()();
  TextColumn get inputMethod => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ActiveTimerRow')
class ActiveTimers extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get categoryId => text().references(Categories, #id)();
  DateTimeColumn get startTime => dateTime()();
  TextColumn get memo => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GoalRow')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get targetAmount => integer()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  DateTimeColumn get periodStart => dateTime().nullable()();
  DateTimeColumn get periodEnd => dateTime().nullable()();
  DateTimeColumn get achievedAt => dateTime().nullable()();
  /// ユーザーが任意に並び替えできる表示順。
  /// 新規追加時はアクティブ目標の現在の最大値+1 を割り当て、末尾に追加される。
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SettingRow')
class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  BoolColumn get reminderEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get reminderTime => text().withDefault(const Constant('21:00'))();
  /// リマインダー通知する曜日のCSV（DateTime.weekday 形式: 1=月 .. 7=日）。
  /// デフォルトは毎日（"1,2,3,4,5,6,7"）。
  TextColumn get reminderWeekdaysCsv =>
      text().withDefault(const Constant('1,2,3,4,5,6,7'))();
  BoolColumn get achievementNotificationEnabled =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
