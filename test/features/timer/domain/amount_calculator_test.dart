import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/timer/domain/amount_calculator.dart';

void main() {
  group('AmountCalculator.calculate', () {
    test('returns 0 for non-positive duration or rate', () {
      expect(AmountCalculator.calculate(durationSec: 0, hourlyRate: 1000), 0);
      expect(AmountCalculator.calculate(durationSec: -10, hourlyRate: 1000), 0);
      expect(AmountCalculator.calculate(durationSec: 100, hourlyRate: 0), 0);
    });

    test('one hour at 2000円 = 2000円', () {
      expect(
        AmountCalculator.calculate(durationSec: 3600, hourlyRate: 2000),
        2000,
      );
    });

    test('30 minutes at 2000円 = 1000円', () {
      expect(
        AmountCalculator.calculate(durationSec: 1800, hourlyRate: 2000),
        1000,
      );
    });

    test('rounds to nearest integer (banker not required)', () {
      // 1 second at 3000円/h = 3000/3600 = 0.833... → 1
      expect(
        AmountCalculator.calculate(durationSec: 1, hourlyRate: 3000),
        1,
      );
      // 1 second at 1000円/h = 1000/3600 = 0.277... → 0
      expect(
        AmountCalculator.calculate(durationSec: 1, hourlyRate: 1000),
        0,
      );
    });

    test('large duration', () {
      // 10 hours at 2000円 = 20000円
      expect(
        AmountCalculator.calculate(durationSec: 36000, hourlyRate: 2000),
        20000,
      );
    });
  });

  group('AmountCalculator.paidDurationSec (15 分単位切り下げ)', () {
    test('0 / negative → 0', () {
      expect(AmountCalculator.paidDurationSec(0), 0);
      expect(AmountCalculator.paidDurationSec(-100), 0);
    });

    test('under 15 minutes → 0', () {
      expect(AmountCalculator.paidDurationSec(14 * 60), 0);
      expect(AmountCalculator.paidDurationSec(15 * 60 - 1), 0);
    });

    test('exactly 15 minutes → 15 minutes', () {
      expect(AmountCalculator.paidDurationSec(15 * 60), 15 * 60);
    });

    test('between 15 and 30 minutes → 15 minutes', () {
      expect(AmountCalculator.paidDurationSec(23 * 60), 15 * 60);
      expect(AmountCalculator.paidDurationSec(29 * 60 + 59), 15 * 60);
    });

    test('exactly 30 minutes → 30 minutes', () {
      expect(AmountCalculator.paidDurationSec(30 * 60), 30 * 60);
    });

    test('60 minutes → 60 minutes', () {
      expect(AmountCalculator.paidDurationSec(60 * 60), 60 * 60);
    });
  });

  group('AmountCalculator.calculatePaid (15 分単位 + 時給)', () {
    test('時給 2000 円 / 14:59 → 0 円', () {
      expect(
        AmountCalculator.calculatePaid(
          workedSec: 14 * 60 + 59,
          hourlyRate: 2000,
        ),
        0,
      );
    });

    test('時給 2000 円 / 15:00 → 500 円', () {
      expect(
        AmountCalculator.calculatePaid(
          workedSec: 15 * 60,
          hourlyRate: 2000,
        ),
        500,
      );
    });

    test('時給 2000 円 / 23:00 → 500 円（15 分切り下げ）', () {
      expect(
        AmountCalculator.calculatePaid(
          workedSec: 23 * 60,
          hourlyRate: 2000,
        ),
        500,
      );
    });

    test('時給 2000 円 / 30:00 → 1000 円', () {
      expect(
        AmountCalculator.calculatePaid(
          workedSec: 30 * 60,
          hourlyRate: 2000,
        ),
        1000,
      );
    });

    test('時給 2000 円 / 60:00 → 2000 円', () {
      expect(
        AmountCalculator.calculatePaid(
          workedSec: 60 * 60,
          hourlyRate: 2000,
        ),
        2000,
      );
    });
  });
}
