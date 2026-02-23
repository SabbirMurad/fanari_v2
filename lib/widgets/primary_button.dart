import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fanari_v2/constants/colors.dart';

class PrimaryButton extends StatefulWidget {
  final bool loading;
  final String text;
  final void Function()? onTap;
  final bool shadow;
  final bool enabled;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final Widget? tailing;

  const PrimaryButton({
    super.key,
    this.loading = false,
    required this.text,
    this.height,
    this.width,
    this.enabled = true,
    this.borderRadius,
    this.onTap,
    this.shadow = true,
    this.backgroundColor,
    this.textStyle,
    this.tailing,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.enabled || widget.loading) return;

        widget.onTap?.call();
      },
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 48.h,
        decoration: BoxDecoration(
          color: widget.enabled
              ? (widget.backgroundColor ?? AppColors.primary)
              : (widget.backgroundColor ?? AppColors.primary).withValues(
                  alpha: 0.65,
                ),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(24.r),
          boxShadow: widget.shadow
              ? [
                  BoxShadow(
                    color: widget.backgroundColor != null
                        ? widget.backgroundColor!.withAlpha(20)
                        : AppColors.primary.withAlpha(20),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: Offset(4.w, 8.h),
                  ),
                ]
              : [],
        ),
        child: widget.loading
            ? Center(
                child: SizedBox(
                  height: 24.w,
                  child: SpinKitWave(color: AppColors.white, size: 24.w),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.text,
                    style:
                        widget.textStyle ??
                        TextStyle(
                          color: AppColors.text,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.tailing != null)
                    Padding(
                      padding: EdgeInsets.only(left: 6.w),
                      child: widget.tailing!,
                    ),
                ],
              ),
      ),
    );
  }
}
