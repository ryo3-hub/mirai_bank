import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/history/application/work_session_providers.dart';
import '../../features/settings/application/setting_providers.dart';
import '../../features/timer/application/timer_providers.dart';
import 'notification_service.dart';

/// 日次リマインダー通知のスケジュール状態を、アプリ設定と実行時状態
/// （タイマー稼働 / 今日のセッション有無）から再評価して整合させる
/// コーディネーター（issue #178）。
///
/// 設計：
/// - `refresh()` を **状態が変わったとき** に呼ぶだけで、内部で
///   `NotificationService.scheduleDailyReminder` を `skipToday` 込みで叩く
/// - `NotificationService.scheduleDailyReminder` は 14 日先までの one-shot を
///   再スケジュールする（同 ID は上書き）。よって呼びすぎても副作用は無い
///
/// 呼ばれる場所：
/// - `main.dart` bootstrap（アプリ起動）
/// - `SettingController` の reminder ON/OFF / 時刻変更 / 曜日変更
/// - `TimerController.start` / `stop`
class ReminderScheduler {
  ReminderScheduler(this._ref);

  final Ref _ref;

  Future<void> refresh() async {
    try {
      final setting = await _ref.read(settingRepositoryProvider).fetch();
      if (!setting.reminderEnabled || setting.reminderWeekdays.isEmpty) {
        await NotificationService.instance.cancelDailyReminder();
        return;
      }
      final skipToday = await _isTodayEngaged();
      await NotificationService.instance.scheduleDailyReminder(
        setting.reminderTimeOfDay,
        weekdays: setting.reminderWeekdays,
        skipToday: skipToday,
      );
    } catch (e, st) {
      debugPrint('ReminderScheduler.refresh failed: $e\n$st');
    }
  }

  /// 「今日はリマインダーを送らない方が良い状況か？」を判定する。
  /// - タイマー計測中（ActiveTimer がある）
  /// - 今日すでにセッションが 1 件以上ある（金額計上された履歴）
  Future<bool> _isTodayEngaged() async {
    final timer = await _ref.read(activeTimerRepositoryProvider).fetch();
    if (timer != null) return true;
    return _ref
        .read(workSessionRepositoryProvider)
        .hasSessionOn(DateTime.now());
  }
}

/// `ReminderScheduler` をアプリ全体で共有するための Provider。
/// 状態を持たないので keepAlive。
final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return ReminderScheduler(ref);
});
