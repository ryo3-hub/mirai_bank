import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/history/application/summary_providers.dart';

void main() {
  group('summaryDateRange', () {
    test('all returns unbounded range', () {
      final range = summaryDateRange(SummaryPeriod.all);
      expect(range.start, isNull);
      expect(range.end, isNull);
      expect(range.includes(DateTime(1990)), isTrue);
      expect(range.includes(DateTime(2099)), isTrue);
    });

    test('today range covers the full local day', () {
      final now = DateTime(2026, 5, 17, 14, 30);
      final range = summaryDateRange(SummaryPeriod.today, now: now);
      expect(range.start, DateTime(2026, 5, 17, 0, 0, 0));
      expect(range.includes(DateTime(2026, 5, 17, 0, 0, 0)), isTrue);
      expect(range.includes(DateTime(2026, 5, 17, 23, 59, 59)), isTrue);
      expect(range.includes(DateTime(2026, 5, 16, 23, 59, 59)), isFalse);
      expect(range.includes(DateTime(2026, 5, 18, 0, 0, 1)), isFalse);
    });

    test('week range covers Monday to Sunday', () {
      // 2026-05-17 is a Sunday
      final sunday = DateTime(2026, 5, 17, 14);
      final range = summaryDateRange(SummaryPeriod.week, now: sunday);
      expect(range.start, DateTime(2026, 5, 11)); // Monday
      expect(range.includes(DateTime(2026, 5, 11)), isTrue);
      expect(range.includes(DateTime(2026, 5, 17, 23, 59, 59)), isTrue);
      expect(range.includes(DateTime(2026, 5, 10, 23, 59, 59)), isFalse);
      expect(range.includes(DateTime(2026, 5, 18)), isFalse);
    });

    test('week range when today is Monday', () {
      final monday = DateTime(2026, 5, 11, 10);
      final range = summaryDateRange(SummaryPeriod.week, now: monday);
      expect(range.start, DateTime(2026, 5, 11));
      expect(range.includes(DateTime(2026, 5, 11)), isTrue);
      expect(range.includes(DateTime(2026, 5, 17, 23, 59, 59)), isTrue);
      expect(range.includes(DateTime(2026, 5, 18)), isFalse);
    });

    test('month range covers the full calendar month', () {
      final mid = DateTime(2026, 5, 17);
      final range = summaryDateRange(SummaryPeriod.month, now: mid);
      expect(range.start, DateTime(2026, 5, 1));
      expect(range.includes(DateTime(2026, 5, 1)), isTrue);
      expect(range.includes(DateTime(2026, 5, 31, 23, 59, 59)), isTrue);
      expect(range.includes(DateTime(2026, 4, 30, 23, 59, 59)), isFalse);
      expect(range.includes(DateTime(2026, 6, 1)), isFalse);
    });

    test('month range handles February in leap year', () {
      final leap = DateTime(2024, 2, 10);
      final range = summaryDateRange(SummaryPeriod.month, now: leap);
      expect(range.start, DateTime(2024, 2, 1));
      expect(range.includes(DateTime(2024, 2, 29, 23, 59, 59)), isTrue);
      expect(range.includes(DateTime(2024, 3, 1)), isFalse);
    });
  });
}
