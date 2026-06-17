import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/database/database_provider.dart';
import '../../../shared/notification/notification_service.dart';
import '../../../shared/notification/post_session_notifier.dart';
import '../../../shared/notification/reminder_scheduler.dart';
import '../../category/application/category_providers.dart';
import '../../history/application/work_session_providers.dart';
import '../../history/domain/work_session.dart';
import '../domain/active_timer.dart';
import '../domain/amount_calculator.dart';
import '../infrastructure/active_timer_repository.dart';
import '../infrastructure/active_timer_repository_impl.dart';

part 'timer_providers.g.dart';

@Riverpod(keepAlive: true)
ActiveTimerRepository activeTimerRepository(Ref ref) {
  return ActiveTimerRepositoryImpl(ref.watch(appDatabaseProvider));
}

@riverpod
Stream<ActiveTimer?> activeTimer(Ref ref) {
  return ref.watch(activeTimerRepositoryProvider).watch();
}

/// アクティブタイマーの累計経過秒数を 1 秒間隔で emit する。
/// 一時停止中は固定値を返し続ける。
@riverpod
Stream<int> timerElapsed(Ref ref) async* {
  final timer = await ref.watch(activeTimerProvider.future);
  if (timer == null) {
    yield 0;
    return;
  }
  int compute() => timer.elapsedSecondsAt(DateTime.now());
  yield compute();
  if (timer.isPaused) {
    // 一時停止中は更新しない
    return;
  }
  yield* Stream<void>.periodic(const Duration(seconds: 1))
      .map((_) => compute());
}

@riverpod
class TimerController extends _$TimerController {
  @override
  void build() {}

  /// プリセットを選んでタイマーを開始する。
  Future<void> start({
    required String categoryId,
    required int targetDurationSec,
    String? memo,
  }) async {
    // カテゴリが見つからない場合はタイマーを開始しない。以前は通知だけ
    // スキップしてタイマーが開始されてしまっていた（issue #204）。
    final category =
        await ref.read(categoryRepositoryProvider).findById(categoryId);
    if (category == null) {
      throw StateError('カテゴリが見つかりません');
    }
    // 完了通知をきちんと届けるため、初回起動時にまだ要求していなければ
    // ここで通知権限を確認しておく（既に許可済みなら no-op）。
    await NotificationService.instance.requestPermissions();
    final now = DateTime.now();
    await ref.read(activeTimerRepositoryProvider).start(
          categoryId: categoryId,
          startTime: now,
          targetDurationSec: targetDurationSec,
          memo: memo,
        );
    await NotificationService.instance.showOngoingTimer(
      categoryName: category.name,
      subtitle: '作業時間を計測中',
    );
    // 完了時の push 通知をスケジュール（一時停止 / 停止 / 完了時にキャンセル）
    await NotificationService.instance.scheduleTimerCompletion(
      fireAt: now.add(Duration(seconds: targetDurationSec)),
      title: '⏰ タイマー完了！',
      body: '${category.name} の作業時間が完了しました',
    );
    // 計測中になったので、今日のリマインダー通知を抑止する（issue #178）。
    await ref.read(reminderSchedulerProvider).refresh();
  }

  Future<void> pause() async {
    await ref
        .read(activeTimerRepositoryProvider)
        .pause(now: DateTime.now());
    // 一時停止中は完了通知をキャンセル
    await NotificationService.instance.cancelTimerCompletion();
    // 常駐通知もアプリ内表示と矛盾しないよう「一時停止中」に更新する
    // （issue #193）
    final timer = await ref.read(activeTimerRepositoryProvider).fetch();
    if (timer != null) {
      final category = await ref
          .read(categoryRepositoryProvider)
          .findById(timer.categoryId);
      if (category != null) {
        await NotificationService.instance.showOngoingTimer(
          categoryName: category.name,
          subtitle: 'タイマーは止まっています',
          paused: true,
        );
      }
    }
  }

