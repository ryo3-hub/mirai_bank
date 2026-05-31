import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/database/database_provider.dart';
import '../../../shared/notification/notification_service.dart';
import '../../../shared/notification/reminder_scheduler.dart';
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
    }
    await ref
        .read(settingRepositoryProvider)
        .update(reminderEnabled: enabled);
    // ReminderScheduler が現在の設定と状態を読み直して、必要なら
    // skipToday=true で再スケジュールする（issue #178）。
    await ref.read(reminderSchedulerProvider).refresh();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    final formatted = AppSetting.formatTime(time);
    await ref
        .read(settingRepositoryProvider)
        .update(reminderTime: formatted);
    await ref.read(reminderSchedulerProvider).refresh();
  }

  Future<void> setReminderWeekdays(Set<int> weekdays) async {
    await ref.read(settingRepositoryProvider).update(reminderWeekdays: weekdays);
    await ref.read(reminderSchedulerProvider).refresh();
  }

  Future<void> setAchievementNotificationEnabled(bool enabled) async {
    await ref
        .read(settingRepositoryProvider)
        .update(achievementNotificationEnabled: enabled);
  }
}
