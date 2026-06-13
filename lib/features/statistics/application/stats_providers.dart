import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../category/application/category_providers.dart';
import '../../history/application/work_session_providers.dart';
import '../domain/stats_data.dart';

part 'stats_providers.g.dart';

enum StatsPeriod {
  all('全期間'),
  year('今年'),
  month('今月'),
  week('週');

  const StatsPeriod(this.label);

  final String label;
}

StatsDateRange statsDateRange(StatsPeriod period, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  switch (period) {
    case StatsPeriod.week:
      final start = today.subtract(const Duration(days: 6));
      final end = today.add(const Duration(days: 1));
      return StatsDateRange(
        start: start,
        end: end,
        granularity: BucketGranularity.day,
      );
    case StatsPeriod.month:
      final start = DateTime(ref.year, ref.month, 1);
      final end = DateTime(ref.year, ref.month + 1, 1);
      return StatsDateRange(
        start: start,
        end: end,
        granularity: BucketGranularity.day,
      );
    case StatsPeriod.year:
      final start = DateTime(ref.year, 1, 1);
      final end = DateTime(ref.year + 1, 1, 1);
      return StatsDateRange(
        start: start,
        end: end,
        granularity: BucketGranularity.month,
      );
    case StatsPeriod.all:
      return const StatsDateRange(granularity: BucketGranularity.year);
  }
}

@riverpod
Stream<PeriodStats> periodStats(Ref ref, StatsPeriod period) async* {
  final sessionRepo = ref.watch(workSessionRepositoryProvider);
  final categoryRepo = ref.watch(categoryRepositoryProvider);

  await for (final sessions in sessionRepo.watchAll()) {
    // 削除済みカテゴリのセッションも内訳に含める（issue #190）。除外すると
    // 「期間サマリの合計 ≠ 内訳の合計」になり、円グラフの％も 100% に
    // ならない。表示側で「（削除済み）」を付けて区別する。
    final categories = await categoryRepo.fetchAllIncludingDeleted();
    final categoryMap = {for (final c in categories) c.id: c};
    final range = statsDateRange(period);

    final inRange = sessions.where((s) {
      if (range.start != null && s.endTime.isBefore(range.start!)) return false;
      if (range.end != null && !s.endTime.isBefore(range.end!)) return false;
      return true;
    }).toList();

    final buckets = StatsBucketBuilder.build(
      range: range,
      sessions: inRange,
    );

    final amountByCategory = <String, int>{};
    final durationByCategory = <String, int>{};
    var totalAmount = 0;
    var totalDuration = 0;
    for (final s in inRange) {
      totalAmount += s.amount;
      totalDuration += s.durationSec;
      amountByCategory[s.categoryId] =
          (amountByCategory[s.categoryId] ?? 0) + s.amount;
      durationByCategory[s.categoryId] =
          (durationByCategory[s.categoryId] ?? 0) + s.durationSec;
    }

    final breakdown = <CategoryShare>[];
    for (final entry in amountByCategory.entries) {
      final category = categoryMap[entry.key];
      if (category == null) continue;
      final amount = entry.value;
      final ratio = totalAmount == 0 ? 0.0 : amount / totalAmount;
      breakdown.add(
        CategoryShare(
          category: category,
          amount: amount,
          durationSec: durationByCategory[entry.key] ?? 0,
          ratio: ratio,
        ),
      );
    }
    breakdown.sort((a, b) => b.amount.compareTo(a.amount));

    yield PeriodStats(
      totalAmount: totalAmount,
      totalDurationSec: totalDuration,
      buckets: buckets,
      granularity: range.granularity,
      breakdown: breakdown,
      topCategory: breakdown.isEmpty ? null : breakdown.first.category,
    );
  }
}
