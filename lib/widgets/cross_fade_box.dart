import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ColorFadeBox extends StatefulWidget {
  final Color color1;
  final Color color2;
  final Duration duration;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ColorFadeBox({
    super.key,
    this.color1 = const Color.fromARGB(255, 46, 48, 53),
    this.color2 = const Color.fromARGB(255, 55, 57, 61),
    this.borderRadius,
    this.duration = const Duration(milliseconds: 2000),
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  State<ColorFadeBox> createState() => _ColorFadeBoxState();
}

class _ColorFadeBoxState extends State<ColorFadeBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      animationBehavior: AnimationBehavior.preserve,
    )..repeat(reverse: true); // 👈 smoothly goes back and forth

    _colorAnimation = ColorTween(
      begin: widget.color1,
      end: widget.color2,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width ?? 40.w,
          height: widget.height ?? 40.w,
          padding: widget.padding,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(20.r),
          ),
        );
      },
    );
  }
}
