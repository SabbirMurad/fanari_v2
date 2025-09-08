import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommentInputWidget extends StatefulWidget {
  const CommentInputWidget({super.key});

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  Widget _inputContainer() {
    return Container(
      width: double.infinity,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          CustomSvg('assets/icons/emoji.svg', width: 20.w, height: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: 'Write here ...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
                isDense: true,
              ),
              style: TextStyle(color: AppColors.text, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withValues(alpha: 0.85),
            AppColors.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: 8.h,
            left: 20.w,
            right: 20.w,
            bottom: 8.h,
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomSvg(
                    'assets/icons/attachment.svg',
                    width: 18.w,
                    height: 18.w,
                    color: AppColors.text,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(child: _inputContainer()),
              SizedBox(width: 12.w),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomSvg(
                    'assets/icons/send.svg',
                    width: 18.w,
                    height: 18.w,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
