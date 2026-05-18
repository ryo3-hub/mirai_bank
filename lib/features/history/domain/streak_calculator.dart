import 'work_session.dart';

class StreakCalculator {
  const StreakCalculator._();

  static const List<int> milestones = [3, 7, 30, 100, 365];

  static DateTime dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

  /// Counts consecutive days with at least one session, ending at today
  /// (or yesterday if today has no session yet — the streak isn't broken
  /// just because the user hasn't studied today yet).
  static int compute(List<WorkSession> sessions, {DateTime? now}) {
    if (sessions.isEmpty) return 0;
    final today = dateOnly(now ?? DateTime.now());
    final activeDays = sessions.map((s) => dateOnly(s.endTime)).toSet();

    var cursor = today;
    if (!activeDays.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!activeDays.contains(cursor)) return 0;
    }
    var streak = 0;
    while (activeDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Returns the milestone value if today is the first session-day
  /// and the resulting streak matches a milestone; otherwise null.
  static int? milestoneIfFirstToday(
    List<WorkSession> sessionsIncludingNew, {
    DateTime? now,
  }) {
    final today = dateOnly(now ?? DateTime.now());
    final todaySessions = sessionsIncludingNew
        .where((s) => dateOnly(s.endTime) == today)
        .length;
    if (todaySessions != 1) return null;
    final streak = compute(sessionsIncludingNew, now: now);
    return milestones.contains(streak) ? streak : null;
  }
}
