import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 「今日」（端末ローカルの 0:00 で区切った日付）を提供する（issue #189）。
///
/// 0:00 を跨いだとき（日付変化タイマー）とアプリのバックグラウンド復帰時に
/// 再評価し、日付が変わっていれば新しい値を流す。「今日の積み上げ」や
/// 統計の期間境界、連続学習日数（streak）など今日基準の集計プロバイダは
/// これを watch することで、日付ロールオーバー時に自動的に再計算される。
final currentDayProvider = NotifierProvider<CurrentDayNotifier, DateTime>(
  CurrentDayNotifier.new,
);

class CurrentDayNotifier extends Notifier<DateTime>
    with WidgetsBindingObserver {
  Timer? _midnightTimer;

  @override
  DateTime build() {
    final binding = WidgetsBinding.instance;
    binding.addObserver(this);
    ref.onDispose(() {
      binding.removeObserver(this);
      _midnightTimer?.cancel();
    });
    final today = _today();
    _scheduleMidnightTick(today);
    return today;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshIfDayChanged();
    }
  }

  void _refreshIfDayChanged() {
    final today = _today();
    if (today != state) {
      state = today;
    }
    // 日付が変わっていなくても（スリープでタイマーが遅延したケース等）
    // 次の 0:00 に向けてタイマーを張り直す。
    _scheduleMidnightTick(today);
  }

  void _scheduleMidnightTick(DateTime today) {
    _midnightTimer?.cancel();
    final nextMidnight = DateTime(today.year, today.month, today.day + 1);
    final delay =
        nextMidnight.difference(DateTime.now()) + const Duration(seconds: 1);
    _midnightTimer = Timer(
      delay.isNegative ? const Duration(seconds: 1) : delay,
      _refreshIfDayChanged,
    );
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
