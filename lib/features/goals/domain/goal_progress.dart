import '../../history/domain/work_session.dart';
import 'goal.dart';

class GoalProgress {
  const GoalProgress({
    required this.goal,
    required this.currentAmount,
  });

  final Goal goal;
  final int currentAmount;

  double get ratio {
    if (goal.targetAmount <= 0) return 0;
    return (currentAmount / goal.targetAmount).clamp(0.0, 1.0);
  }

  bool get hasReachedTarget => currentAmount >= goal.targetAmount;
}

class GoalAggregator {
  const GoalAggregator._();

  static int calculateCurrentAmount({
    required Goal goal,
    required List<WorkSession> sessions,
  }) {
    DateTime? endExclusive;
    if (goal.type == GoalType.period && goal.periodEnd != null) {
      final e = goal.periodEnd!;
      endExclusive = DateTime(e.year, e.month, e.day).add(
        const Duration(days: 1),
      );
    }

    var sum = 0;
    for (final s in sessions) {
      if (goal.categoryId != null && s.categoryId != goal.categoryId) {
        continue;
      }
      if (goal.type == GoalType.period) {
        final start = goal.periodStart;
        if (start == null || endExclusive == null) continue;
        if (s.endTime.isBefore(start)) continue;
        if (!s.endTime.isBefore(endExclusive)) continue;
      }
      sum += s.amount;
    }
    return sum;
  }
}
