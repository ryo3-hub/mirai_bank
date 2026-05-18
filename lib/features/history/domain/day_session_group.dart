import 'work_session.dart';

class DaySessionGroup {
  const DaySessionGroup({
    required this.date,
    required this.sessions,
  });

  final DateTime date;
  final List<WorkSession> sessions;

  int get totalAmount =>
      sessions.fold<int>(0, (sum, s) => sum + s.amount);

  int get totalDurationSec =>
      sessions.fold<int>(0, (sum, s) => sum + s.durationSec);

  static List<DaySessionGroup> groupByDay(List<WorkSession> sessions) {
    final buckets = <DateTime, List<WorkSession>>{};
    for (final s in sessions) {
      final key =
          DateTime(s.endTime.year, s.endTime.month, s.endTime.day);
      buckets.putIfAbsent(key, () => []).add(s);
    }
    for (final list in buckets.values) {
      list.sort((a, b) => b.endTime.compareTo(a.endTime));
    }
    final entries = buckets.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return [
      for (final e in entries)
        DaySessionGroup(date: e.key, sessions: e.value),
    ];
  }
}
