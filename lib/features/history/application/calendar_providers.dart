import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/daily_stats.dart';
import '../domain/work_session.dart';
import 'work_session_providers.dart';

part 'calendar_providers.g.dart';

DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

/// 月内のセッション一覧から、日付ごとの集計（金額 + 主カテゴリ）を作る。
///
/// テストしやすいよう純粋関数として切り出している。
Map<DateTime, DailyStats> computeDailyStatsMap({
  required Iterable<WorkSession> sessions,
  required DateTime month,
}) {
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 1);
  // day -> categoryId -> amount（categoryId の挿入順を維持するため
  // LinkedHashMap を明示的に使う）
  final perDayPerCategory = <DateTime, Map<String, int>>{};
  for (final s in sessions) {
    final endDate = _dateOnly(s.endTime);
    if (endDate.isBefore(start) || !endDate.isBefore(end)) continue;
    final perCategory =
        perDayPerCategory.putIfAbsent(endDate, () => <String, int>{});
    perCategory[s.categoryId] = (perCategory[s.categoryId] ?? 0) + s.amount;
  }
  return perDayPerCategory.map((day, perCategory) {
    var dominantId = perCategory.keys.first;
    var dominantAmount = perCategory[dominantId]!;
    var total = 0;
    perCategory.forEach((id, amt) {
      total += amt;
      // 同点のときは「最初に出現した方」を優先（厳密に大なりで比較）。
      if (amt > dominantAmount) {
        dominantAmount = amt;
        dominantId = id;
      }
    });
    return MapEntry(
      day,
      DailyStats(amount: total, dominantCategoryId: dominantId),
    );
  });
}

@riverpod
Stream<Map<DateTime, DailyStats>> dailyStatsMap(Ref ref, DateTime month) {
  return ref.watch(workSessionRepositoryProvider).watchAll().map(
        (sessions) => computeDailyStatsMap(sessions: sessions, month: month),
      );
}

@riverpod
Stream<List<WorkSession>> sessionsOnDay(Ref ref, DateTime date) {
  final target = _dateOnly(date);
  final nextDay = target.add(const Duration(days: 1));
  return ref.watch(workSessionRepositoryProvider).watchAll().map((sessions) {
    final filtered = sessions.where((s) {
      return !s.endTime.isBefore(target) && s.endTime.isBefore(nextDay);
    }).toList();
    filtered.sort((a, b) => a.endTime.compareTo(b.endTime));
    return filtered;
  });
}
