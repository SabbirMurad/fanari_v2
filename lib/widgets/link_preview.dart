import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyLinkPreview extends StatelessWidget {
  final String? title;
  final String? description;
  final String? image;
  final double? imageWidth;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Color? textColor;

  const MyLinkPreview({
    super.key,
    this.title,
    this.description,
    this.image,
    this.imageWidth,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
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
                  if (title != null)
                    Text(
                      title!,
                      style: TextStyle(
                        color:
                            textColor ?? AppColors.text,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  SizedBox(height: 8.h),
                  if (description != null)
                    Text(
                      description!,
                      style: TextStyle(
                        color:
                            textColor ?? AppColors.text,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (image != null)
            Container(
              margin: EdgeInsets.only(left: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: image!,
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
