import 'package:flutter/material.dart' show TimeOfDay;

class AppSetting {
  const AppSetting({
    required this.reminderEnabled,
    required this.reminderTime,
    required this.achievementNotificationEnabled,
  });

  static const AppSetting defaults = AppSetting(
    reminderEnabled: false,
    reminderTime: '21:00',
    achievementNotificationEnabled: true,
  );

  final bool reminderEnabled;
  final String reminderTime; // 'HH:mm'
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

  AppSetting copyWith({
    bool? reminderEnabled,
    String? reminderTime,
    bool? achievementNotificationEnabled,
  }) {
    return AppSetting(
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      achievementNotificationEnabled:
          achievementNotificationEnabled ?? this.achievementNotificationEnabled,
    );
  }
}
