import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/encouragement_providers.dart';

/// ホーム画面上部に表示する励ましのひとことバナー。
///
/// アプリ起動時にランダムに 1 つ選ばれ（[dailyEncouragementProvider]）、
/// 同じセッション中は同じ文言を表示する。タイマーカードの直前に置き、
/// 「作業前にやる気を出してもらう」目的の文脈で見えるようにする。
///
/// 連続学習日数が 0 日でも表示する（issue 0 日目でも見たい要望）。
/// メッセージ取得待ちのときは何も描画しないので、空のスペースで
/// レイアウトを乱さない。
class DailyEncouragementBanner extends ConsumerWidget {
  const DailyEncouragementBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMessage = ref.watch(dailyEncouragementProvider);
    final message = asyncMessage.valueOrNull;
    if (message == null || message.isEmpty) {
      // ローディング中は固定高さを保ってレイアウトの跳ねを防ぐ
      return const SizedBox(height: 56);
    }
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.format_quote_outlined,
            size: 18,
            color: cs.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
