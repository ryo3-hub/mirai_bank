import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/services/current_day_provider.dart';
import '../domain/streak_calculator.dart';
import 'work_session_providers.dart';

part 'streak_providers.g.dart';

/// 現在の連続学習日数（ストリーク）。
/// セッションの変動を購読し、`StreakCalculator.compute` で算出した値を流す。
@riverpod
Stream<int> currentStreak(Ref ref) {
  // 0:00 を跨いだとき / アプリ復帰時に「今日」を再評価する（issue #189）
  final today = ref.watch(currentDayProvider);
  return ref
      .watch(workSessionRepositoryProvider)
      .watchAll()
      .map((sessions) => StreakCalculator.compute(sessions, now: today));
}
