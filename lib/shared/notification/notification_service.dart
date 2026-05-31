import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_messages.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _timerNotificationId = 1001;
  static const int _timerCompletionNotificationId = 1010;
  // Legacy single-id reminder（v1 互換、cancelDailyReminder で清掃する）。
  static const int _legacyReminderNotificationId = 1002;
  // 曜日ごとに別 ID を使う：基底 + DateTime.weekday (1..7)
  static const int _reminderNotificationIdBase = 1100;
  static const int _achievementNotificationIdBase = 2000;
  static const int _streakNotificationIdBase = 3000;

  static const String _timerChannelId = 'timer_ongoing';
  static const String _timerChannelName = 'タイマー';
  static const String _timerChannelDescription = '作業計測中の常駐通知';

  static const String _reminderChannelId = 'reminder';
  static const String _reminderChannelName = 'リマインダー';
  static const String _reminderChannelDescription = '学習リマインダー';

  static const String _achievementChannelId = 'achievement';
  static const String _achievementChannelName = '達成';
  static const String _achievementChannelDescription = '目標達成・節目通知';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));
      } catch (_) {
        // fall back to UTC if Asia/Tokyo isn't available for some reason
      }
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _plugin.initialize(initSettings);

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _timerChannelId,
          _timerChannelName,
          description: _timerChannelDescription,
          importance: Importance.low,
        ),
      );
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _reminderChannelId,
          _reminderChannelName,
          description: _reminderChannelDescription,
          importance: Importance.defaultImportance,
        ),
      );
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _achievementChannelId,
          _achievementChannelName,
          description: _achievementChannelDescription,
          importance: Importance.high,
        ),
      );
      _initialized = true;
    } catch (e, st) {
      debugPrint('NotificationService.init failed: $e\n$st');
    }
  }

  Future<bool> requestPermissions() async {
    if (!_initialized) return false;
    try {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final iosOk = await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final androidOk =
          await android?.requestNotificationsPermission() ?? true;
      return iosOk && androidOk;
    } catch (e, st) {
      debugPrint('NotificationService.requestPermissions failed: $e\n$st');
      return false;
    }
  }

  Future<void> showOngoingTimer({
    required String categoryName,
    String? subtitle,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        _timerNotificationId,
        '計測中: $categoryName',
        subtitle,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _timerChannelId,
            _timerChannelName,
            channelDescription: _timerChannelDescription,
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            showWhen: false,
            onlyAlertOnce: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentSound: false,
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('showOngoingTimer failed: $e\n$st');
    }
  }

  Future<void> cancelOngoingTimer() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_timerNotificationId);
    } catch (e, st) {
      debugPrint('cancelOngoingTimer failed: $e\n$st');
    }
  }

  /// カウントダウンタイマー完了時の push 通知を [fireAt] にスケジュールする。
  /// 既存のスケジュールがあれば上書き。一時停止 / 停止 / 完了時にキャンセルする。
  Future<void> scheduleTimerCompletion({
    required DateTime fireAt,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      await cancelTimerCompletion();
      final scheduled = tz.TZDateTime.from(fireAt, tz.local);
      if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
        // 過去時刻 → 即座に通知（fire-and-forget）。
        await _plugin.show(
          _timerCompletionNotificationId,
          title,
          body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _achievementChannelId,
              _achievementChannelName,
              channelDescription: _achievementChannelDescription,
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
        return;
      }
      await _plugin.zonedSchedule(
        _timerCompletionNotificationId,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _achievementChannelId,
            _achievementChannelName,
            channelDescription: _achievementChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        // alarmClock を使うと SCHEDULE_EXACT_ALARM 権限を別途要求せずに
        // 正確な発火が得られる（端末再起動後も保持される）。
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e, st) {
      debugPrint('scheduleTimerCompletion failed: $e\n$st');
    }
  }

  Future<void> cancelTimerCompletion() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_timerCompletionNotificationId);
    } catch (e, st) {
      debugPrint('cancelTimerCompletion failed: $e\n$st');
    }
  }

  /// 指定された曜日にリマインダーをスケジュールする。
  /// [weekdays] は DateTime.weekday の値（1=月 .. 7=日）の集合。
  /// 空集合の場合は何もスケジュールしない（実質 OFF）。
  /// 内部で 7 曜日分の既存スケジュールを全てキャンセルしてから再登録する。
  Future<void> scheduleDailyReminder(
    TimeOfDay time, {
    required Set<int> weekdays,
  }) async {
    if (!_initialized) return;
    try {
      // 既存の全曜日スケジュール + legacy 単発 ID をクリーンアップ
      await cancelDailyReminder();
      if (weekdays.isEmpty) return;
      for (final weekday in weekdays) {
        final scheduled = _nextOccurrenceOfWeekday(weekday, time);
        // 文言は曜日タグ（平日 / 休日 / どちらでも）に合致するプールから
        // 乱択する（issue #174）。アプリ起動ごとに本メソッドが呼ばれるので、
        // 起動するたびに次の 1 週間ぶんの文言が refresh される。
        final message = ReminderMessages.randomFor(weekday);
        await _plugin.zonedSchedule(
          _reminderNotificationIdBase + weekday,
          message.title,
          message.body,
          scheduled,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _reminderChannelId,
              _reminderChannelName,
              channelDescription: _reminderChannelDescription,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e, st) {
      debugPrint('scheduleDailyReminder failed: $e\n$st');
    }
  }

  /// 指定された [weekday] (1=月 .. 7=日) の次の [time] を返す。
  tz.TZDateTime _nextOccurrenceOfWeekday(int weekday, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    while (candidate.weekday != weekday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  Future<void> cancelDailyReminder() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_legacyReminderNotificationId);
      for (var d = 1; d <= 7; d++) {
        await _plugin.cancel(_reminderNotificationIdBase + d);
      }
    } catch (e, st) {
      debugPrint('cancelDailyReminder failed: $e\n$st');
    }
  }

  Future<void> showAchievement({
    required String title,
    required String body,
    int idOffset = 0,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        _achievementNotificationIdBase + idOffset,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _achievementChannelId,
            _achievementChannelName,
            channelDescription: _achievementChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('showAchievement failed: $e\n$st');
    }
  }

  Future<void> showStreak(int days) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        _streakNotificationIdBase + days,
        '$days日連続達成！',
        'コツコツの積み上げが続いています',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _achievementChannelId,
            _achievementChannelName,
            channelDescription: _achievementChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('showStreak failed: $e\n$st');
    }
  }
}
