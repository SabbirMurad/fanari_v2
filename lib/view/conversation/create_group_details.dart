import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/prepared_image.dart';
import 'package:fanari_v2/provider/conversation.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/widgets/image_uploader_v_one.dart';
import 'package:fanari_v2/widgets/input_field_v_one.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart' as utils;

class CreateGroupDetails extends ConsumerStatefulWidget {
  final List<String> members;

  const CreateGroupDetails({super.key, required this.members});

  @override
  ConsumerState<CreateGroupDetails> createState() => _CreateGroupDetailsState();
}

class _CreateGroupDetailsState extends ConsumerState<CreateGroupDetails> {
  bool _creatingGroup = false;

  PreparedImage? _groupImage;
  final TextEditingController _nameController = TextEditingController();

  void _createGroup() async {
    if (_creatingGroup) return;

    if (_nameController.text.trim().isEmpty) {
      utils.show_custom_toast(text: 'Please enter group name.');
      return;
    }

    setState(() {
      _creatingGroup = true;
    });

    await ref
        .read(conversationNotifierProvider.notifier)
        .create_group_conversation(
          group_name: _nameController.text.trim(),
          group_image: _groupImage,
          members: widget.members,
        );

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _creatingGroup = false;
      });
      AppRoutes.pop();
      AppRoutes.pop();
    });
  }

  Widget _header() {
    return Row(
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
          onTap: _createGroup,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: _creatingGroup
                ? SizedBox(
                    width: 12.w,
                    height: 12.w,
                    child: CircularProgressIndicator(strokeWidth: 1.w),
                  )
                : Text(
                    'Next',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.text),
                  ),
          ),
        ),
      ],
    );
  }

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
              SafeArea(bottom: false, child: SizedBox(height: 12.h)),
              _header(),
              SizedBox(height: 36.h),
              ImageUploaderVOne(height: 124.w, enable: true),
              SizedBox(height: 24.h),
              InputFieldVOne(
                hintText: 'Group Name',
                controller: _nameController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
