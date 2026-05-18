class DurationFormatter {
  const DurationFormatter._();

  static String hms(int totalSeconds) {
    final s = totalSeconds < 0 ? 0 : totalSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${sec.toString().padLeft(2, '0')}';
  }

  /// Human-readable duration in Japanese, e.g. "2時間30分", "45分", "0分".
  /// Seconds are floored to whole minutes.
  static String hourMinute(int totalSeconds) {
    final s = totalSeconds < 0 ? 0 : totalSeconds;
    final totalMinutes = s ~/ 60;
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return '$m分';
    if (m == 0) return '$h時間';
    return '$h時間$m分';
  }
}
