import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Svg {
  Svg._();

  static Widget asset(
    String path, {
    Color? color,
    BlendMode? blendMode,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      colorFilter:
          color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
