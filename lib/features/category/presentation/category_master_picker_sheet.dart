import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/category_master.dart';
import '../domain/category_presets.dart';

/// プリセット master を選ぶボトムシート（大カテゴリ → 小カテゴリ の 2 ステップ）。
///
/// 大カテゴリは 14 件をボタングリッドで表示。タップすると同じシート内で
/// その major に属する小カテゴリ一覧に切り替わる。小カテゴリをタップすると
/// その [CategoryMasterMinor] を返してシートを閉じる。issue #97.
class CategoryMasterPickerSheet extends StatefulWidget {
  const CategoryMasterPickerSheet({super.key, this.initialMajorKey});

  /// 編集モードで開いたときの初期表示。指定があれば該当 major の minor
  /// 一覧から開始する。
  final String? initialMajorKey;

  static Future<CategoryMasterMinor?> show(
    BuildContext context, {
    String? initialMajorKey,
  }) {
    return showModalBottomSheet<CategoryMasterMinor>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => CategoryMasterPickerSheet(
        initialMajorKey: initialMajorKey,
      ),
    );
  }

  @override
  State<CategoryMasterPickerSheet> createState() =>
      _CategoryMasterPickerSheetState();
}

class _CategoryMasterPickerSheetState extends State<CategoryMasterPickerSheet> {
  CategoryMasterMajor? _selectedMajor;

  @override
  void initState() {
    super.initState();
    if (widget.initialMajorKey != null) {
      _selectedMajor = CategoryMaster.findMajor(widget.initialMajorKey!);
    }
  }

  void _onMajorTap(CategoryMasterMajor major) {
    setState(() => _selectedMajor = major);
  }

  void _onBack() {
    setState(() => _selectedMajor = null);
  }

  void _onMinorTap(CategoryMasterMinor minor) {
    Navigator.of(context).pop(minor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  if (_selectedMajor != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: '戻る',
                      onPressed: _onBack,
                    ),
                  Expanded(
                    child: Text(
                      _selectedMajor == null
                          ? 'カテゴリを選ぶ'
                          : _selectedMajor!.name,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: _selectedMajor == null
                  ? _MajorGrid(onMajorTap: _onMajorTap)
                  : _MinorList(
                      major: _selectedMajor!,
                      onMinorTap: _onMinorTap,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MajorGrid extends StatelessWidget {
  const _MajorGrid({required this.onMajorTap});

  final ValueChanged<CategoryMasterMajor> onMajorTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.6,
      ),
      itemCount: CategoryMaster.majors.length,
      itemBuilder: (context, i) {
        final major = CategoryMaster.majors[i];
        return _MajorButton(major: major, onTap: () => onMajorTap(major));
      },
    );
  }
}

class _MajorButton extends StatelessWidget {
  const _MajorButton({required this.major, required this.onTap});

  final CategoryMasterMajor major;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = CategoryPresets.colorFor(major.colorCode);
    final icon = CategoryPresets.iconFor(major.iconCode);
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color,
                foregroundColor: Colors.white,
                child: Icon(icon, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  major.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MinorList extends StatelessWidget {
  const _MinorList({required this.major, required this.onMinorTap});

  final CategoryMasterMajor major;
  final ValueChanged<CategoryMasterMinor> onMinorTap;

  static final _rateFormatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final minors = CategoryMaster.minorsFor(major.key);
    final theme = Theme.of(context);
    final color = CategoryPresets.colorFor(major.colorCode);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      itemCount: minors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, i) {
        final m = minors[i];
        return ListTile(
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.15),
            foregroundColor: color,
            child: Icon(
              CategoryPresets.iconFor(major.iconCode),
              size: 16,
            ),
          ),
          title: Text(m.name),
          subtitle: Text(
            '推奨時給 ${_rateFormatter.format(m.recommendedRate)} 円/h',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.outline,
          ),
          onTap: () => onMinorTap(m),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
