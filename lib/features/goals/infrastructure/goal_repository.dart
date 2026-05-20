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
}
