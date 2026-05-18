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
}
