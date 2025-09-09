import 'package:fanari_v2/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class SecondaryAppBar extends StatelessWidget {
  final String title;
  final String? icon;
  final EdgeInsetsGeometry? padding;

  const SecondaryAppBar({
    super.key,
    required this.title,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20.sp,
                color: AppColors.text,
              ),
            ),
            const SizedBox(width: 12),
            if (icon != null)
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: SvgPicture.asset(
                  icon!,
                  width: 20.w,
                  height: 20.w,
                  color: AppColors.text,
                  fit: BoxFit.contain,
                ),
              ),
            Text(
              title,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
