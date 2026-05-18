import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/animated_amount.dart';
import '../../../history/application/summary_providers.dart';

class DashboardTotalCard extends ConsumerStatefulWidget {
  const DashboardTotalCard({super.key});

  @override
  ConsumerState<DashboardTotalCard> createState() =>
      _DashboardTotalCardState();
}

class _DashboardTotalCardState extends ConsumerState<DashboardTotalCard> {
  SummaryPeriod _period = SummaryPeriod.all;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final summaryAsync = ref.watch(summaryProvider(_period));
    final amount = summaryAsync.value?.amount ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<SummaryPeriod>(
              segments: [
                for (final p in SummaryPeriod.values)
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
            const SizedBox(height: 20),
            Text(
              '${_period.label}の積み上げ',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Center(
              child: AnimatedAmount(
                amount: amount,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
