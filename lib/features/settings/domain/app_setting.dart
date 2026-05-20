import 'package:flutter/material.dart' show TimeOfDay;

class AppSetting {
  const AppSetting({
    required this.reminderEnabled,
    required this.reminderTime,
    required this.reminderWeekdays,
    required this.achievementNotificationEnabled,
  });

  static const AppSetting defaults = AppSetting(
    reminderEnabled: false,
    reminderTime: '21:00',
    reminderWeekdays: allWeekdays,
    achievementNotificationEnabled: true,
  );

  /// DateTime.weekday の値（1=月 .. 7=日）の集合。デフォルトは毎日。
  static const Set<int> allWeekdays = {1, 2, 3, 4, 5, 6, 7};

  final bool reminderEnabled;
  final String reminderTime; // 'HH:mm'
  final Set<int> reminderWeekdays;
  final bool achievementNotificationEnabled;

  TimeOfDay get reminderTimeOfDay {
    final parts = reminderTime.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 21, minute: 0);
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return const TimeOfDay(hour: 21, minute: 0);
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  static String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  /// CSV 文字列を曜日集合に変換する。
  /// 不正な値はスキップ、空文字 / null は空集合を返す。
  static Set<int> parseWeekdays(String? csv) {
    if (csv == null || csv.trim().isEmpty) return const <int>{};
    final result = <int>{};
    for (final raw in csv.split(',')) {
      final v = int.tryParse(raw.trim());
      if (v != null && v >= 1 && v <= 7) result.add(v);
    }
    return result;
  }

  /// 曜日集合をソートして CSV 文字列に変換する。
  static String formatWeekdays(Set<int> weekdays) {
    final sorted = weekdays.toList()..sort();
    return sorted.join(',');
  }

  AppSetting copyWith({
    bool? reminderEnabled,
    String? reminderTime,
    Set<int>? reminderWeekdays,
    bool? achievementNotificationEnabled,
  }) {
    return AppSetting(
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderWeekdays: reminderWeekdays ?? this.reminderWeekdays,
      achievementNotificationEnabled:
          achievementNotificationEnabled ?? this.achievementNotificationEnabled,
    );
  }
}
