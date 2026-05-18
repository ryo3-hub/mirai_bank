import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/work_session.dart';
import 'work_session_providers.dart';

part 'calendar_providers.g.dart';

DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

@riverpod
Stream<Map<DateTime, int>> dailyAmountMap(Ref ref, DateTime month) {
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 1);
  return ref.watch(workSessionRepositoryProvider).watchAll().map((sessions) {
    final map = <DateTime, int>{};
    for (final s in sessions) {
      final endDate = _dateOnly(s.endTime);
      if (endDate.isBefore(start) || !endDate.isBefore(end)) continue;
      map[endDate] = (map[endDate] ?? 0) + s.amount;
    }
    return map;
  });
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