  Future<void> resume() async {
    final timer = await ref.read(activeTimerRepositoryProvider).fetch();
    // 一時停止中でないときは repository も no-op なので、完了通知の
    // 再スケジュールも行わない（issue #204）
    if (timer == null || !timer.isPaused) return;
    final now = DateTime.now();
    await ref.read(activeTimerRepositoryProvider).resume(now: now);
    final category = await ref
        .read(categoryRepositoryProvider)
        .findById(timer.categoryId);
    if (category != null) {
      // 常駐通知を「計測中」に戻す（issue #193）
      await NotificationService.instance.showOngoingTimer(
        categoryName: category.name,
        subtitle: '作業時間を計測中',
      );
      // 残り時間に合わせて完了通知を再スケジュール
      final remaining = timer.targetDurationSec - timer.accumulatedSec;
      if (remaining > 0) {
        await NotificationService.instance.scheduleTimerCompletion(
          fireAt: now.add(Duration(seconds: remaining)),
          title: '⏰ タイマー完了！',
          body: '${category.name} の作業時間が完了しました',
        );
      }
    }
  }

  Future<void> updateMemo(String? memo) {
    final normalized = (memo == null || memo.trim().isEmpty)
        ? null
        : memo.trim();
    return ref.read(activeTimerRepositoryProvider).updateMemo(normalized);
  }

  /// タイマーを終了してセッションを保存する。
  ///
  /// 課金対象時間（5 分単位切り下げ）が 0 のときは記録を作らずに
  /// クリアだけ行い、`null` を返す（issue #95 案 B）。
  Future<WorkSession?> stop({String? memo}) async {
    final activeTimer =
        await ref.read(activeTimerRepositoryProvider).fetch();
    if (activeTimer == null) return null;

    final now = DateTime.now();
    final workedSec = activeTimer.billableSecondsAt(now);
    final paidSec = AmountCalculator.paidDurationSec(workedSec);

    await NotificationService.instance.cancelTimerCompletion();
    await NotificationService.instance.cancelOngoingTimer();

    // 課金単位（5 分）未満は記録しない
    if (paidSec <= 0) {
      await ref.read(activeTimerRepositoryProvider).clear();
      // 計測を辞めたが今日のセッションは作られていない → 今日のリマインダー
      // 抑止の根拠が消えた可能性があるので再評価する（issue #178）。
      await ref.read(reminderSchedulerProvider).refresh();
      return null;
    }

    final category = await ref
        .read(categoryRepositoryProvider)
        .findById(activeTimer.categoryId);
    final hourlyRate = category?.hourlyRate ?? 0;
    final amount = AmountCalculator.calculate(
      durationSec: paidSec,
      hourlyRate: hourlyRate,
    );
    final finalMemo = memo?.trim().isNotEmpty == true
        ? memo!.trim()
        : activeTimer.memo;

    // endTime は基本「実際の停止時刻」（issue #192）。ただし overrun
    // （target を超過したまま放置）状態で auto-stop が走った場合は、
    // 実際に target に到達した瞬間を使う（issue #224）。これにより
    // バックグラウンド放置で何日も経ってから停止しても、セッションは
    // 「タイマーが完了した日」に正しく計上される。
    final endTime = activeTimer.completionTimeBy(now) ?? now;
    // セッション作成と ActiveTimer クリアを同一トランザクションで行う。
    // 別々の await にすると間でプロセスが死んだとき完了済み ActiveTimer が
    // 残存し、再起動時の自動停止で同一作業が二重記録される（issue #188）。
    final session = await ref.read(appDatabaseProvider).transaction(() async {
      final created = await ref.read(workSessionRepositoryProvider).create(
            categoryId: activeTimer.categoryId,
            startTime: activeTimer.startTime,
            endTime: endTime,
            durationSec: paidSec,
            amount: amount,
            memo: finalMemo,
            inputMethod: WorkSessionInputMethod.timer,
          );
      await ref.read(activeTimerRepositoryProvider).clear();
      return created;
    });
    await ref.read(postSessionNotifierProvider).runAfterSessionSave();
    // 今日のセッションが新規作成されたので、今日のリマインダーは抑止する
    // （issue #178）。refresh が skipToday=true を計算して反映する。
    await ref.read(reminderSchedulerProvider).refresh();
    return session;
  }

  Future<void> cancel() async {
    await ref.read(activeTimerRepositoryProvider).clear();
    await NotificationService.instance.cancelTimerCompletion();
    await NotificationService.instance.cancelOngoingTimer();
    // 計測中でなくなったので「今日のリマインダー抑止」を再評価する。
    // stop() の 5 分未満パスと対称にする（issue #196）。
    await ref.read(reminderSchedulerProvider).refresh();
  }
}
