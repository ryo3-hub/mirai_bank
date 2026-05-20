import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/day_session_group.dart';
import '../domain/limited_session_groups.dart';
import '../domain/work_session.dart';
import 'work_session_providers.dart';

part 'session_list_providers.g.dart';

@riverpod
Stream<List<WorkSession>> sessionList(Ref ref) {
  return ref.watch(workSessionRepositoryProvider).watchAll().map((sessions) {
    final sorted = [...sessions]
      ..sort((a, b) => b.endTime.compareTo(a.endTime));
    return sorted;
  });
}

/// 履歴一覧用の表示データ。最新 [LimitedSessionGroups.displayLimit] 件に
/// 絞ってから日付グループ化する。総件数も同梱して、画面側で「N 件以上」
/// の告知に使えるようにする。
@riverpod
Stream<LimitedSessionGroups> groupedSessionList(Ref ref) {
  return ref.watch(workSessionRepositoryProvider).watchAll().map((sessions) {
    final sortedDesc = [...sessions]
      ..sort((a, b) => b.endTime.compareTo(a.endTime));
    final visible = sortedDesc.take(LimitedSessionGroups.displayLimit).toList();
    final groups = DaySessionGroup.groupByDay(visible);
    return LimitedSessionGroups(
      groups: groups,
      totalCount: sortedDesc.length,
      displayedCount: visible.length,
    );
  });
}
