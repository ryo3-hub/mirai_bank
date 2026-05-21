import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/utils/duration_formatter.dart';
import '../../../category/domain/category.dart';
import '../../../category/domain/category_presets.dart';
import '../../domain/work_session.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.category,
    this.onTap,
  });

  final WorkSession session;
  final Category? category;
  final VoidCallback? onTap;

  static final _amountFormatter = NumberFormat('#,###');
  static final _timeFormatter = DateFormat('H:mm');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category == null
        ? theme.colorScheme.outline
        : CategoryPresets.colorFor(category!.colorCode);
    final icon = category == null
        ? Icons.help_outline
        : CategoryPresets.iconFor(category!.iconCode);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color,
                foregroundColor: Colors.white,
                radius: 20,
                child: Icon(icon, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            category?.name ?? '不明なカテゴリ',
                            style: theme.textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _InputMethodBadge(method: session.inputMethod),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_timeFormatter.format(session.startTime)}'
                          '–${_timeFormatter.format(session.endTime)}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DurationFormatter.hourMinuteSecond(
                              session.durationSec),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (session.memo != null && session.memo!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        session.memo!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_amountFormatter.format(session.amount)} 円',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputMethodBadge extends StatelessWidget {
  const _InputMethodBadge({required this.method});

  final WorkSessionInputMethod method;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTimer = method == WorkSessionInputMethod.timer;
    final label = isTimer ? 'タイマー' : '手動';
    final icon = isTimer ? Icons.timer_outlined : Icons.edit_outlined;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: theme.colorScheme.outline),
          const SizedBox(width: 3),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
