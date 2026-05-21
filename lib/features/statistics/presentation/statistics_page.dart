import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/stats_providers.dart';
import '../domain/stats_data.dart';
import 'widgets/stats_breakdown_card.dart';
import 'widgets/stats_summary_card.dart';
import 'widgets/stats_trend_chart_card.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  StatsPeriod _period = StatsPeriod.week;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(periodStatsProvider(_period));
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SegmentedButton<StatsPeriod>(
                segments: [
                  for (final p in StatsPeriod.values)
                    ButtonSegment(value: p, label: Text(p.label)),
                ],
                selected: {_period},
                showSelectedIcon: false,
                onSelectionChanged: (set) =>
                    setState(() => _period = set.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: statsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('読み込みに失敗しました: $e')),
                data: (stats) => _StatsBody(stats: stats),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final PeriodStats stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatsSummaryCard(stats: stats),
          const SizedBox(height: 12),
          StatsTrendChartCard(stats: stats),
          const SizedBox(height: 12),
          StatsBreakdownCard(stats: stats),
        ],
      ),
    );
  }
}
