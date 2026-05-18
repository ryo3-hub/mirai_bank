import '../domain/app_setting.dart';

abstract interface class SettingRepository {
  Stream<AppSetting> watch();

  Future<AppSetting> fetch();

  Future<void> update({
    bool? reminderEnabled,
    String? reminderTime,
    bool? achievementNotificationEnabled,
  });
}
