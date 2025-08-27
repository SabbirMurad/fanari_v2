import 'package:flutter/material.dart';

class CustomSkeleton extends StatelessWidget {
  final double height;
  final double width;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxShape? shape;

  const CustomSkeleton({
    super.key,
    required this.height,
    required this.width,
    this.color,
    this.borderRadius,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.secondary,
        borderRadius: borderRadius,
        shape: shape ?? BoxShape.rectangle,
      ),
    );
  }
}
