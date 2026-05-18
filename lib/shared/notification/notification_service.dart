import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _timerNotificationId = 1001;
  static const int _reminderNotificationId = 1002;
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

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    if (!_initialized) return;
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        _reminderNotificationId,
        '今日の学習を続けましょう',
        '少しの時間でも、未来への投資になります',
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
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e, st) {
      debugPrint('scheduleDailyReminder failed: $e\n$st');
    }
  }

  Future<void> cancelDailyReminder() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_reminderNotificationId);
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
