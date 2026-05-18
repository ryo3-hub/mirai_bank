import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/category.dart';
import '../domain/category_presets.dart';

class CategoryPickerSheet extends StatelessWidget {
  const CategoryPickerSheet({
    super.key,
    required this.categories,
    this.selectedId,
  });

  final List<Category> categories;
  final String? selectedId;

  static Future<Category?> show(
    BuildContext context, {
    required List<Category> categories,
    String? selectedId,
  }) {
    return showModalBottomSheet<Category>(
      context: context,
      showDragHandle: true,
      builder: (_) => CategoryPickerSheet(
        categories: categories,
        selectedId: selectedId,
      ),
    );
  }

  static final _rateFormatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedId;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: CategoryPresets.colorFor(category.colorCode),
              foregroundColor: Colors.white,
              child: Icon(CategoryPresets.iconFor(category.iconCode)),
            ),
            title: Text(category.name),
            subtitle:
                Text('${_rateFormatter.format(category.hourlyRate)} 円/h'),
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(category),
          );
        },
      ),
    );
  }
}
