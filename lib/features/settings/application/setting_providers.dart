import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/database/database_provider.dart';
import '../../../shared/notification/notification_service.dart';
import '../domain/app_setting.dart';
import '../infrastructure/setting_repository.dart';
import '../infrastructure/setting_repository_impl.dart';

part 'setting_providers.g.dart';

@Riverpod(keepAlive: true)
SettingRepository settingRepository(Ref ref) {
  return SettingRepositoryImpl(ref.watch(appDatabaseProvider));
}

@riverpod
Stream<AppSetting> appSetting(Ref ref) {
  return ref.watch(settingRepositoryProvider).watch();
}

@riverpod
class SettingController extends _$SettingController {
  @override
  void build() {}

  Future<void> setReminderEnabled({
    required bool enabled,
    required TimeOfDay time,
    required Set<int> weekdays,
  }) async {
    if (enabled) {
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted) {
        await ref.read(settingRepositoryProvider).update(reminderEnabled: false);
        throw StateError('通知の許可が得られませんでした');
      }
      await NotificationService.instance.scheduleDailyReminder(
        time,
        weekdays: weekdays,
      );
    } else {
      await NotificationService.instance.cancelDailyReminder();
    }
    await ref
        .read(settingRepositoryProvider)
        .update(reminderEnabled: enabled);
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    final formatted = AppSetting.formatTime(time);
    await ref
        .read(settingRepositoryProvider)
        .update(reminderTime: formatted);
    final current = await ref.read(settingRepositoryProvider).fetch();
    if (current.reminderEnabled) {
      await NotificationService.instance.scheduleDailyReminder(
        time,
        weekdays: current.reminderWeekdays,
      );
    }
  }

  Future<void> setReminderWeekdays(Set<int> weekdays) async {
    await ref.read(settingRepositoryProvider).update(reminderWeekdays: weekdays);
    final current = await ref.read(settingRepositoryProvider).fetch();
    if (current.reminderEnabled) {
      await NotificationService.instance.scheduleDailyReminder(
        current.reminderTimeOfDay,
        weekdays: weekdays,
      );
    }
  }

  Future<void> setAchievementNotificationEnabled(bool enabled) async {
    await ref
        .read(settingRepositoryProvider)
        .update(achievementNotificationEnabled: enabled);
  }
}
