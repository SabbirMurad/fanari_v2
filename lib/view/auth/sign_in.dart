import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/svg_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.surface,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 0.12.sh),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Svg.asset('assets/icons/logo.svg', width: 28.w),
                  SizedBox(width: 12.h),
                  Text(
                    'Fanari',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.08.sh),
              Text(
                'Sign Up',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Create a account to get started with your journey',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(height: 0.55.sh),
            ],
          ),
        ),
      ),
    );
  }
}
