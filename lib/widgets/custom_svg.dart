import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvg extends StatelessWidget {
  final Color? color;
  final BlendMode blendMode;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double? size;
  final String path;
  final VoidCallback? onTap;

  const CustomSvg(
    this.path, {
    super.key,
    this.color,
    this.blendMode = BlendMode.srcIn,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final svg = SvgPicture.asset(
      path,
      colorFilter: color == null ? null : ColorFilter.mode(color!, blendMode),
      width: width ?? size ?? 24.w,
      height: width ?? size ?? 24.w,
      fit: fit,
    );

    return onTap == null ? svg : InkWell(onTap: onTap, child: svg);
  }
}
