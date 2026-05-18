import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/stats_data.dart';

class StatsTrendChartCard extends StatelessWidget {
  const StatsTrendChartCard({super.key, required this.stats});

  final PeriodStats stats;

  static final _amountFormatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buckets = stats.buckets;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '推移',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (buckets.isEmpty || buckets.every((b) => b.amount == 0))
              const _ChartEmpty()
            else
              SizedBox(
                height: 220,
                child: BarChart(
                  _buildChartData(theme, buckets),
                  swapAnimationDuration: const Duration(milliseconds: 350),
                  swapAnimationCurve: Curves.easeOutCubic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  BarChartData _buildChartData(ThemeData theme, List<StatsBucket> buckets) {
    final maxAmount = buckets.fold<int>(
      0,
      (m, b) => b.amount > m ? b.amount : m,
    );
    final maxY = maxAmount == 0 ? 1000.0 : maxAmount * 1.15;
    final showEvery = _labelStep(buckets.length);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      minY: 0,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _horizontalInterval(maxY),
        getDrawingHorizontalLine: (_) => FlLine(
          color: theme.colorScheme.outlineVariant,
          strokeWidth: 1,
          dashArray: const [4, 4],
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            interval: _horizontalInterval(maxY),
            getTitlesWidget: (value, meta) {
              if (value == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  _abbreviateAmount(value),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= buckets.length) {
                return const SizedBox.shrink();
              }
              if (i % showEvery != 0 && i != buckets.length - 1) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  buckets[i].label,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => theme.colorScheme.inverseSurface,
          getTooltipItem: (group, _, rod, __) {
            final bucket = buckets[group.x];
            return BarTooltipItem(
              '${bucket.label}\n${_amountFormatter.format(rod.toY.toInt())} 円',
              TextStyle(
                color: theme.colorScheme.onInverseSurface,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
      barGroups: [
        for (var i = 0; i < buckets.length; i++)
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: buckets[i].amount.toDouble(),
                color: theme.colorScheme.primary,
                width: _barWidth(buckets.length),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
      ],
    );
  }

  int _labelStep(int count) {
    if (count <= 10) return 1;
    if (count <= 20) return 3;
    return 5;
  }

  double _barWidth(int count) {
    if (count <= 7) return 24;
    if (count <= 12) return 16;
    if (count <= 20) return 10;
    return 6;
  }

  double _horizontalInterval(double maxY) {
    if (maxY <= 0) return 1;
    final raw = maxY / 4;
    if (raw < 100) return 100;
    if (raw < 1000) return 500;
    if (raw < 10000) return 1000;
    if (raw < 100000) return 10000;
    return 50000;
  }

  static String _abbreviateAmount(double value) {
    final v = value.abs();
    if (v >= 10000) {
      return '${(value / 10000).toStringAsFixed(value % 10000 == 0 ? 0 : 1)}万';
    }
    if (v >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k';
    }
    return value.toInt().toString();
  }
}

class _ChartEmpty extends StatelessWidget {
  const _ChartEmpty();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart,
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
