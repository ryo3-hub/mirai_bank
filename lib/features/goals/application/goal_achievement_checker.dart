import '../../history/infrastructure/work_session_repository.dart';
import '../domain/goal_progress.dart';
import '../infrastructure/goal_repository.dart';

class GoalAchievementChecker {
  GoalAchievementChecker(this._goalRepo, this._sessionRepo);

  final GoalRepository _goalRepo;
  final WorkSessionRepository _sessionRepo;

  /// Marks all active goals whose current amount has reached the target.
  /// Returns the IDs of goals that were newly marked achieved.
  Future<List<String>> checkAndMark() async {
    final goals = await _goalRepo.fetchActive();
    if (goals.isEmpty) return const [];
    final sessions = await _sessionRepo.fetchAll();
    final now = DateTime.now();
    final achieved = <String>[];
    for (final goal in goals) {
      final current = GoalAggregator.calculateCurrentAmount(
        goal: goal,
        sessions: sessions,
      );
      if (current >= goal.targetAmount) {
        await _goalRepo.markAchieved(goal.id, now);
        achieved.add(goal.id);
      }
    }
    return achieved;
  }
}
