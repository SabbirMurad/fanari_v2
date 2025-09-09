import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/custom_switch.dart';
import 'package:fanari_v2/widgets/secondary_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  Widget _notificationItem({required String title, required String text}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 36.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.7),
                    fontSize: 13.sp,
                  ),
                ),
              ),
              SizedBox(width: 36.w),
              CustomSwitch(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.surface,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SecondaryAppBar(
                title: 'Notification',
                icon: 'assets/icons/settings/notification.svg',
                padding: EdgeInsets.symmetric(vertical: 18.h),
              ),
              SizedBox(height: 24.h),
              _notificationItem(
                title: 'Appreciations',
                text:
                    'Get an notification every time someone likes one of your posts comments or replies',
              ),
              _notificationItem(
                title: 'Comments',
                text:
                    'Get an notification every time someone comments or replies to your posts or comments',
              ),
              _notificationItem(
                title: 'Tags',
                text:
                    'Get an notification every time someone tags you in a comment or replies',
              ),
              _notificationItem(
                title: 'Order',
                text:
                    'Get a notification when someone orders one of your product',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
