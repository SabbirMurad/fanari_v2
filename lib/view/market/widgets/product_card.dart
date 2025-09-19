import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/product.dart';
import 'package:fanari_v2/widgets/cross_fade_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart' as utils;

class ProductCard extends StatefulWidget {
  final ProductModel model;

  const ProductCard({super.key, required this.model});

  @override
  State<ProductCard> createState() => _ProductCardState();

  static Widget skeleton() {
    return Container(
      width: (1.sw - 40.w - 18.w) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColorFadeBox(
            width: (1.sw - 40.w - 18.w) / 2,
            height: (1.sw - 40.w - 18.w) / 2,
            borderRadius: BorderRadius.circular(6.r),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6.w, bottom: 6.w),
            child: ColorFadeBox(
              width: (1.sw - 40.w - 18.w) / 2,
              height: 13.h,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 6.w),
            child: ColorFadeBox(
              width: (1.sw - 40.w - 18.w) / 4,
              height: 13.h,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          Row(
            children: [
              ColorFadeBox(
                width: 36.w,
                height: 16.h,
                borderRadius: BorderRadius.circular(6.r),
              ),
              Spacer(),
              ColorFadeBox(
                width: 72.w,
                height: 18.h,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: (1.sw - 40.w - 18.w) / 2,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: CachedNetworkImage(
              imageUrl: widget.model.image.url,
              width: (1.sw - 40.w - 18.w) / 2,
              height: (1.sw - 40.w - 18.w) / 2,
              fit: BoxFit.cover,
              placeholder: (context, url) {
                return ColorFadeBox(
                  width: (1.sw - 40.w - 18.w) / 2,
                  height: (1.sw - 40.w - 18.w) / 2,
                  borderRadius: BorderRadius.circular(6.r),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 6.w, top: 6.w, bottom: 6.w),
            child: Text(
              widget.model.title,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 13.sp,
                height: 1.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 6.w, right: 6.w),
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: Color(0xffE9D449), size: 20.w),
                Text(
                  '${widget.model.rating / 10}',
                  style: TextStyle(color: AppColors.text, fontSize: 16.sp),
                ),
                Spacer(),
                Text(
                  '\$${utils.formatNumberMagnitude(widget.model.price / 100)}',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
