import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../category/domain/category_presets.dart';
import '../../domain/stats_data.dart';

class StatsBreakdownCard extends StatelessWidget {
  const StatsBreakdownCard({super.key, required this.stats});

  final PeriodStats stats;

  static final _amountFormatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakdown = stats.breakdown;
    final hasData =
        breakdown.isNotEmpty && breakdown.any((b) => b.amount > 0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'カテゴリ別',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (!hasData)
              const _BreakdownEmpty()
            else
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: [
                      for (final share in breakdown)
                        PieChartSectionData(
                          value: share.amount.toDouble(),
                          color: CategoryPresets.colorFor(
                            share.category.colorCode,
                          ),
                          radius: 56,
                          title: share.ratio >= 0.08
                              ? '${(share.ratio * 100).round()}%'
                              : '',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                    ],
                    centerSpaceRadius: 36,
                    sectionsSpace: 2,
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 350),
                ),
              ),
            if (hasData) ...[
              const SizedBox(height: 16),
              for (final share in breakdown)
                _LegendRow(share: share),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.share});

  final CategoryShare share;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: CategoryPresets.colorFor(share.category.colorCode),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              share.category.name,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${StatsBreakdownCard._amountFormatter.format(share.amount)} 円',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              '${(share.ratio * 100).toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownEmpty extends StatelessWidget {
  const _BreakdownEmpty();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 40,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            const Text('データがありません'),
          ],
        ),
      ),
    );
  }
}
