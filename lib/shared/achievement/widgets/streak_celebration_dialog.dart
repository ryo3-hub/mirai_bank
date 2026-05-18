import 'dart:async';

import 'package:flutter/material.dart';

class StreakCelebrationDialog extends StatefulWidget {
  const StreakCelebrationDialog({super.key, required this.days});

  final int days;

  static Future<void> show(BuildContext context, {required int days}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => StreakCelebrationDialog(days: days),
    );
  }

  @override
  State<StreakCelebrationDialog> createState() =>
      _StreakCelebrationDialogState();
}

class _StreakCelebrationDialogState extends State<StreakCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scale;
  Timer? _autoDismiss;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale.forward();
    _autoDismiss = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _scale,
                curve: Curves.elasticOut,
              ),
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.deepOrange,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _scale,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.days}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.deepOrange,
                      ),
                    ),
                    TextSpan(
                      text: '日連続達成！',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'コツコツの積み上げが続いています',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
