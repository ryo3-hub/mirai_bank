import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../category/application/category_providers.dart';
import '../domain/session_summary.dart';
import 'work_session_providers.dart';

part 'summary_providers.g.dart';

enum SummaryPeriod {
  all('全期間'),
  month('今月'),
  week('今週'),
  today('今日');

  const SummaryPeriod(this.label);

  final String label;
}

class SummaryDateRange {
  const SummaryDateRange({this.start, this.end});

  final DateTime? start;
  final DateTime? end;

  bool includes(DateTime time) {
    if (start != null && time.isBefore(start!)) return false;
    if (end != null && time.isAfter(end!)) return false;
    return true;
  }
}

SummaryDateRange summaryDateRange(SummaryPeriod period, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  switch (period) {
    case SummaryPeriod.all:
      return const SummaryDateRange();
    case SummaryPeriod.today:
      final start = DateTime(ref.year, ref.month, ref.day);
      final end = DateTime(ref.year, ref.month, ref.day, 23, 59, 59, 999);
      return SummaryDateRange(start: start, end: end);
    case SummaryPeriod.week:
      final today = DateTime(ref.year, ref.month, ref.day);
      final daysSinceMonday = today.weekday - DateTime.monday;
      final monday = today.subtract(Duration(days: daysSinceMonday));
      final sunday = monday.add(const Duration(days: 6));
      final end =
          DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59, 999);
      return SummaryDateRange(start: monday, end: end);
    case SummaryPeriod.month:
      final start = DateTime(ref.year, ref.month, 1);
      final lastDay = DateTime(ref.year, ref.month + 1, 0).day;
      final end =
          DateTime(ref.year, ref.month, lastDay, 23, 59, 59, 999);
      return SummaryDateRange(start: start, end: end);
  }
}

@riverpod
Stream<SessionSummary> summary(Ref ref, SummaryPeriod period) {
  return ref.watch(workSessionRepositoryProvider).watchAll().map((sessions) {
    final range = summaryDateRange(period);
    var amount = 0;
    var duration = 0;
    for (final s in sessions) {
      if (!range.includes(s.endTime)) continue;
      amount += s.amount;
      duration += s.durationSec;
    }
    return SessionSummary(amount: amount, durationSec: duration);
  });
}

@riverpod
Stream<List<CategoryBreakdownItem>> categoryBreakdown(
  Ref ref,
  SummaryPeriod period,
) async* {
  final sessionRepo = ref.watch(workSessionRepositoryProvider);
  final categoryRepo = ref.watch(categoryRepositoryProvider);

  await for (final sessions in sessionRepo.watchAll()) {
    final categories = await categoryRepo.fetchAll();
    final categoryMap = {for (final c in categories) c.id: c};
    final range = summaryDateRange(period);

    final byId = <String, ({int amount, int duration})>{};
    for (final s in sessions) {
      if (!range.includes(s.endTime)) continue;
      final existing = byId[s.categoryId] ?? (amount: 0, duration: 0);
      byId[s.categoryId] = (
        amount: existing.amount + s.amount,
        duration: existing.duration + s.durationSec,
      );
    }

    final items = <CategoryBreakdownItem>[];
    for (final entry in byId.entries) {
      final category = categoryMap[entry.key];
      if (category == null) continue;
      items.add(
        CategoryBreakdownItem(
          category: category,
          amount: entry.value.amount,
          durationSec: entry.value.duration,
        ),
      );
    }
    items.sort((a, b) => b.amount.compareTo(a.amount));
    yield items;
  }
}
