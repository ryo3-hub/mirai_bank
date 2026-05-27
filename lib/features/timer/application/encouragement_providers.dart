import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../history/application/streak_providers.dart';
import '../domain/streak_messages.dart';

part 'encouragement_providers.g.dart';

/// アプリ起動時にランダムに選ばれる励ましメッセージ。
///
/// `keepAlive: true` なのでアプリのライフタイム中はキャッシュされ、
/// 同じセッション内では同じ文言を表示する。次回起動時に新たに選び直される。
///
/// 連続学習日数（[currentStreakProvider]）に応じてメッセージのプール（tier）が
/// 切り替わる。streak の取得を待ってから選ぶことで、適切なティアから引ける。
@Riverpod(keepAlive: true)
Future<String> dailyEncouragement(Ref ref) async {
  final streak = await ref.watch(currentStreakProvider.future);
  return pickRandomEncouragement(streak);
}
