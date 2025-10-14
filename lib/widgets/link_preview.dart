import 'package:flutter/material.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyLinkPreview extends StatelessWidget {
  final double? imageWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Color? textColor;
  final PreviewData previewData;
  final double? width;

  const MyLinkPreview({
    super.key,
    required this.previewData,
    this.imageWidth,
    this.padding,
    this.width,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: width ?? double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (previewData.title != null)
                    Text(
                      previewData.title!,
                      style: TextStyle(
                        color: textColor ?? AppColors.text,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  SizedBox(height: 8.h),
                  if (previewData.description != null)
                    Text(
                      previewData.description!,
                      style: TextStyle(
                        color: textColor ?? AppColors.text,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (previewData.image != null)
            Container(
              margin: EdgeInsets.only(left: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: previewData.image!.url,
                  width: imageWidth ?? 96.w,
                  height: imageWidth ?? 96.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
