import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/goals/domain/goal.dart';
import 'package:mirai_bank/features/goals/domain/goal_progress.dart';
import 'package:mirai_bank/features/history/domain/work_session.dart';

Goal _cumulativeGoal({
  String? categoryId,
  int targetAmount = 10000,
}) {
  return Goal(
    id: 'goal-1',
    type: GoalType.cumulative,
    targetAmount: targetAmount,
    categoryId: categoryId,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

Goal _periodGoal({
  String? categoryId,
  required DateTime start,
  required DateTime end,
  int targetAmount = 5000,
}) {
  return Goal(
    id: 'goal-period',
    type: GoalType.period,
    targetAmount: targetAmount,
    categoryId: categoryId,
    periodStart: start,
    periodEnd: end,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

WorkSession _session({
  required String categoryId,
  required DateTime endTime,
  required int amount,
}) {
  return WorkSession(
    id: 'sess-${endTime.millisecondsSinceEpoch}-$amount',
    categoryId: categoryId,
    startTime: endTime.subtract(const Duration(hours: 1)),
    endTime: endTime,
    durationSec: 3600,
    amount: amount,
    inputMethod: WorkSessionInputMethod.manual,
    createdAt: endTime,
    updatedAt: endTime,
  );
}

void main() {
  group('GoalProgress.ratio', () {
    test('clamps to 1.0 when current exceeds target', () {
      final goal = _cumulativeGoal(targetAmount: 1000);
      final p = GoalProgress(goal: goal, currentAmount: 5000);
      expect(p.ratio, 1.0);
      expect(p.hasReachedTarget, isTrue);
    });

    test('returns 0 when target is invalid', () {
      final goal = _cumulativeGoal(targetAmount: 0);
      final p = GoalProgress(goal: goal, currentAmount: 100);
      expect(p.ratio, 0);
    });

    test('returns proportional value', () {
      final goal = _cumulativeGoal(targetAmount: 10000);
      expect(
        GoalProgress(goal: goal, currentAmount: 2500).ratio,
        0.25,
      );
    });
  });

  group('GoalAggregator.calculateCurrentAmount — cumulative', () {
    test('all-categories sums every session', () {
      final amount = GoalAggregator.calculateCurrentAmount(
        goal: _cumulativeGoal(),
        sessions: [
          _session(
            categoryId: 'a',
            endTime: DateTime(2026, 5, 10),
            amount: 1000,
          ),
          _session(
            categoryId: 'b',
            endTime: DateTime(2026, 5, 11),
            amount: 2000,
          ),
        ],
      );
      expect(amount, 3000);
    });

    test('category-scoped filters by categoryId', () {
      final amount = GoalAggregator.calculateCurrentAmount(
        goal: _cumulativeGoal(categoryId: 'a'),
        sessions: [
          _session(
            categoryId: 'a',
            endTime: DateTime(2026, 5, 10),
            amount: 1000,
          ),
          _session(
            categoryId: 'b',
            endTime: DateTime(2026, 5, 11),
            amount: 2000,
          ),
        ],
      );
      expect(amount, 1000);
    });
  });

  group('GoalAggregator.calculateCurrentAmount — period', () {
    test('includes sessions ending within the period (end day inclusive)', () {
      final amount = GoalAggregator.calculateCurrentAmount(
        goal: _periodGoal(
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 31),
        ),
        sessions: [
          _session(
            categoryId: 'a',
            endTime: DateTime(2026, 5, 1, 0),
            amount: 100,
          ),
          _session(
            categoryId: 'a',
            endTime: DateTime(2026, 5, 31, 23, 59),
            amount: 200,
          ),
          _session(
            categoryId: 'a',
            endTime: DateTime(2026, 4, 30, 23, 59),
            amount: 300,
          ),
          _session(
            categoryId: 'a',
            endTime: DateTime(2026, 6, 1, 0),
            amount: 400,
          ),
        ],
      );
      expect(amount, 300);
    });

    test('combines category and period filters', () {
      final amount = GoalAggregator.calculateCurrentAmount(
        goal: _periodGoal(
          categoryId: 'a',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 31),
        ),
        sessions: [
          _session(
            categoryId: 'a',
            endTime: DateTime(2026, 5, 10),
            amount: 1000,
          ),
          _session(
            categoryId: 'b',
            endTime: DateTime(2026, 5, 10),
            amount: 5000,
          ),
        ],
      );
      expect(amount, 1000);
    });
  });
}
