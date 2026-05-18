import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/goals/domain/goal.dart';

void main() {
  group('Goal.validateTargetAmount', () {
    test('rejects empty / non-numeric / non-positive', () {
      expect(Goal.validateTargetAmount(null), isNotNull);
      expect(Goal.validateTargetAmount(''), isNotNull);
      expect(Goal.validateTargetAmount('abc'), isNotNull);
      expect(Goal.validateTargetAmount('0'), isNotNull);
      expect(Goal.validateTargetAmount('-1'), isNotNull);
    });

    test('rejects values above the max', () {
      expect(
        Goal.validateTargetAmount((Goal.targetAmountMax + 1).toString()),
        isNotNull,
      );
    });

    test('accepts valid amounts', () {
      expect(Goal.validateTargetAmount('1'), isNull);
      expect(Goal.validateTargetAmount('100000'), isNull);
      expect(
        Goal.validateTargetAmount(Goal.targetAmountMax.toString()),
        isNull,
      );
    });
  });

  group('Goal.validatePeriod', () {
    test('cumulative type ignores period', () {
      expect(
        Goal.validatePeriod(type: GoalType.cumulative),
        isNull,
      );
    });

    test('period type requires both dates', () {
      expect(
        Goal.validatePeriod(type: GoalType.period),
        isNotNull,
      );
      expect(
        Goal.validatePeriod(
          type: GoalType.period,
          start: DateTime(2026, 5, 1),
        ),
        isNotNull,
      );
    });

    test('period type rejects end before start', () {
      expect(
        Goal.validatePeriod(
          type: GoalType.period,
          start: DateTime(2026, 5, 10),
          end: DateTime(2026, 5, 5),
        ),
        isNotNull,
      );
    });

    test('period type accepts start == end (single-day goal)', () {
      expect(
        Goal.validatePeriod(
          type: GoalType.period,
          start: DateTime(2026, 5, 10),
          end: DateTime(2026, 5, 10),
        ),
        isNull,
      );
    });

    test('period type accepts start < end', () {
      expect(
        Goal.validatePeriod(
          type: GoalType.period,
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 31),
        ),
        isNull,
      );
    });
  });
}
