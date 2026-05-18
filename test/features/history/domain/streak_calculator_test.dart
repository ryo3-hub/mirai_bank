import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/history/domain/streak_calculator.dart';
import 'package:mirai_bank/features/history/domain/work_session.dart';

WorkSession _session({required DateTime endTime}) {
  return WorkSession(
    id: 'sess-${endTime.millisecondsSinceEpoch}',
    categoryId: 'cat-1',
    startTime: endTime.subtract(const Duration(hours: 1)),
    endTime: endTime,
    durationSec: 3600,
    amount: 1000,
    inputMethod: WorkSessionInputMethod.manual,
    createdAt: endTime,
    updatedAt: endTime,
  );
}

void main() {
  group('StreakCalculator.compute', () {
    final now = DateTime(2026, 5, 17, 14);

    test('returns 0 for empty list', () {
      expect(StreakCalculator.compute(const [], now: now), 0);
    });

    test('returns 1 when only today has a session', () {
      expect(
        StreakCalculator.compute(
          [_session(endTime: DateTime(2026, 5, 17, 10))],
          now: now,
        ),
        1,
      );
    });

    test('counts consecutive days ending today', () {
      expect(
        StreakCalculator.compute(
          [
            _session(endTime: DateTime(2026, 5, 15, 10)),
            _session(endTime: DateTime(2026, 5, 16, 10)),
            _session(endTime: DateTime(2026, 5, 17, 10)),
          ],
          now: now,
        ),
        3,
      );
    });

    test('continues streak when today is empty but yesterday is active', () {
      expect(
        StreakCalculator.compute(
          [
            _session(endTime: DateTime(2026, 5, 15, 10)),
            _session(endTime: DateTime(2026, 5, 16, 10)),
          ],
          now: now,
        ),
        2,
      );
    });

    test('breaks streak when there is a gap', () {
      expect(
        StreakCalculator.compute(
          [
            _session(endTime: DateTime(2026, 5, 13, 10)),
            _session(endTime: DateTime(2026, 5, 17, 10)),
          ],
          now: now,
        ),
        1,
      );
    });

    test('returns 0 when neither today nor yesterday has sessions', () {
      expect(
        StreakCalculator.compute(
          [_session(endTime: DateTime(2026, 5, 10, 10))],
          now: now,
        ),
        0,
      );
    });

    test('multiple sessions on the same day count once', () {
      expect(
        StreakCalculator.compute(
          [
            _session(endTime: DateTime(2026, 5, 17, 8)),
            _session(endTime: DateTime(2026, 5, 17, 12)),
            _session(endTime: DateTime(2026, 5, 17, 22)),
          ],
          now: now,
        ),
        1,
      );
    });
  });

  group('StreakCalculator.milestoneIfFirstToday', () {
    final now = DateTime(2026, 5, 17, 14);

    test('returns milestone when streak == milestone and one session today',
        () {
      final sessions = [
        for (var i = 0; i < 3; i++)
          _session(endTime: DateTime(2026, 5, 15 + i, 10)),
      ];
      // streak = 3 (5/15, 5/16, 5/17), one today → returns 3
      expect(
        StreakCalculator.milestoneIfFirstToday(sessions, now: now),
        3,
      );
    });

    test('returns null when streak is not a milestone', () {
      final sessions = [
        for (var i = 0; i < 2; i++)
          _session(endTime: DateTime(2026, 5, 16 + i, 10)),
      ];
      // streak = 2
      expect(
        StreakCalculator.milestoneIfFirstToday(sessions, now: now),
        isNull,
      );
    });

    test('returns null when today already has more than one session', () {
      final sessions = [
        for (var i = 0; i < 2; i++)
          _session(endTime: DateTime(2026, 5, 15 + i, 10)),
        _session(endTime: DateTime(2026, 5, 17, 10)),
        _session(endTime: DateTime(2026, 5, 17, 20)),
      ];
      expect(
        StreakCalculator.milestoneIfFirstToday(sessions, now: now),
        isNull,
      );
    });
  });
}
