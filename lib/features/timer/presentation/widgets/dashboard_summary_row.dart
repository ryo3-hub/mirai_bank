import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/utils/duration_formatter.dart';
import '../../../history/application/summary_providers.dart';
import '../../../history/domain/session_summary.dart';

class DashboardSummaryRow extends ConsumerWidget {
  const DashboardSummaryRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(summaryProvider(SummaryPeriod.today));
    final monthAsync = ref.watch(summaryProvider(SummaryPeriod.month));
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: '今日',
            summary: todayAsync.value ?? SessionSummary.empty,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTile(
            label: '今月',
            summary: monthAsync.value ?? SessionSummary.empty,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.summary});

  final String label;
  final SessionSummary summary;

  static final _amountFormatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_amountFormatter.format(summary.amount)} 円',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DurationFormatter.hourMinute(summary.durationSec),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
