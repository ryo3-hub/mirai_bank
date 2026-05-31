import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'features/settings/application/setting_providers.dart';
import 'shared/notification/notification_service.dart';

/// Sentry の DSN は `--dart-define=SENTRY_DSN=...` でビルド時注入する想定。
/// 空文字（ローカル開発・テスト時）はクラッシュ送信を完全スキップする。
const String _sentryDsn = String.fromEnvironment('SENTRY_DSN');

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      // パフォーマンス計測のサンプリング率（本番でも 10% 程度に絞る）
      options.tracesSampleRate = kReleaseMode ? 0.1 : 1.0;
      // 環境タグ。Sentry の UI 上でフィルタできる
      options.environment = kReleaseMode ? 'production' : 'development';
      // 開発中は console にログを出して動作確認しやすくする
      options.debug = !kReleaseMode;
      // 個人情報を持っていないので IP / Cookie 等の自動収集も無効化
      options.sendDefaultPii = false;
    },
    appRunner: _bootstrap,
  );
}

/// 自然初期化（〜1.5 秒）に上乗せしてブランドスプラッシュを少し長く見せる
/// 追加ホールド時間（issue #172）。トータルで約 2.5〜3 秒の体感になる想定。
const Duration _splashExtraHold = Duration(milliseconds: 1500);

Future<void> _bootstrap() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // 通常 flutter_native_splash は最初の Flutter フレーム描画時に自動で
  // dismiss されるが、preserve を呼ぶと remove するまでスプラッシュを
  // ホールドする。下の Future.delayed と合わせて使う。
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initializeDateFormatting('ja_JP');
  await NotificationService.instance.init();
  final container = ProviderContainer();
  try {
    final setting = await container.read(settingRepositoryProvider).fetch();
    if (setting.reminderEnabled) {
      await NotificationService.instance.scheduleDailyReminder(
        setting.reminderTimeOfDay,
        weekdays: setting.reminderWeekdays,
      );
    }
  } catch (e, st) {
    debugPrint('Bootstrap error: $e\n$st');
    // 起動時の致命的でない失敗も Sentry に送っておく（DSN 設定時のみ送信される）
    await Sentry.captureException(e, stackTrace: st);
  }
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MiraiBankApp(),
    ),
  );
  // 最初のフレーム描画 + 追加ホールド後にスプラッシュを引っ込める。
  // ホールド中も Flutter UI は裏で完成しているので、remove と同時に
  // ホーム/オンボーディングへスムーズに切り替わる。
  await Future<void>.delayed(_splashExtraHold);
  FlutterNativeSplash.remove();
}
