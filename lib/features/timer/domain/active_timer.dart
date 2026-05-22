/// 現在進行中のタイマー状態（シングルトン）。
///
/// カウントダウン式タイマー（issue #95）：
/// - [targetDurationSec] = プリセットで選んだ目標時間（秒）
/// - [accumulatedSec] = 一時停止までの累積稼働秒数
/// - [resumedAt] = 直近で再開（または開始）した時刻。null のとき一時停止中
class ActiveTimer {
  const ActiveTimer({
    required this.categoryId,
    required this.startTime,
    required this.targetDurationSec,
    required this.accumulatedSec,
    required this.resumedAt,
    this.memo,
  });

  /// セッションの集計用開始時刻（履歴の startTime として使う）。
  final DateTime startTime;
  final String categoryId;
  final int targetDurationSec;
  final int accumulatedSec;
  final DateTime? resumedAt;
  final String? memo;

  bool get isPaused => resumedAt == null;

  /// 現時点での累計経過秒数（accumulated + 再開後の経過）。
  int elapsedSecondsAt(DateTime now) {
    if (resumedAt == null) {
      return accumulatedSec.clamp(0, 1 << 30);
    }
    final sinceResume = now.difference(resumedAt!).inSeconds;
    return (accumulatedSec + sinceResume).clamp(0, 1 << 30);
  }

  /// 残り秒数（負にはしない）。
  int remainingSecondsAt(DateTime now) {
    final remaining = targetDurationSec - elapsedSecondsAt(now);
    return remaining < 0 ? 0 : remaining;
  }

  bool isCompletedAt(DateTime now) =>
      elapsedSecondsAt(now) >= targetDurationSec && targetDurationSec > 0;
}
