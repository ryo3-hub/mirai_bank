import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/streak_calculator.dart';
import 'work_session_providers.dart';

part 'streak_providers.g.dart';

/// 現在の連続学習日数（ストリーク）。
/// セッションの変動を購読し、`StreakCalculator.compute` で算出した値を流す。
@riverpod
Stream<int> currentStreak(Ref ref) {
  return ref
      .watch(workSessionRepositoryProvider)
      .watchAll()
      .map(StreakCalculator.compute);
}
