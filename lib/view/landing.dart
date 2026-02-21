import 'package:fanari_v2/constants/local_storage.dart';
import 'package:fanari_v2/providers/author.dart';
import 'package:fanari_v2/routes.dart';
import 'package:flutter/material.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/primary_button.dart';
import 'package:fanari_v2/widgets/svg_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  @override
  void initState() {
    super.initState();

    _initiateStartup();
  }

  bool _loading = false;

  void _initiateStartup() async {
    final access_token = await LocalStorage.access_token.get();

    if (access_token == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    final success = await ref
        .read(authorNotifierProvider.notifier)
        .loadAuthorDetails();

    if (success) {
      setState(() {
        _loading = false;
      });

      AppRoutes.go(AppRoutes.feed);
    }
  }

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
            Svg.asset(
              'assets/icons/logo.svg',
              width: 80.w,
              color: AppColors.primary,
            ),
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
            if (!_loading)
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
