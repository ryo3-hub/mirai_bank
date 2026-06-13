import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/statistics/application/stats_providers.dart';
import 'package:mirai_bank/features/statistics/domain/stats_data.dart';

void main() {
  group('statsDateRange', () {
    test('week = last 7 days, day buckets', () {
      final now = DateTime(2026, 5, 17, 14);
      final r = statsDateRange(StatsPeriod.week, now: now);
      expect(r.start, DateTime(2026, 5, 11));
      expect(r.end, DateTime(2026, 5, 18));
      expect(r.granularity, BucketGranularity.day);
    });

    test('month = current calendar month, day buckets', () {
      final now = DateTime(2026, 5, 17);
      final r = statsDateRange(StatsPeriod.month, now: now);
      expect(r.start, DateTime(2026, 5, 1));
      expect(r.end, DateTime(2026, 6, 1));
      expect(r.granularity, BucketGranularity.day);
    });

    test('year = current calendar year, month buckets', () {
      final now = DateTime(2026, 5, 17);
      final r = statsDateRange(StatsPeriod.year, now: now);
      expect(r.start, DateTime(2026, 1, 1));
      expect(r.end, DateTime(2027, 1, 1));
      expect(r.granularity, BucketGranularity.month);
    });

    test('all = unbounded, month buckets', () {
      // 仕様（docs/specs/04_statistics.md）：全期間は月バケット（issue #201）
      final r = statsDateRange(StatsPeriod.all);
      expect(r.start, isNull);
      expect(r.end, isNull);
      expect(r.granularity, BucketGranularity.month);
    });
  });
}
