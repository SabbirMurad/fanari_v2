import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlassContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double? blurStrength;
  final BorderRadius? borderRadius;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    this.width,
    this.height,
    this.blurStrength,
    this.borderRadius,
    this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          borderRadius ?? BorderRadius.circular(20.r), // Rounded corners
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurStrength ?? 6,
          sigmaY: blurStrength ?? 6,
        ), // Glass blur
        child: Container(
          width: width,
          height: height,
          padding: padding,
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(20.r),
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 83, 83, 83).withValues(alpha: 0.4),
                const Color.fromARGB(255, 83, 83, 83).withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
