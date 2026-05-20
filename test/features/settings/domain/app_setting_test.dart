import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/settings/domain/app_setting.dart';

void main() {
  group('AppSetting.reminderTimeOfDay', () {
    test('parses HH:mm', () {
      const s = AppSetting(
        reminderEnabled: true,
        reminderTime: '09:30',
        achievementNotificationEnabled: true,
      );
      expect(s.reminderTimeOfDay, const TimeOfDay(hour: 9, minute: 30));
    });

    test('falls back to 21:00 on invalid input', () {
      const s = AppSetting(
        reminderEnabled: true,
        reminderTime: 'invalid',
        achievementNotificationEnabled: true,
      );
      expect(s.reminderTimeOfDay, const TimeOfDay(hour: 21, minute: 0));
    });

    test('clamps out-of-range hours and minutes', () {
      const s = AppSetting(
        reminderEnabled: true,
        reminderTime: '28:99',
        achievementNotificationEnabled: true,
      );
      expect(s.reminderTimeOfDay, const TimeOfDay(hour: 23, minute: 59));
    });
  });

  group('AppSetting.formatTime', () {
    test('formats with zero padding', () {
      expect(
        AppSetting.formatTime(const TimeOfDay(hour: 7, minute: 5)),
        '07:05',
      );
      expect(
        AppSetting.formatTime(const TimeOfDay(hour: 21, minute: 0)),
        '21:00',
      );
    });
  });

  group('AppSetting.copyWith', () {
    test('overrides specified fields and preserves the rest', () {
      const base = AppSetting.defaults;
      final updated = base.copyWith(reminderEnabled: true, reminderTime: '08:00');
      expect(updated.reminderEnabled, isTrue);
      expect(updated.reminderTime, '08:00');
      expect(
        updated.achievementNotificationEnabled,
        base.achievementNotificationEnabled,
      );
    });
  });
}
