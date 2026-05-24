import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/reorder_proxy_decorator.dart';
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
          return _PresetReorderableList(presets: presets);
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

/// 並び替え時のちらつきを抑えるため、ID 順序だけローカル state で管理する。
/// （カテゴリ管理 issue #70 と同じパターン）
class _PresetReorderableList extends ConsumerStatefulWidget {
  const _PresetReorderableList({required this.presets});

  final List<TimerPreset> presets;

  @override
  ConsumerState<_PresetReorderableList> createState() =>
      _PresetReorderableListState();
}

class _PresetReorderableListState
    extends ConsumerState<_PresetReorderableList> {
  late List<String> _localOrder;

  @override
  void initState() {
    super.initState();
    _localOrder = widget.presets.map((p) => p.id).toList();
  }

  @override
  void didUpdateWidget(_PresetReorderableList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIds = widget.presets.map((p) => p.id).toSet();
    _localOrder.removeWhere((id) => !newIds.contains(id));
    for (final p in widget.presets) {
      if (!_localOrder.contains(p.id)) {
        _localOrder.add(p.id);
      }
    }
  }

  Future<void> _onReorder(int oldIndex, int newIndex) {
    HapticFeedback.heavyImpact();
    // ReorderableListView の newIndex は「移動後の挿入先」を指すので、
    // 下方向への移動は -1 補正してリスト操作と整合させる。
    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    setState(() {
      final id = _localOrder.removeAt(oldIndex);
      _localOrder.insert(adjustedNewIndex, id);
    });
    return ref
        .read(timerPresetControllerProvider.notifier)
        .reorder(List<String>.from(_localOrder));
  }

  @override
  Widget build(BuildContext context) {
    final byId = {for (final p in widget.presets) p.id: p};
    final displayList = _localOrder
        .map((id) => byId[id])
        .whereType<TimerPreset>()
        .toList();
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      itemCount: displayList.length,
      proxyDecorator: roundedReorderProxy,
      onReorderStart: (_) => HapticFeedback.mediumImpact(),
      onReorder: _onReorder,
      header: _SectionLabel(count: displayList.length),
      itemBuilder: (context, index) {
        final preset = displayList[index];
        return Padding(
          key: ValueKey(preset.id),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _PresetCard(preset: preset),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          Text(
            'プリセット',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count件',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Icon(
            Icons.drag_indicator,
            size: 16,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            '長押しで並び替え',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
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
