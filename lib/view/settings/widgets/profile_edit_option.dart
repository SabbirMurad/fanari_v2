import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileEditOption extends StatefulWidget {
  final String title;
  final String? subTitle;
  final bool canEdit;
  final bool canSwitch;
  final bool switchValue;

  final Function(bool)? onSwitch;
  final Function()? onEditClick;

  const ProfileEditOption({
    super.key,
    required this.title,
    required this.subTitle,
    this.canEdit = false,
    this.canSwitch = false,
    this.switchValue = false,
    this.onEditClick,

    this.onSwitch,
  });

  @override
  State<ProfileEditOption> createState() => _ProfileEditOptionState();
}

class _ProfileEditOptionState extends State<ProfileEditOption> {
  late bool switchValue;

  @override
  void initState() {
    super.initState();
    switchValue = widget.switchValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 18.h),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.subTitle ?? 'Not Selected',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (widget.canEdit)
            IconButton(
              onPressed: () {
                widget.onEditClick?.call();
              },
              padding: EdgeInsets.zero,
              icon: CustomSvg(
                'assets/icons/edit.svg',
                width: 20.w,
                height: 20.w,
                color: AppColors.text,
              ),
            ),
          if (widget.canSwitch)
            SizedBox(
              height: 36.h,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Switch(
                  value: switchValue,
                  onChanged: (value) {
                    setState(() {
                      switchValue = value;
                    });
                    widget.onSwitch?.call(switchValue);
                  },
                  activeColor: AppColors.primary,
                  inactiveTrackColor: AppColors.text,
                  inactiveThumbColor: AppColors.secondary,
                  trackOutlineColor: WidgetStateColor.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
