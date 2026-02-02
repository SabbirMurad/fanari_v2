import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/providers/myself.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Widget _settingsOption({
    required String icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 12.w),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              child: Center(
                child: CustomSvg(icon, width: 24.w, height: 24.w),
              ),
            ),
            SizedBox(width: 18.w),
            Text(
              text,
              style: TextStyle(color: AppColors.text, fontSize: 16.sp),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18.w,
              color: AppColors.text,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myself = ref
        .watch(myselfNotifierProvider)
        .when(
          data: (data) => data,
          error: (error, stackTrace) => null,
          loading: () => null,
        );

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(bottom: false, child: SizedBox(height: 48.h)),
            Row(
              children: [
                NamedAvatar(
                  loading: myself == null,
                  name: myself == null ? 'Loading' : myself.profile.first_name,
                  size: 72.w,
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      myself == null
                          ? 'Loading'
                          : myself.profile.first_name +
                                ' ' +
                                myself.profile.last_name,
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '@${myself == null ? 'Loading' : myself.core.username}',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 48.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 18.w, horizontal: 24.w),
              child: Column(
                children: [
                  _settingsOption(
                    icon: 'assets/icons/settings/user.svg',
                    text: 'Profile',
                    onTap: () {
                      AppRoutes.push(AppRoutes.profileSettings);
                    },
                  ),
                  _settingsOption(
                    icon: 'assets/icons/settings/payment.svg',
                    text: 'Subscriptions',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 18.w, horizontal: 24.w),
              child: Column(
                children: [
                  _settingsOption(
                    icon: 'assets/icons/settings/notification.svg',
                    text: 'Notifications',
                    onTap: () {
                      AppRoutes.push(AppRoutes.notificationSettings);
                    },
                  ),
                  _settingsOption(
                    icon: 'assets/icons/settings/visible.svg',
                    text: 'Color & Themes',
                    onTap: () {},
                  ),
                  _settingsOption(
                    icon: 'assets/icons/settings/language.svg',
                    text: 'Language',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 18.w, horizontal: 24.w),
              child: Column(
                children: [
                  _settingsOption(
                    icon: 'assets/icons/settings/lock.svg',
                    text: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _settingsOption(
                    icon: 'assets/icons/settings/lock.svg',
                    text: 'Terms of Service',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 18.w, horizontal: 24.w),
              child: Column(
                children: [
                  _settingsOption(
                    icon: 'assets/icons/settings/visible.svg',
                    text: 'Reports',
                    onTap: () {},
                  ),
                  _settingsOption(
                    icon: 'assets/icons/settings/language.svg',
                    text: 'Support',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 24.w),
              child: Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    child: Center(
                      child: CustomSvg(
                        'assets/icons/settings/logout.svg',
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Text(
                    'Logout',
                    style: TextStyle(color: AppColors.text, fontSize: 16.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 84.h),
          ],
        ),
      ),
    );
  }
}
