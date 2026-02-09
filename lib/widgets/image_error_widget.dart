import 'package:fanari_v2/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageErrorWidget extends StatelessWidget {
  final String blur_hash;

  const ImageErrorWidget({super.key, required this.blur_hash});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          BlurHash(
            hash: blur_hash,
            color: AppColors.secondary,
            optimizationMode: BlurHashOptimizationMode.approximation,
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              decoration: BoxDecoration(
                color: Color.fromRGBO(24, 24, 24, 0.6),
                border: Border.all(color: Colors.white.withValues(alpha: .1)),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(24, 24, 24, .2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Couldn\'t load image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
