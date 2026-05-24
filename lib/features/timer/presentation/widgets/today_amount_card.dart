import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/duration_formatter.dart';
import '../../../../shared/widgets/animated_amount.dart';
import '../../../history/application/streak_providers.dart';
import '../../../history/application/summary_providers.dart';

class TodayAmountCard extends ConsumerWidget {
  const TodayAmountCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final summaryAsync = ref.watch(summaryProvider(SummaryPeriod.today));
    final amount = summaryAsync.value?.amount ?? 0;
    final durationSec = summaryAsync.value?.durationSec ?? 0;
    // issue #122: 連続学習日数を本カードのフッターとして統合表示する。
    final streakDays = ref.watch(currentStreakProvider).valueOrNull ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '今日の積み上げ',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Center(
              child: AnimatedAmount(
                amount: amount,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                DurationFormatter.hourMinute(durationSec),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (streakDays > 0) ...[
              const SizedBox(height: 20),
              _StreakFooter(days: streakDays),
            ],
          ],
        ),
      ),
    );
  }
}

/// issue #122: ホームの「今日の積み上げ」カード下部に表示する連続学習日数。
///
/// 旧 `StreakBadge` のピル型から、カード内フッター（divider + 炎アイコン +
/// 日数 + milestone ラベル）に再設計した。色は段階別（[_streakAccent]）。
class _StreakFooter extends StatelessWidget {
  const _StreakFooter({required this.days});

  final int days;

  /// 節目（3 / 7 / 30 / 100 / 365）のラベル。ぴったり一致した日だけ強調を出す。
  static String? _milestoneLabel(int days) {
    return switch (days) {
      365 => '1年達成！',
      100 => '100日達成！',
      30 => '1ヶ月達成！',
      7 => '1週間達成！',
      3 => '3日達成！',
      _ => null,
    };
  }

  /// 連続日数に応じて段階的に色を変える。
  /// 1-6: primary、7-29: amber、30-99: orange、100-364: crimson、365+: gold。
  static Color _streakAccent(int days, ColorScheme cs) {
    if (days >= 365) return const Color(0xFFD4A017); // gold
    if (days >= 100) return const Color(0xFFC0392B); // crimson
    if (days >= 30) return const Color(0xFFE67E22); // orange
    if (days >= 7) return const Color(0xFFEEAA22); // amber
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = _streakAccent(days, cs);
    final label = _milestoneLabel(days);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(color: cs.outlineVariant, height: 1),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department,
              size: 20,
              color: accent,
            ),
            const SizedBox(width: 6),
            Text(
              '$days 日連続',
              style: theme.textTheme.titleSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: accent.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
