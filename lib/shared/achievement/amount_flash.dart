import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AmountFlash {
  const AmountFlash._();

  static void show(BuildContext context, int amount) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (_) => _AmountFlashWidget(
        amount: amount,
        onDone: () => entry?.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _AmountFlashWidget extends StatefulWidget {
  const _AmountFlashWidget({required this.amount, required this.onDone});

  final int amount;
  final VoidCallback onDone;

  @override
  State<_AmountFlashWidget> createState() => _AmountFlashWidgetState();
}

class _AmountFlashWidgetState extends State<_AmountFlashWidget>
    with SingleTickerProviderStateMixin {
  static final _formatter = NumberFormat('#,###');

  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _ctrl.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final scale = t < 0.3 ? Curves.elasticOut.transform(t / 0.3) : 1.0;
        final fadeStart = 0.75;
        final opacity = t < fadeStart
            ? 1.0
            : (1.0 - (t - fadeStart) / (1.0 - fadeStart));
        final translateY = -50 * t;
        return Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: Offset(0, translateY),
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.savings,
                            size: 28,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '+ ¥${_formatter.format(widget.amount)}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onPrimaryContainer,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
