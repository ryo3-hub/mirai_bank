import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/timer/domain/active_timer.dart';

ActiveTimer _running({
  required DateTime startTime,
  int targetMinutes = 30,
  int accumulatedSec = 0,
}) =>
    ActiveTimer(
      categoryId: 'c1',
      startTime: startTime,
      targetDurationSec: targetMinutes * 60,
      accumulatedSec: accumulatedSec,
      resumedAt: startTime,
    );

ActiveTimer _resumed({
  required DateTime startTime,
  required DateTime resumedAt,
  int targetMinutes = 30,
  int accumulatedSec = 0,
}) =>
    ActiveTimer(
      categoryId: 'c1',
      startTime: startTime,
      targetDurationSec: targetMinutes * 60,
      accumulatedSec: accumulatedSec,
      resumedAt: resumedAt,
    );

ActiveTimer _paused({
  required DateTime startTime,
  int targetMinutes = 30,
  int accumulatedSec = 0,
}) =>
    ActiveTimer(
      categoryId: 'c1',
      startTime: startTime,
      targetDurationSec: targetMinutes * 60,
      accumulatedSec: accumulatedSec,
      resumedAt: null,
    );

void main() {
  group('ActiveTimer.elapsedSecondsAt — running', () {
    final start = DateTime(2026, 1, 1, 10, 0, 0);
    final timer = _running(startTime: start);

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

  group('ActiveTimer paused / resumed', () {
    final start = DateTime(2026, 1, 1, 10, 0, 0);

    test('paused timer keeps accumulatedSec regardless of now', () {
      final paused = _paused(startTime: start, accumulatedSec: 300);
      expect(paused.isPaused, true);
      expect(paused.elapsedSecondsAt(start.add(const Duration(minutes: 10))),
          300);
    });

    test('resumed timer adds accumulated + sinceResume', () {
      final resumedAt = start.add(const Duration(minutes: 10));
      final resumed = _resumed(
        startTime: start,
        resumedAt: resumedAt,
        accumulatedSec: 300,
      );
      expect(resumed.isPaused, false);
      expect(
        resumed.elapsedSecondsAt(resumedAt.add(const Duration(minutes: 7))),
        300 + 7 * 60,
      );
    });

    test('remaining clamps to 0 when over target', () {
      final timer = _paused(
        startTime: start,
        targetMinutes: 15,
        accumulatedSec: 30 * 60,
      );
      expect(timer.remainingSecondsAt(start), 0);
      expect(timer.isCompletedAt(start), true);
    });
  });

  group('ActiveTimer.billableSecondsAt (issue #186)', () {
    final start = DateTime(2026, 1, 1, 10, 0, 0);

    test('equals elapsed while under target', () {
      final timer = _running(startTime: start, targetMinutes: 15);
      expect(
        timer.billableSecondsAt(start.add(const Duration(minutes: 10))),
        10 * 60,
      );
    });

    test('equals elapsed exactly at target', () {
      final timer = _running(startTime: start, targetMinutes: 15);
      expect(
        timer.billableSecondsAt(start.add(const Duration(minutes: 15))),
        15 * 60,
      );
    });

    test('caps at target when left running in background past target', () {
      final timer = _running(startTime: start, targetMinutes: 15);
      expect(
        timer.billableSecondsAt(start.add(const Duration(hours: 2))),
        15 * 60,
      );
    });

    test('caps paused timer whose accumulated exceeds target', () {
      final timer = _paused(
        startTime: start,
        targetMinutes: 15,
        accumulatedSec: 60 * 60,
      );
      expect(timer.billableSecondsAt(start), 15 * 60);
    });

    test('no cap when targetDurationSec is 0', () {
      final timer = ActiveTimer(
        categoryId: 'c1',
        startTime: start,
        targetDurationSec: 0,
        accumulatedSec: 0,
        resumedAt: start,
      );
      expect(
        timer.billableSecondsAt(start.add(const Duration(minutes: 40))),
        40 * 60,
      );
    });
  });
}
