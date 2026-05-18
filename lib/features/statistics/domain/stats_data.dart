import '../../category/domain/category.dart';
import '../../history/domain/work_session.dart';

enum BucketGranularity { day, month, year }

class StatsDateRange {
  const StatsDateRange({
    this.start,
    this.end,
    required this.granularity,
  });

  final DateTime? start;
  final DateTime? end;
  final BucketGranularity granularity;
}

class StatsBucket {
  const StatsBucket({
    required this.start,
    required this.end,
    required this.amount,
    required this.label,
  });

  final DateTime start;
  final DateTime end;
  final int amount;
  final String label;
}

class CategoryShare {
  const CategoryShare({
    required this.category,
    required this.amount,
    required this.durationSec,
    required this.ratio,
  });

  final Category category;
  final int amount;
  final int durationSec;
  final double ratio;
}

class PeriodStats {
  const PeriodStats({
    required this.totalAmount,
    required this.totalDurationSec,
    required this.buckets,
    required this.granularity,
    required this.breakdown,
    this.topCategory,
  });

  static const PeriodStats empty = PeriodStats(
    totalAmount: 0,
    totalDurationSec: 0,
    buckets: [],
    granularity: BucketGranularity.day,
    breakdown: [],
  );

  final int totalAmount;
  final int totalDurationSec;
  final List<StatsBucket> buckets;
  final BucketGranularity granularity;
  final List<CategoryShare> breakdown;
  final Category? topCategory;
}

class StatsBucketBuilder {
  const StatsBucketBuilder._();

  static List<StatsBucket> build({
    required StatsDateRange range,
    required List<WorkSession> sessions,
  }) {
    var start = range.start;
    var end = range.end;

    if (start == null || end == null) {
      if (sessions.isEmpty) return const [];
      var min = sessions.first.endTime;
      var max = sessions.first.endTime;
      for (final s in sessions) {
        if (s.endTime.isBefore(min)) min = s.endTime;
        if (s.endTime.isAfter(max)) max = s.endTime;
      }
      switch (range.granularity) {
        case BucketGranularity.day:
          start = DateTime(min.year, min.month, min.day);
          end = DateTime(max.year, max.month, max.day).add(
            const Duration(days: 1),
          );
        case BucketGranularity.month:
          start = DateTime(min.year, min.month);
          end = DateTime(max.year, max.month + 1);
        case BucketGranularity.year:
          start = DateTime(min.year);
          end = DateTime(max.year + 1);
      }
    }

    final result = <StatsBucket>[];
    var current = _normalize(start, range.granularity);
    while (current.isBefore(end)) {
      final next = _advance(current, range.granularity);
      var amount = 0;
      for (final s in sessions) {
        if (!s.endTime.isBefore(current) && s.endTime.isBefore(next)) {
          amount += s.amount;
        }
      }
      result.add(
        StatsBucket(
          start: current,
          end: next,
          amount: amount,
          label: _formatLabel(current, range.granularity),
        ),
      );
      current = next;
    }
    return result;
  }

  static DateTime _normalize(DateTime t, BucketGranularity g) {
    switch (g) {
      case BucketGranularity.day:
        return DateTime(t.year, t.month, t.day);
      case BucketGranularity.month:
        return DateTime(t.year, t.month);
      case BucketGranularity.year:
        return DateTime(t.year);
    }
  }

  static DateTime _advance(DateTime t, BucketGranularity g) {
    switch (g) {
      case BucketGranularity.day:
        return t.add(const Duration(days: 1));
      case BucketGranularity.month:
        return DateTime(t.year, t.month + 1);
      case BucketGranularity.year:
        return DateTime(t.year + 1);
    }
  }

  static String _formatLabel(DateTime t, BucketGranularity g) {
    switch (g) {
      case BucketGranularity.day:
        return '${t.month}/${t.day}';
      case BucketGranularity.month:
        return '${t.month}月';
      case BucketGranularity.year:
        return '${t.year}';
    }
  }
}
