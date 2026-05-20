import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/settings/domain/app_setting.dart';

void main() {
  group('AppSetting.reminderTimeOfDay', () {
    test('parses HH:mm', () {
      const s = AppSetting(
        reminderEnabled: true,
        reminderTime: '09:30',
        reminderWeekdays: AppSetting.allWeekdays,
        achievementNotificationEnabled: true,
      );
      expect(s.reminderTimeOfDay, const TimeOfDay(hour: 9, minute: 30));
    });

    test('falls back to 21:00 on invalid input', () {
      const s = AppSetting(
        reminderEnabled: true,
        reminderTime: 'invalid',
        reminderWeekdays: AppSetting.allWeekdays,
        achievementNotificationEnabled: true,
      );
      expect(s.reminderTimeOfDay, const TimeOfDay(hour: 21, minute: 0));
    });

    test('clamps out-of-range hours and minutes', () {
      const s = AppSetting(
        reminderEnabled: true,
        reminderTime: '28:99',
        reminderWeekdays: AppSetting.allWeekdays,
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
      expect(updated.reminderWeekdays, base.reminderWeekdays);
      expect(
        updated.achievementNotificationEnabled,
        base.achievementNotificationEnabled,
      );
    });
  });

  group('AppSetting.parseWeekdays', () {
    test('parses CSV into set', () {
      expect(AppSetting.parseWeekdays('1,2,3,4,5,6,7'), AppSetting.allWeekdays);
      expect(AppSetting.parseWeekdays('1,3,5'), {1, 3, 5});
      expect(AppSetting.parseWeekdays(' 2 , 4 '), {2, 4});
    });

    test('returns empty set for null / empty / whitespace', () {
      expect(AppSetting.parseWeekdays(null), isEmpty);
      expect(AppSetting.parseWeekdays(''), isEmpty);
      expect(AppSetting.parseWeekdays('  '), isEmpty);
    });

    test('skips invalid values', () {
      expect(AppSetting.parseWeekdays('0,1,8,abc,3'), {1, 3});
    });
  });

  group('AppSetting.formatWeekdays', () {
    test('sorts and joins with comma', () {
      expect(AppSetting.formatWeekdays({3, 1, 5}), '1,3,5');
      expect(AppSetting.formatWeekdays(AppSetting.allWeekdays), '1,2,3,4,5,6,7');
      expect(AppSetting.formatWeekdays({}), '');
    });
  });
}
