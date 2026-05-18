import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/database/app_database.dart';
import '../domain/goal.dart';
import 'goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  $GoalsTable get _table => _db.goals;

  @override
  Stream<List<Goal>> watchActive() {
    return (_db.select(_table)
          ..where((g) => g.achievedAt.isNull())
          ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList(growable: false));
  }

  @override
  Stream<List<Goal>> watchAchieved() {
    return (_db.select(_table)
          ..where((g) => g.achievedAt.isNotNull())
          ..orderBy([(g) => OrderingTerm.desc(g.achievedAt)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList(growable: false));
  }

  @override
  Future<List<Goal>> fetchActive() async {
    final rows = await (_db.select(_table)
          ..where((g) => g.achievedAt.isNull())
          ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
        .get();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<Goal?> findById(String id) async {
    final row = await (_db.select(_table)..where((g) => g.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _toEntity(row);
  }

  @override
  Future<Goal> create({
    required GoalType type,
    required int targetAmount,
    String? categoryId,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db.into(_table).insert(
          GoalsCompanion(
            id: Value(id),
            type: Value(type.dbValue),
            targetAmount: Value(targetAmount),
            categoryId: Value(categoryId),
            periodStart: Value(periodStart),
            periodEnd: Value(periodEnd),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return Goal(
      id: id,
      type: type,
      targetAmount: targetAmount,
      categoryId: categoryId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> update(Goal goal) async {
    final now = DateTime.now();
    await (_db.update(_table)..where((g) => g.id.equals(goal.id))).write(
      GoalsCompanion(
        type: Value(goal.type.dbValue),
        targetAmount: Value(goal.targetAmount),
        categoryId: Value(goal.categoryId),
        periodStart: Value(goal.periodStart),
        periodEnd: Value(goal.periodEnd),
        achievedAt: Value(goal.achievedAt),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_table)..where((g) => g.id.equals(id))).go();
  }

  @override
  Future<void> markAchieved(String id, DateTime achievedAt) async {
    final now = DateTime.now();
    await (_db.update(_table)..where((g) => g.id.equals(id))).write(
      GoalsCompanion(
        achievedAt: Value(achievedAt),
        updatedAt: Value(now),
      ),
    );
  }

  Goal _toEntity(GoalRow row) {
    return Goal(
      id: row.id,
      type: GoalType.fromDbValue(row.type),
      targetAmount: row.targetAmount,
      categoryId: row.categoryId,
      periodStart: row.periodStart,
      periodEnd: row.periodEnd,
      achievedAt: row.achievedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
