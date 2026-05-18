import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedAmount extends StatefulWidget {
  const AnimatedAmount({
    super.key,
    required this.amount,
    this.style,
    this.suffix = ' 円',
    this.duration = const Duration(milliseconds: 500),
  });

  final int amount;
  final TextStyle? style;
  final String suffix;
  final Duration duration;

  @override
  State<AnimatedAmount> createState() => _AnimatedAmountState();
}

class _AnimatedAmountState extends State<AnimatedAmount> {
  static final _formatter = NumberFormat('#,###');

  int _previous = 0;

  @override
  void didUpdateWidget(AnimatedAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previous = oldWidget.amount;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      tween: IntTween(begin: _previous, end: widget.amount),
      builder: (context, value, _) {
        return Text(
          '${_formatter.format(value)}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
