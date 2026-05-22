import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/timer_preset_providers.dart';
import '../domain/timer_preset.dart';

/// プリセットを選んでタイマーを開始するボトムシート。
class TimerPresetPickerSheet extends ConsumerWidget {
  const TimerPresetPickerSheet({super.key});

  static Future<TimerPreset?> show(BuildContext context) {
    return showModalBottomSheet<TimerPreset>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const TimerPresetPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(timerPresetListProvider);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Row(
              children: [
                Text(
                  'タイマーをセットする',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'プリセットを編集',
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/settings/timer-presets');
                  },
                ),
              ],
            ),
          ),
          presetsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text('読み込みに失敗しました: $e'),
            ),
            data: (presets) {
              if (presets.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timer_off_outlined,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      const Text('プリセットがありません'),
                      const SizedBox(height: 8),
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.add),
                        label: const Text('プリセットを追加'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push('/settings/timer-presets');
                        },
                      ),
                    ],
                  ),
                );
              }
              final maxMinutes = presets
                  .map((p) => p.minutes)
                  .fold<int>(0, (m, x) => x > m ? x : m);
              return Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: presets.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = presets[i];
                    return _PresetRow(
                      preset: p,
                      maxMinutes: maxMinutes,
                      onTap: () => Navigator.of(context).pop(p),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.preset,
    required this.maxMinutes,
    required this.onTap,
  });

  final TimerPreset preset;
  final int maxMinutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = maxMinutes == 0 ? 0.0 : preset.minutes / maxMinutes;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 92),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${preset.minutes}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: 'min',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  FractionallySizedBox(
                    widthFactor: ratio.clamp(0.08, 1.0),
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                preset.label.isEmpty ? '${preset.minutes}分集中' : preset.label,
                style: theme.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
