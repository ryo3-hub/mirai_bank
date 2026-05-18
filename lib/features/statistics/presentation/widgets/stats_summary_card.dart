import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/utils/duration_formatter.dart';
import '../../../../shared/widgets/animated_amount.dart';
import '../../../category/domain/category_presets.dart';
import '../../domain/stats_data.dart';

class StatsSummaryCard extends StatelessWidget {
  const StatsSummaryCard({super.key, required this.stats});

  final PeriodStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = stats.topCategory;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '期間サマリ',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: AnimatedAmount(
                amount: stats.totalAmount,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                DurationFormatter.hourMinute(stats.totalDurationSec),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (top != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '最も学習',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        CategoryPresets.colorFor(top.colorCode),
                    foregroundColor: Colors.white,
                    child: Icon(
                      CategoryPresets.iconFor(top.iconCode),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    top.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${NumberFormat('#,###').format(stats.breakdown.first.amount)} 円',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
