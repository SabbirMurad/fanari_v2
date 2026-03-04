import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/widgets/image_uploader_v_one.dart';
import 'package:fanari_v2/widgets/input_field_v_one.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateGroupDetails extends StatefulWidget {
  const CreateGroupDetails({super.key});

  @override
  State<CreateGroupDetails> createState() => _CreateGroupDetailsState();
}

class _CreateGroupDetailsState extends State<CreateGroupDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => AppRoutes.pop(),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 20.w,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Enter Group Details',
                      style: TextStyle(color: AppColors.text, fontSize: 19.sp),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        // if (_selectedUsers.isNotEmpty) {
                        //   Navigator.of(context).push(
                        //     MaterialPageRoute(
                        //       builder: (_) {
                        //         return CreateGroupDetails();
                        //       },
                        //     ),
                        //   );
                        // }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36.h),
              ImageUploaderVOne(height: 124.w, enable: true),
              SizedBox(height: 24.h),
              InputFieldVOne(
                hintText: 'Group Name',
                controller: TextEditingController(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
