import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/database/app_database.dart';
import '../domain/work_session.dart';
import 'work_session_repository.dart';

class WorkSessionRepositoryImpl implements WorkSessionRepository {
  WorkSessionRepositoryImpl(this._db, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  $WorkSessionsTable get _table => _db.workSessions;

  SimpleSelectStatement<$WorkSessionsTable, WorkSessionRow> _activeQuery() {
    return _db.select(_table)
      ..where((s) => s.deletedAt.isNull())
      ..orderBy([(s) => OrderingTerm.desc(s.startTime)]);
  }

  @override
  Stream<List<WorkSession>> watchAll() {
    return _activeQuery().watch().map(
          (rows) => rows.map(_toEntity).toList(growable: false),
        );
  }

  @override
  Future<List<WorkSession>> fetchAll() async {
    final rows = await _activeQuery().get();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<WorkSession?> findById(String id) async {
    final row = await (_db.select(_table)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _toEntity(row);
  }

  @override
  Future<WorkSession> create({
    required String categoryId,
    required DateTime startTime,
    required DateTime endTime,
    required int durationSec,
    required int amount,
    String? memo,
    required WorkSessionInputMethod inputMethod,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db.into(_table).insert(
          WorkSessionsCompanion(
            id: Value(id),
            categoryId: Value(categoryId),
            startTime: Value(startTime),
            endTime: Value(endTime),
            durationSec: Value(durationSec),
            amount: Value(amount),
            memo: Value(memo),
            inputMethod: Value(inputMethod.dbValue),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return WorkSession(
      id: id,
      categoryId: categoryId,
      startTime: startTime,
      endTime: endTime,
      durationSec: durationSec,
      amount: amount,
      memo: memo,
      inputMethod: inputMethod,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> update(WorkSession session) async {
    final now = DateTime.now();
    await (_db.update(_table)..where((s) => s.id.equals(session.id))).write(
      WorkSessionsCompanion(
        categoryId: Value(session.categoryId),
        startTime: Value(session.startTime),
        endTime: Value(session.endTime),
        durationSec: Value(session.durationSec),
        amount: Value(session.amount),
        memo: Value(session.memo),
        inputMethod: Value(session.inputMethod.dbValue),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now();
    await (_db.update(_table)..where((s) => s.id.equals(id))).write(
      WorkSessionsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  WorkSession _toEntity(WorkSessionRow row) {
    return WorkSession(
      id: row.id,
      categoryId: row.categoryId,
      startTime: row.startTime,
      endTime: row.endTime,
      durationSec: row.durationSec,
      amount: row.amount,
      memo: row.memo,
      inputMethod: WorkSessionInputMethod.fromDbValue(row.inputMethod),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}
