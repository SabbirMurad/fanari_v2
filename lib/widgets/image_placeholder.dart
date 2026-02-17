import 'package:fanari_v2/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class ImagePlaceholder extends StatelessWidget {
  final String blur_hash;
  final double? width;
  final double? height;

  const ImagePlaceholder({
    super.key,
    required this.blur_hash,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      child: BlurHash(
        hash: blur_hash,
        color: AppColors.secondary,
        optimizationMode: BlurHashOptimizationMode.approximation,
      ),
    );
  }
}
