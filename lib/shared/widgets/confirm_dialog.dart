import 'package:flutter/material.dart';

Future<bool> showDeleteConfirmDialog({
  required BuildContext context,
  String title = '削除しますか？',
  required String message,
  String cancelLabel = 'キャンセル',
  String deleteLabel = '削除',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return AlertDialog(
        icon: Icon(
          Icons.delete_outline,
          color: colorScheme.error,
          size: 32,
        ),
        title: Text(title),
        content: Text(message, textAlign: TextAlign.center),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(deleteLabel),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
  return ok == true;
}
