import 'package:drift/drift.dart';

import '../../../infrastructure/database/app_database.dart';
import '../domain/active_timer.dart';
import 'active_timer_repository.dart';

class ActiveTimerRepositoryImpl implements ActiveTimerRepository {
  ActiveTimerRepositoryImpl(this._db);

  final AppDatabase _db;

  static const int _singletonId = 1;

  $ActiveTimersTable get _table => _db.activeTimers;

  @override
  Stream<ActiveTimer?> watch() {
    return (_db.select(_table)..where((t) => t.id.equals(_singletonId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toEntity(row));
  }

  @override
  Future<ActiveTimer?> fetch() async {
    final row = await (_db.select(_table)
          ..where((t) => t.id.equals(_singletonId)))
        .getSingleOrNull();
    if (row == null) return null;
    return _toEntity(row);
  }

  @override
  Future<void> save({
    required String categoryId,
    required DateTime startTime,
    String? memo,
  }) async {
    await _db.into(_table).insertOnConflictUpdate(
          ActiveTimersCompanion(
            id: const Value(_singletonId),
            categoryId: Value(categoryId),
            startTime: Value(startTime),
            memo: Value(memo),
          ),
        );
  }

  @override
  Future<void> clear() async {
    await (_db.delete(_table)..where((t) => t.id.equals(_singletonId))).go();
  }

  ActiveTimer _toEntity(ActiveTimerRow row) {
    return ActiveTimer(
      categoryId: row.categoryId,
      startTime: row.startTime,
      memo: row.memo,
    );
  }
}
