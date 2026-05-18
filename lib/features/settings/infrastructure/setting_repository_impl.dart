import 'package:drift/drift.dart';

import '../../../infrastructure/database/app_database.dart';
import '../domain/app_setting.dart';
import 'setting_repository.dart';

class SettingRepositoryImpl implements SettingRepository {
  SettingRepositoryImpl(this._db);

  final AppDatabase _db;

  static const int _singletonId = 1;

  $SettingsTable get _table => _db.settings;

  @override
  Stream<AppSetting> watch() {
    return (_db.select(_table)..where((s) => s.id.equals(_singletonId)))
        .watchSingleOrNull()
        .map((row) => row == null ? AppSetting.defaults : _toEntity(row));
  }

  @override
  Future<AppSetting> fetch() async {
    final row = await (_db.select(_table)
          ..where((s) => s.id.equals(_singletonId)))
        .getSingleOrNull();
    if (row == null) {
      await _ensureRow();
      return AppSetting.defaults;
    }
    return _toEntity(row);
  }

  @override
  Future<void> update({
    bool? reminderEnabled,
    String? reminderTime,
    bool? achievementNotificationEnabled,
  }) async {
    await _ensureRow();
    await (_db.update(_table)..where((s) => s.id.equals(_singletonId))).write(
      SettingsCompanion(
        reminderEnabled: reminderEnabled == null
            ? const Value.absent()
            : Value(reminderEnabled),
        reminderTime: reminderTime == null
            ? const Value.absent()
            : Value(reminderTime),
        achievementNotificationEnabled: achievementNotificationEnabled == null
            ? const Value.absent()
            : Value(achievementNotificationEnabled),
      ),
    );
  }

  Future<void> _ensureRow() async {
    await _db.into(_table).insertOnConflictUpdate(
          const SettingsCompanion(
            id: Value(_singletonId),
          ),
        );
  }

  AppSetting _toEntity(SettingRow row) {
    return AppSetting(
      reminderEnabled: row.reminderEnabled,
      reminderTime: row.reminderTime,
      achievementNotificationEnabled: row.achievementNotificationEnabled,
    );
  }
}
