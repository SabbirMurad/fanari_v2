import 'package:flutter/material.dart';

class BouncingDots extends StatefulWidget {
  final double dotSize;
  final double gap;
  final Color? color;
  final int dotCount;
  final double bounceHeight;
  final double delay;
  final Duration duration;

  const BouncingDots({
    Key? key,
    this.dotSize = 8,
    this.gap = 8,
    this.color,
    this.dotCount = 3,
    this.bounceHeight = 12.0,
    this.delay = 0.2,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<BouncingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this, // Ensures proper ticker support
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        final delay = index * widget.delay; // Adds a delay for each dot
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final animationValue = (_controller.value + delay) % 1.0;
            final offset = (animationValue <= 0.5
                    ? animationValue
                    : 1.0 - animationValue) *
                widget.bounceHeight; // Bounce height
            return Transform.translate(
              offset: Offset(0, -offset),
              child: child,
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: widget.gap / 2),
            height: widget.dotSize,
            width: widget.dotSize,
            decoration: BoxDecoration(
              color: widget.color ?? Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(widget.dotSize / 2),
            ),
          ),
        );
      }),
    );
  }
}
