import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/day_session_group.dart';
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

@riverpod
Stream<List<DaySessionGroup>> groupedSessionList(Ref ref) {
  return ref
      .watch(workSessionRepositoryProvider)
      .watchAll()
      .map(DaySessionGroup.groupByDay);
}
