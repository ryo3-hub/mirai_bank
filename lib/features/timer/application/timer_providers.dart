import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/database/database_provider.dart';
import '../../../shared/notification/notification_service.dart';
import '../../../shared/notification/post_session_notifier.dart';
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

@riverpod
Stream<int> elapsedSeconds(Ref ref, DateTime startTime) async* {
  yield DateTime.now().difference(startTime).inSeconds;
  yield* Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now().difference(startTime).inSeconds,
  );
}

@riverpod
class TimerController extends _$TimerController {
  @override
  void build() {}

  Future<void> start({required String categoryId, String? memo}) async {
    final now = DateTime.now();
    await ref.read(activeTimerRepositoryProvider).save(
          categoryId: categoryId,
          startTime: now,
          memo: memo,
        );
    final category =
        await ref.read(categoryRepositoryProvider).findById(categoryId);
    if (category != null) {
      await NotificationService.instance.showOngoingTimer(
        categoryName: category.name,
        subtitle: '作業を計測中です',
      );
    }
  }

  Future<void> updateMemo(String? memo) async {
    final current = await ref.read(activeTimerRepositoryProvider).fetch();
    if (current == null) return;
    await ref.read(activeTimerRepositoryProvider).save(
          categoryId: current.categoryId,
          startTime: current.startTime,
          memo: (memo == null || memo.isEmpty) ? null : memo,
        );
  }

  Future<WorkSession?> stop({String? memo}) async {
    final activeTimer =
        await ref.read(activeTimerRepositoryProvider).fetch();
    if (activeTimer == null) return null;

    final category = await ref
        .read(categoryRepositoryProvider)
        .findById(activeTimer.categoryId);

    final endTime = DateTime.now();
    final durationSec = endTime.difference(activeTimer.startTime).inSeconds;
    final hourlyRate = category?.hourlyRate ?? 0;
    final amount = AmountCalculator.calculate(
      durationSec: durationSec,
      hourlyRate: hourlyRate,
    );
    final finalMemo = memo?.trim().isNotEmpty == true
        ? memo!.trim()
        : activeTimer.memo;

    final session = await ref.read(workSessionRepositoryProvider).create(
          categoryId: activeTimer.categoryId,
          startTime: activeTimer.startTime,
          endTime: endTime,
          durationSec: durationSec,
          amount: amount,
          memo: finalMemo,
          inputMethod: WorkSessionInputMethod.timer,
        );

    await ref.read(activeTimerRepositoryProvider).clear();
    await NotificationService.instance.cancelOngoingTimer();
    await ref.read(postSessionNotifierProvider).runAfterSessionSave();
    return session;
  }

  Future<void> cancel() async {
    await ref.read(activeTimerRepositoryProvider).clear();
    await NotificationService.instance.cancelOngoingTimer();
  }
}
