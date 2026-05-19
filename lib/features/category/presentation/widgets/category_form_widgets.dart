import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/category.dart';
import '../../domain/category_presets.dart';

/// Text field for entering a category name.
/// Shares label / placeholder / validator across onboarding and the edit sheet.
class CategoryNameField extends StatelessWidget {
  const CategoryNameField({
    super.key,
    required this.controller,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: const InputDecoration(
        labelText: 'カテゴリ名',
        hintText: '例：プログラミング、英語、資格',
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      maxLength: Category.nameMaxLength,
      validator: Category.validateName,
    );
  }
}

/// Numeric field for entering the hourly rate (円).
/// Forces digits-only input and runs the shared validator.
class CategoryHourlyRateField extends StatelessWidget {
  const CategoryHourlyRateField({
    super.key,
    required this.controller,
    this.focusNode,
    this.helperText,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;

  /// Optional helper text shown beneath the field.
  /// Onboarding passes contextual copy; the edit sheet omits it.
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: '時給（円）',
        helperText: helperText,
        suffixText: '円/h',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: Category.validateHourlyRate,
    );
  }
}

/// Section label shown above pickers ("アイコン" / "カラー").
class CategoryFormSectionLabel extends StatelessWidget {
  const CategoryFormSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

/// Wrap-grid picker for choosing a preset category icon.
class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker({
    super.key,
    required this.selected,
    required this.color,
    required this.onChanged,
  });

  final String selected;
  final Color color;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: CategoryPresets.icons.entries.map((entry) {
        final isSelected = entry.key == selected;
        return GestureDetector(
          onTap: () => onChanged(entry.key),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              entry.value,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Wrap-grid picker for choosing a preset category color.
class CategoryColorPicker extends StatelessWidget {
  const CategoryColorPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: CategoryPresets.colors.map((hex) {
        final color = CategoryPresets.colorFor(hex);
        final isSelected = hex == selected;
        return GestureDetector(
          onTap: () => onChanged(hex),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
