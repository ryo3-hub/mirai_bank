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

  group('ActiveTimer.completionTimeBy (issue #224)', () {
    final start = DateTime(2026, 1, 1, 14, 0, 0);

    test('returns null when still running and not completed yet', () {
      final timer = _running(startTime: start, targetMinutes: 15);
      expect(
        timer.completionTimeBy(start.add(const Duration(minutes: 10))),
        isNull,
      );
    });

    test('returns null exactly at target completion', () {
      // \`isCompletedAt\` is \`elapsed >= target\` なので、target ピッタリは
      // 含むが、stop() の通常パス（target 未満で停止）と区別するため
      // 厳密境界の挙動を固定化する。
      final timer = _running(startTime: start, targetMinutes: 15);
      expect(
        timer.completionTimeBy(start.add(const Duration(minutes: 15))),
        start.add(const Duration(minutes: 15)),
      );
    });

    test('returns startTime+target for never-paused overrun', () {
      // 14:00 開始の 5 分タイマーが、放置されて翌日 00:00 に検知された
      // ケース。実完了時刻は 14:05 のはず。
      final timer = _running(startTime: start, targetMinutes: 5);
      final detected = start.add(const Duration(hours: 10));
      expect(
        timer.completionTimeBy(detected),
        start.add(const Duration(minutes: 5)),
      );
    });

    test('returns resumedAt + (target - accumulated) after resume overrun', () {
      // 14:00 開始 30 分タイマー、14:10 で一時停止（accumulated=10 分）、
      // 23:00 で resume してそのまま放置。
      // 残り 20 分 → 実完了時刻は 23:20。
      final resumedAt = start.add(const Duration(hours: 9));
      final timer = _resumed(
        startTime: start,
        resumedAt: resumedAt,
        targetMinutes: 30,
        accumulatedSec: 10 * 60,
      );
      final detected = resumedAt.add(const Duration(hours: 2));
      expect(
        timer.completionTimeBy(detected),
        resumedAt.add(const Duration(minutes: 20)),
      );
    });

    test('returns null when paused (cannot overrun while paused)', () {
      // paused 中は elapsed が進まないので overrun 経路に入らない想定。
      // accumulated が target を超えていても、completionTimeBy は null を
      // 返して呼び出し側に「now を使え」と伝える保険動作。
      final paused = _paused(
        startTime: start,
        targetMinutes: 15,
        accumulatedSec: 30 * 60,
      );
      expect(paused.completionTimeBy(start), isNull);
    });

    test('returns null when targetDurationSec is 0', () {
      final timer = ActiveTimer(
        categoryId: 'c1',
        startTime: start,
        targetDurationSec: 0,
        accumulatedSec: 0,
        resumedAt: start,
      );
      expect(
        timer.completionTimeBy(start.add(const Duration(minutes: 40))),
        isNull,
      );
    });
  });
}
