import 'package:fanari_v2/constants/colors.dart';
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
        color: color ?? AppColors.secondary,
        borderRadius: borderRadius,
        shape: shape ?? BoxShape.rectangle,
      ),
    );
  }
}
