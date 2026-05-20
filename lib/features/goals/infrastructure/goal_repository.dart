import '../domain/goal.dart';

abstract interface class GoalRepository {
  Stream<List<Goal>> watchActive();

  Stream<List<Goal>> watchAchieved();

  Future<List<Goal>> fetchActive();

  Future<Goal?> findById(String id);

  Future<Goal> create({
    required GoalType type,
    required int targetAmount,
    String? categoryId,
    DateTime? periodStart,
    DateTime? periodEnd,
  });

  Future<void> update(Goal goal);

  Future<void> delete(String id);

  Future<void> markAchieved(String id, DateTime achievedAt);

  /// ユーザーが指定した順に並び替える。
  /// [orderedIds] にはアクティブ目標の id をユーザー希望の順序で渡す。
  /// sortOrder を 0..N に更新する。
  Future<void> reorder(List<String> orderedIds);
}
