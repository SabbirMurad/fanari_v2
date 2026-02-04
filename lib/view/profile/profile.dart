import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/user.dart';
import 'package:fanari_v2/widgets/image_uploader_v_one.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart' as utils;

class ProfileScreen extends StatefulWidget {
  final String user_id;
  final UserModel? user;

  const ProfileScreen({super.key, required this.user_id, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();

    _loadProfileData();
  }

  void _loadProfileData() async {
    if (widget.user != null) {
      setState(() {
        _user = widget.user!;
      });
      return;
    }

    final response = await utils.CustomHttp.get(
      endpoint: '/profile/profile/${widget.user_id}',
    );

    if (response.statusCode != 200) return;

    final user = UserModel.fromJson(response.data[0]);

    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Text(
                  'Profile',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ImageUploaderVOne(
                height: 104.w,
                currentImage: _user?.profile.profile_picture != null
                    ? CachedNetworkImageProvider(
                        _user!.profile.profile_picture!.webp_url,
                      )
                    : null,
                onImageSelected: (newImage) {},
              ),
              Text(
                _user == null
                    ? ''
                    : _user!.profile.first_name +
                          ' ' +
                          _user!.profile.last_name,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _user?.core.username ?? '',
                style: TextStyle(color: AppColors.text, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
