import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/widgets/primary_button.dart';
import 'package:fanari_v2/widgets/svg_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 240.h),
            Svg.asset('assets/icons/logo.svg', width: 80.w),
            SizedBox(height: 36.h),
            Text(
              'Welcome to Fanari',
              style: TextStyle(
                fontSize: 31.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 36.h),
            Text(
              'Fanari is a open source project for the vast group of people who are developers, gamers and anime fan',
              style: TextStyle(fontSize: 14.sp, color: AppColors.text),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 178.h),
            PrimaryButton(
              text: 'Explore',
              width: 288.w,
              onTap: () {
                AppRoutes.push(AppRoutes.sign_up);
              },
            ),
          ],
        ),
      ),
    );
  }
}
