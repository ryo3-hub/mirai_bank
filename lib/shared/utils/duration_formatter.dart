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

  /// Human-readable duration in Japanese including seconds, e.g.
  /// "1時間30分45秒", "30分5秒", "45秒". 履歴で秒単位まで見せたいとき用。
  /// 0 の単位はスキップする（例: 3605秒 → "1時間5秒"）。
  static String hourMinuteSecond(int totalSeconds) {
    final s = totalSeconds < 0 ? 0 : totalSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    final parts = <String>[];
    if (h > 0) parts.add('$h時間');
    if (m > 0) parts.add('$m分');
    if (sec > 0 || parts.isEmpty) parts.add('$sec秒');
    return parts.join();
  }
}
