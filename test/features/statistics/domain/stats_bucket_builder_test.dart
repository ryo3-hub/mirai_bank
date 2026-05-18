import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/history/domain/work_session.dart';
import 'package:mirai_bank/features/statistics/domain/stats_data.dart';

WorkSession _session({
  required DateTime endTime,
  required int amount,
}) {
  final start = endTime.subtract(const Duration(hours: 1));
  return WorkSession(
    id: 'id-${endTime.millisecondsSinceEpoch}-$amount',
    categoryId: 'cat-1',
    startTime: start,
    endTime: endTime,
    durationSec: 3600,
    amount: amount,
    inputMethod: WorkSessionInputMethod.manual,
    createdAt: endTime,
    updatedAt: endTime,
  );
}

void main() {
  group('StatsBucketBuilder.build', () {
    test('creates 7 daily buckets for a week range', () {
      final range = StatsDateRange(
        start: DateTime(2026, 5, 11),
        end: DateTime(2026, 5, 18),
        granularity: BucketGranularity.day,
      );
      final sessions = [
        _session(endTime: DateTime(2026, 5, 11, 12), amount: 500),
        _session(endTime: DateTime(2026, 5, 13, 8), amount: 1500),
        _session(endTime: DateTime(2026, 5, 17, 23), amount: 2000),
      ];
      final buckets = StatsBucketBuilder.build(
        range: range,
        sessions: sessions,
      );
      expect(buckets.length, 7);
      expect(buckets[0].amount, 500); // 5/11
      expect(buckets[1].amount, 0); // 5/12
      expect(buckets[2].amount, 1500); // 5/13
      expect(buckets[6].amount, 2000); // 5/17
      expect(buckets[0].label, '5/11');
    });

    test('creates 12 monthly buckets for a year range', () {
      final range = StatsDateRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2027, 1, 1),
        granularity: BucketGranularity.month,
      );
      final sessions = [
        _session(endTime: DateTime(2026, 3, 15), amount: 1000),
        _session(endTime: DateTime(2026, 12, 31, 23), amount: 5000),
      ];
      final buckets = StatsBucketBuilder.build(
        range: range,
        sessions: sessions,
      );
      expect(buckets.length, 12);
      expect(buckets[2].amount, 1000); // March
      expect(buckets[11].amount, 5000); // December
      expect(buckets[0].label, '1月');
    });

    test('all-time derives bounds from sessions, buckets by year', () {
      final sessions = [
        _session(endTime: DateTime(2024, 6, 1), amount: 100),
        _session(endTime: DateTime(2026, 2, 1), amount: 200),
      ];
      final buckets = StatsBucketBuilder.build(
        range: const StatsDateRange(granularity: BucketGranularity.year),
        sessions: sessions,
      );
      expect(buckets.length, 3); // 2024, 2025, 2026
      expect(buckets[0].label, '2024');
      expect(buckets[0].amount, 100);
      expect(buckets[1].amount, 0);
      expect(buckets[2].amount, 200);
    });

    test('all-time with no sessions returns empty', () {
      final buckets = StatsBucketBuilder.build(
        range: const StatsDateRange(granularity: BucketGranularity.year),
        sessions: const [],
      );
      expect(buckets, isEmpty);
    });

    test('sessions outside the range are not counted', () {
      final range = StatsDateRange(
        start: DateTime(2026, 5, 10),
        end: DateTime(2026, 5, 11),
        granularity: BucketGranularity.day,
      );
      final sessions = [
        _session(endTime: DateTime(2026, 5, 9, 23), amount: 100),
        _session(endTime: DateTime(2026, 5, 10, 5), amount: 200),
        _session(endTime: DateTime(2026, 5, 11, 0), amount: 300),
      ];
      final buckets = StatsBucketBuilder.build(
        range: range,
        sessions: sessions,
      );
      expect(buckets.length, 1);
      expect(buckets[0].amount, 200);
    });
  });
}
