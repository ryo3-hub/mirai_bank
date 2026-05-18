import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/timer/domain/active_timer.dart';

void main() {
  group('ActiveTimer.elapsedSecondsAt', () {
    final start = DateTime(2026, 1, 1, 10, 0, 0);
    final timer = ActiveTimer(categoryId: 'c1', startTime: start);

    test('returns 0 at start time', () {
      expect(timer.elapsedSecondsAt(start), 0);
    });

    test('returns positive seconds after start', () {
      expect(
        timer.elapsedSecondsAt(start.add(const Duration(minutes: 5))),
        300,
      );
    });

    test('clamps negative differences to 0', () {
      expect(
        timer.elapsedSecondsAt(start.subtract(const Duration(seconds: 10))),
        0,
      );
    });
  });
}
