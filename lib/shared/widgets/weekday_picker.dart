import 'package:flutter/material.dart';

import '../utils/weekday_color.dart';

/// 通知曜日を選ぶ 7 個セルの横並びピッカー（issue #88 / #121）。
///
/// 値は `DateTime.weekday` 形式（1=月 .. 7=日）。表示順は日曜始まり。
/// 設定ページとオンボーディングで共通利用するため `lib/shared/widgets/` に置く。
class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({
    super.key,
    required this.selected,
    required this.onToggle,
    this.enabled = true,
  });

  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final bool enabled;

  // 日曜始まり（issue #88）。値は DateTime.weekday 形式のまま、表示順だけ変更。
  static const _labels = <(int, String)>[
    (7, '日'),
    (1, '月'),
    (2, '火'),
    (3, '水'),
    (4, '木'),
    (5, '金'),
    (6, '土'),
  ];

  @override
  Widget build(BuildContext context) {
    // 端末幅に依存せず常に 1 行に収まるよう、各曜日を Expanded で均等割りした
    // 独自セルにする（issue #74）。Material の FilterChip は最小幅が大きく
    // 狭い画面で折り返すため使用しない。
    return Row(
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: _WeekdayCell(
              weekday: _labels[i].$1,
              label: _labels[i].$2,
              isSelected: selected.contains(_labels[i].$1),
              enabled: enabled,
              onTap: () => onToggle(_labels[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _WeekdayCell extends StatelessWidget {
  const _WeekdayCell({
    required this.weekday,
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final int weekday;
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // 土・日はそれぞれ青・赤、平日は primary 色を選択時の強調色に使う。
    final accent = weekdayColor(context, weekday) ?? colorScheme.primary;

    final Color bg;
    final Color fg;
    final Color border;
    if (!enabled) {
      bg = colorScheme.surfaceContainerLow;
      fg = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
      border = colorScheme.outlineVariant.withValues(alpha: 0.5);
    } else if (isSelected) {
      // 選択時は白背景 + アクセント色の枠線とテキスト（塗りつぶしはしない）
      bg = colorScheme.surface;
      fg = accent;
      border = accent;
    } else {
      bg = colorScheme.surface;
      fg = colorScheme.onSurfaceVariant;
      border = colorScheme.outlineVariant;
    }
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: isSelected ? 1.5 : 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
