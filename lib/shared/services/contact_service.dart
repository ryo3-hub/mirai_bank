import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// お問い合わせ用の `mailto:` URL を組み立てて開くサービス（issue #142）。
///
/// 件名と本文の末尾に **アプリバージョン / OS / 端末モデル** を自動で
/// 入れておくことで、ユーザーが環境情報を書き忘れても開発側で把握できる。
class ContactService {
  ContactService({
    DeviceInfoPlugin? deviceInfo,
    String? supportEmail,
  })  : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
        _supportEmail = supportEmail ??
            const String.fromEnvironment(
              'SUPPORT_EMAIL',
              defaultValue: 'support@example.com',
            );

  final DeviceInfoPlugin _deviceInfo;
  final String _supportEmail;

  /// 既定のメールクライアントを開く。失敗時は呼び出し側で catch して
  /// トーストを出す想定。
  Future<void> openInquiryMail() async {
    final body = await _composeBody();
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: _buildQuery({
        'subject': '[mirai_bank] お問い合わせ',
        'body': body,
      }),
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      throw StateError('メールアプリを開けませんでした');
    }
  }

  Future<String> _composeBody() async {
    final pkg = await PackageInfo.fromPlatform();
    final env = await _envSummary();
    return '''


（ここにお問い合わせ内容を記入してください）

------------------------------------------
※ 以下の情報は変更しないでください
アプリ: ${pkg.appName} ${pkg.version} (${pkg.buildNumber})
$env
''';
  }

  Future<String> _envSummary() async {
    try {
      if (kIsWeb) {
        final web = await _deviceInfo.webBrowserInfo;
        return 'Browser: ${web.userAgent ?? "unknown"}';
      }
      if (Platform.isIOS) {
        final ios = await _deviceInfo.iosInfo;
        return 'OS: iOS ${ios.systemVersion}\n端末: ${ios.utsname.machine}';
      }
      if (Platform.isAndroid) {
        final android = await _deviceInfo.androidInfo;
        return 'OS: Android ${android.version.release} (SDK ${android.version.sdkInt})\n'
            '端末: ${android.manufacturer} ${android.model}';
      }
      return 'OS: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
    } catch (e) {
      return 'OS: ${Platform.operatingSystem}（端末情報取得失敗: $e）';
    }
  }

  /// `mailto:?subject=...&body=...` のクエリ文字列を組み立てる。
  /// `Uri.encodeQueryComponent` は空白を `+` にエンコードするが、メール本文の
  /// 改行を `+` に置換されると読みにくくなるので `Uri.encodeComponent` を使う。
  String _buildQuery(Map<String, String> params) {
    return params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
