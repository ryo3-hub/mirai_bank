import 'package:flutter/material.dart';

/// カテゴリ追加 / オンボーディングで使う「入力モード」。
///
/// `preset` … マスタから選ぶ（名前 / 時給は自動入力されるため画面に出さない）。
/// `custom` … 名前と時給を自分で入力する。
enum CategoryEditMode { preset, custom }

/// `CategoryEditSheet` と `OnboardingPage` で共有する SegmentedButton。
///
/// 端末幅が狭くてもラベルが折り返さないよう、短いラベルにしている
/// （issue #97 のフィードバック）。
class CategoryEditModeSelector extends StatelessWidget {
  const CategoryEditModeSelector({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final CategoryEditMode mode;
  final ValueChanged<CategoryEditMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CategoryEditMode>(
      segments: const [
        ButtonSegment(
          value: CategoryEditMode.preset,
          label: Text('プリセット'),
          icon: Icon(Icons.auto_awesome_outlined),
        ),
        ButtonSegment(
          value: CategoryEditMode.custom,
          label: Text('カスタム'),
          icon: Icon(Icons.edit_outlined),
        ),
      ],
      selected: {mode},
      showSelectedIcon: false,
      onSelectionChanged: (set) => onChanged(set.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
