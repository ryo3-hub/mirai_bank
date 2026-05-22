import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/top_toast.dart';
import '../application/timer_preset_providers.dart';
import '../domain/timer_preset.dart';
import 'timer_preset_edit_sheet.dart';

class TimerPresetListPage extends ConsumerWidget {
  const TimerPresetListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(timerPresetListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('タイマープリセット')),
      body: presetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みに失敗しました: $e')),
        data: (presets) {
          if (presets.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            itemCount: presets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _PresetCard(preset: presets[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => TimerPresetEditSheet.show(context),
        tooltip: 'プリセットを追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_off_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          const Text('プリセットがありません'),
          const SizedBox(height: 8),
          Text(
            '右下のボタンから追加できます',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _PresetCard extends ConsumerWidget {
  const _PresetCard({required this.preset});

  final TimerPreset preset;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDeleteConfirmDialog(
      context: context,
      message: '${preset.minutes} 分プリセットを削除します。',
    );
    if (!ok) return;
    try {
      await ref
          .read(timerPresetControllerProvider.notifier)
          .delete(preset.id);
      if (context.mounted) {
        TopToast.show(context, message: 'プリセットを削除しました');
      }
    } catch (e) {
      if (context.mounted) {
        TopToast.show(
          context,
          message: '削除に失敗しました: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: Text(
            '${preset.minutes}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          preset.label.isEmpty ? '${preset.minutes}分集中' : preset.label,
        ),
        subtitle: Text('${preset.minutes} 分'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: '削除',
          onPressed: () => _confirmDelete(context, ref),
        ),
      ),
    );
  }
}
