import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アプリ内レビュー要請のサービス（issue #141）。
///
/// iOS の `SKStoreReviewController` / Android の Google Play In-App Review
/// API を呼び出す。Apple のガイドラインで「年 3 回まで」「ポジティブな
/// 体験の直後」が推奨されているため、本サービス側でクールダウンを管理する。
class AppReviewService {
  AppReviewService({InAppReview? inAppReview})
      : _inAppReview = inAppReview ?? InAppReview.instance;

  final InAppReview _inAppReview;

  /// SharedPreferences のキー（最後にレビュー要請を行った日時の UTC ISO 文字列）。
  static const String _lastShownKey = 'app_review_last_shown';

  /// 自動要請のクールダウン（60 日）。設定画面からの明示的タップは無視する。
  static const Duration _autoCooldown = Duration(days: 60);

  /// 設定画面の「アプリを評価する」から呼ぶ用。クールダウン無視、即座に
  /// `requestReview()` を試み、ダメなら `openStoreListing()` でストアに遷移。
  Future<void> requestExplicit() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
      await _markShown();
    } else {
      await _inAppReview.openStoreListing(
        appStoreId: const String.fromEnvironment('APP_STORE_ID'),
      );
    }
  }

  /// 達成系のポジティブな体験直後に呼ぶ自動トリガー。
  /// 60 日のクールダウン中は何もしない。`InAppReview.isAvailable()` が
  /// false でも何もしない（ストア遷移はしない）。
  Future<void> maybeRequestAfterAchievement() async {
    if (!await _cooldownElapsed()) return;
    if (!await _inAppReview.isAvailable()) return;
    await _inAppReview.requestReview();
    await _markShown();
  }

  Future<bool> _cooldownElapsed() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastShownKey);
    if (raw == null) return true;
    final last = DateTime.tryParse(raw);
    if (last == null) return true;
    return DateTime.now().toUtc().difference(last) >= _autoCooldown;
  }

  Future<void> _markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastShownKey, DateTime.now().toUtc().toIso8601String());
  }
}
