import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/view/settings/widgets/profile_edit_option.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/secondary_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
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
                title: 'Edit Profile',
                icon: 'assets/icons/settings/user.svg',
                padding: EdgeInsets.symmetric(vertical: 18.h),
              ),
              SizedBox(height: 24.h),
              ProfileEditOption(
                title: 'Full name',
                subTitle: 'Sabbir Hassan',
                canEdit: true,
                onEditClick: () {},
              ),
              ProfileEditOption(title: 'Username', subTitle: 'sabbir0087'),
              ProfileEditOption(
                title: 'Email address',
                subTitle: 'sbbir0087@gmail.com',
              ),
              ProfileEditOption(
                title: 'Phone number',
                subTitle: '+8801705738128',
                canEdit: true,
                onEditClick: () {},
              ),
              ProfileEditOption(
                title: 'Gender',
                subTitle: 'Male',
                canEdit: true,
                onEditClick: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1980),
                    lastDate: DateTime.now(),
                    initialDate: DateTime(2000),
                  );
                  
                },
              ),
              ProfileEditOption(
                title: 'Date of birth',
                subTitle: '19 Nov 2000',
                canEdit: true,
                onEditClick: () {},
              ),
              ProfileEditOption(
                title: 'Country',
                subTitle: 'Bangladesh',
                canEdit: true,
                onEditClick: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
