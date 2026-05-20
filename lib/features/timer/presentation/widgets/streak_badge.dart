import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../history/application/streak_providers.dart';
import '../../../history/domain/streak_calculator.dart';

/// 連続学習日数を示すホーム画面上部のバッジ。
/// streak が 0 のときは何も描画しない。
class StreakBadge extends ConsumerWidget {
  const StreakBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(currentStreakProvider).valueOrNull ?? 0;
    if (days == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final tone = _toneFor(days, theme);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: tone.bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: tone.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                '$days日連続',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: tone.fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (tone.label != null) ...[
                const SizedBox(width: 6),
                Text(
                  tone.label!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tone.fg.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 節目（3 / 7 / 30 / 100 / 365 日）でトーンを変えて達成感を演出する。
  /// 節目を超えた瞬間に色が変わり、次の節目に向かう間は同じトーンが続く。
  static _BadgeTone _toneFor(int days, ThemeData theme) {
    final cs = theme.colorScheme;
    if (days >= 365) {
      return _BadgeTone(
        bg: const Color(0xFFFFF3CC),
        fg: const Color(0xFF8B6B00),
        border: const Color(0xFFE9C46A),
        label: '1年達成！',
      );
    }
    if (days >= 100) {
      return _BadgeTone(
        bg: const Color(0xFFFFE4E1),
        fg: const Color(0xFFB23A3A),
        border: const Color(0xFFE57373),
        label: '100日達成！',
      );
    }
    if (days >= 30) {
      return _BadgeTone(
        bg: const Color(0xFFFFE0B2),
        fg: const Color(0xFFB76E00),
        border: const Color(0xFFFFB74D),
        label: null,
      );
    }
    if (days >= 7) {
      return _BadgeTone(
        bg: const Color(0xFFFFF1D6),
        fg: const Color(0xFFB76E00),
        border: const Color(0xFFFFD08A),
        label: null,
      );
    }
    if (days >= 3) {
      return _BadgeTone(
        bg: cs.primaryContainer,
        fg: cs.onPrimaryContainer,
        border: cs.primaryContainer,
        label: null,
      );
    }
    return _BadgeTone(
      bg: cs.surfaceContainerHighest,
      fg: cs.onSurfaceVariant,
      border: cs.outlineVariant,
      label: null,
    );
  }

  /// 公開：節目達成済みか
  static bool isMilestone(int days) => StreakCalculator.milestones.contains(days);
}

class _BadgeTone {
  const _BadgeTone({
    required this.bg,
    required this.fg,
    required this.border,
    required this.label,
  });

  final Color bg;
  final Color fg;
  final Color border;
  final String? label;
}
