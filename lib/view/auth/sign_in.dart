import 'package:fanari_v2/routes.dart';
import 'package:flutter/material.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/svg_handler.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:fanari_v2/widgets/cross_fade_box.dart';
import 'package:fanari_v2/widgets/primary_button.dart';
import 'package:fanari_v2/widgets/input_field_v_one.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart' as utils;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  List<Widget> _enterPasswordWidgets() {
    return [
      SizedBox(height: 48.h),
      Row(
        children: [
          NamedAvatar(loading: false, name: 'Sabbir', size: 80.w),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sabbir Hassan',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '@sabbir0087',
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
      SizedBox(height: 36.h),
      InputFieldVOne(
        hintText: 'Password',
        controller: _passwordController,
        isPasswordField: true,
      ),
      SizedBox(height: 56.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _emailEntered = false;
              });
            },
            icon: Text(
              'Not your account?',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 28.w),
          PrimaryButton(
            loading: _loading,
            text: 'Confirm',
            onTap: () => AppRoutes.push(AppRoutes.feed),
            width: 130.w,
          ),
        ],
      ),
      SizedBox(height: 72.h),
    ];
  }

  void _getAccountInformation() async {
    if (_emailController.text.isEmpty) {
      utils.showCustomToast(text: 'Please enter your email or username.');
      return;
    }

    final email = _emailController.text.trim().toLowerCase();

    setState(() {
      _loading = true;
    });

    final response = await utils.CustomHttp.get(
      endpoint: '/auth/user/$email',
      needAuth: false,
    );

    if (response.statusCode == 200) {
      print('');
      print(response.data);
      print('');
    }

    print('');
    print(response.error);
    print('');

    setState(() {
      _loading = false;
    });

    // setState(() {
    //   _emailEntered = true;
    // });
    // _goToNextPage();
  }

  List<Widget> _enterEmailWidgets() {
    return [
      SizedBox(height: 72.h),
      InputFieldVOne(
        hintText: 'Email or Username',
        controller: _emailController,
      ),
      SizedBox(height: 56.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => AppRoutes.push(AppRoutes.sign_up),
            icon: Text(
              'Create Account',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 28.w),
          PrimaryButton(
            loading: _loading,
            text: 'Next',
            onTap: _getAccountInformation,
            width: 130.w,
          ),
        ],
      ),
    ];
  }

  //TODO: this is temp
  bool _emailEntered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.surface,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 0.12.sh),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Svg.asset(
                    'assets/icons/logo.svg',
                    width: 28.w,
                    color: AppColors.primary,
                  ),
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
                'Sign In',
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
              if (!_emailEntered) ..._enterEmailWidgets(),
              if (_emailEntered) ..._enterPasswordWidgets(),
            ],
          ),
        ),
      ),
    );
  }
}
