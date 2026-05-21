import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/history/application/calendar_providers.dart';
import 'package:mirai_bank/features/history/domain/work_session.dart';

WorkSession _session({
  required String id,
  required String categoryId,
  required DateTime endTime,
  required int amount,
}) =>
    WorkSession(
      id: id,
      categoryId: categoryId,
      startTime: endTime.subtract(const Duration(hours: 1)),
      endTime: endTime,
      durationSec: 3600,
      amount: amount,
      inputMethod: WorkSessionInputMethod.manual,
      createdAt: endTime,
      updatedAt: endTime,
    );

void main() {
  group('computeDailyStatsMap', () {
    final monthStart = DateTime(2026, 5, 1);

    test('empty sessions → empty map', () {
      final result = computeDailyStatsMap(sessions: const [], month: monthStart);
      expect(result, isEmpty);
    });

    test('sums sessions on the same day and picks the largest category', () {
      final sessions = [
        _session(
          id: 's1',
          categoryId: 'cat-a',
          endTime: DateTime(2026, 5, 10, 9),
          amount: 1500,
        ),
        _session(
          id: 's2',
          categoryId: 'cat-b',
          endTime: DateTime(2026, 5, 10, 11),
          amount: 3000,
        ),
        _session(
          id: 's3',
          categoryId: 'cat-a',
          endTime: DateTime(2026, 5, 10, 13),
          amount: 1000,
        ),
      ];

      final result = computeDailyStatsMap(
        sessions: sessions,
        month: monthStart,
      );
      final day = DateTime(2026, 5, 10);
      expect(result.keys, [day]);
      expect(result[day]!.amount, 5500); // 1500 + 3000 + 1000
      // cat-a total 2500 vs cat-b 3000 → cat-b is dominant.
      expect(result[day]!.dominantCategoryId, 'cat-b');
    });

    test('ties resolve to the first-encountered category', () {
      final sessions = [
        _session(
          id: 's1',
          categoryId: 'cat-a',
          endTime: DateTime(2026, 5, 12, 10),
          amount: 2000,
        ),
        _session(
          id: 's2',
          categoryId: 'cat-b',
          endTime: DateTime(2026, 5, 12, 14),
          amount: 2000,
        ),
      ];

      final result = computeDailyStatsMap(
        sessions: sessions,
        month: monthStart,
      );
      final day = DateTime(2026, 5, 12);
      expect(result[day]!.amount, 4000);
      expect(result[day]!.dominantCategoryId, 'cat-a');
    });

    test('filters sessions outside the requested month', () {
      final sessions = [
        _session(
          id: 'prev',
          categoryId: 'cat-a',
          endTime: DateTime(2026, 4, 30, 23),
          amount: 1000,
        ),
        _session(
          id: 'inside',
          categoryId: 'cat-a',
          endTime: DateTime(2026, 5, 1, 12),
          amount: 2000,
        ),
        _session(
          id: 'next',
          categoryId: 'cat-a',
          endTime: DateTime(2026, 6, 1, 0),
          amount: 4000,
        ),
      ];

      final result = computeDailyStatsMap(
        sessions: sessions,
        month: monthStart,
      );
      expect(result.keys, [DateTime(2026, 5, 1)]);
      expect(result[DateTime(2026, 5, 1)]!.amount, 2000);
    });

    test('groups by end-time date (handles cross-day sessions)', () {
      // A session that starts at 23:00 and ends at 01:00 next day → counted
      // on the next day.
      final sessions = [
        _session(
          id: 'crossing',
          categoryId: 'cat-a',
          endTime: DateTime(2026, 5, 11, 1),
          amount: 1000,
        ),
      ];

      final result = computeDailyStatsMap(
        sessions: sessions,
        month: monthStart,
      );
      expect(result.keys, [DateTime(2026, 5, 11)]);
    });
  });
}
