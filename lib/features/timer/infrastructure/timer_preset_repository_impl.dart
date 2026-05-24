import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/database/app_database.dart';
import '../domain/timer_preset.dart';
import 'timer_preset_repository.dart';

class TimerPresetRepositoryImpl implements TimerPresetRepository {
  TimerPresetRepositoryImpl(this._db, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  $TimerPresetsTable get _table => _db.timerPresets;

  SimpleSelectStatement<$TimerPresetsTable, TimerPresetRow> _activeQuery() {
    return _db.select(_table)
      ..where((p) => p.deletedAt.isNull())
      // 表示順は sortOrder のみ（issue #120 でドラッグ&ドロップ並び替えに対応）。
      // 同じ sortOrder が混入したら minutes で安定化。
      ..orderBy([
        (p) => OrderingTerm.asc(p.sortOrder),
        (p) => OrderingTerm.asc(p.minutes),
      ]);
  }

  @override
  Stream<List<TimerPreset>> watchAll() {
    return _activeQuery()
        .watch()
        .map((rows) => rows.map(_toEntity).toList(growable: false));
  }

  @override
  Future<List<TimerPreset>> fetchAll() async {
    final rows = await _activeQuery().get();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<TimerPreset?> findById(String id) async {
    final row = await (_db.select(_table)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _toEntity(row);
  }

  @override
  Future<TimerPreset> create({
    required int minutes,
    required String label,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    // 新規はアクティブプリセットの末尾に追加（max sortOrder + 1）。
    final maxExp = _table.sortOrder.max();
    final query = _db.selectOnly(_table)
      ..where(_table.deletedAt.isNull())
      ..addColumns([maxExp]);
    final row = await query.getSingleOrNull();
    final nextSortOrder = (row?.read(maxExp) ?? -1) + 1;

    await _db.into(_table).insert(
          TimerPresetsCompanion(
            id: Value(id),
            minutes: Value(minutes),
            label: Value(label),
            sortOrder: Value(nextSortOrder),
            isDefault: const Value(false),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return TimerPreset(
      id: id,
      minutes: minutes,
      label: label,
      sortOrder: nextSortOrder,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now();
    await (_db.update(_table)..where((p) => p.id.equals(id))).write(
      TimerPresetsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_table)..where((p) => p.id.equals(orderedIds[i])))
            .write(TimerPresetsCompanion(
          sortOrder: Value(i),
          updatedAt: Value(now),
        ));
      }
    });
  }

  TimerPreset _toEntity(TimerPresetRow row) {
    return TimerPreset(
      id: row.id,
      minutes: row.minutes,
      label: row.label,
      sortOrder: row.sortOrder,
      isDefault: row.isDefault,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}
