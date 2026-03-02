import 'dart:math';
import 'package:fanari_v2/provider/author.dart';
import 'package:flutter/material.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/view/create_post/create_post.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class CustomBottomNavigator extends ConsumerStatefulWidget {
  final int? selectedNavIndex;
  final void Function()? onProfileTap;
  final void Function(int)? onNavChange;

  const CustomBottomNavigator({
    super.key,
    required this.selectedNavIndex,
    this.onProfileTap,
    required this.onNavChange,
  });

  @override
  ConsumerState<CustomBottomNavigator> createState() =>
      _CustomBottomNavigatorState();
}

class _CustomBottomNavigatorState extends ConsumerState<CustomBottomNavigator> {
  Widget _navItem(String name, int index) {
    return GestureDetector(
      onTap: () {
        widget.onNavChange?.call(index);
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSvg(
              'assets/icons/bottom_nav/${name.toLowerCase()}${widget.selectedNavIndex == index ? '_fill' : ''}.svg',
              color: AppColors.text,
              height: 20.h,
              width: 20.h,
              fit: BoxFit.fitHeight,
            ),
            SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 10.sp,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myself = ref.watch(authorNotifierProvider);

    return SafeArea(
      bottom: true,
      top: false,
      child: Container(
        margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12.w),
        child: LiquidGlass(
          settings: LiquidGlassSettings(
            blur: 4,
            ambientStrength: 3,
            lightAngle: -0.2 * pi,
            glassColor: Colors.white12,
            thickness: 35,
          ),
          shape: LiquidRoundedRectangle(borderRadius: Radius.circular(12.r)),
          glassContainsChild: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 12.w,
              bottom: 12.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _navItem('Home', 0),
                _navItem('Search', 1),
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) {
                          return CreatePostScreen();
                        },
                      ),
                    );
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24.h,
                        height: 24.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.text,
                            width: 1.48,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColors.text,
                          size: 16.w,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Post',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                _navItem('Market', 2),
                GestureDetector(
                  onTap: () {
                    // if (user != null) {
                    // Scaffold.of(context).openDrawer();
                    // widget.onProfileTap?.call();
                    // setState(() {
                    //   _selectedNavIndex = 3;
                    // });

                    widget.onNavChange?.call(3);
                    // }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      myself.when(
                        data: (user) {
                          return NamedAvatar(
                            loading: user == null,
                            image: user?.profile.profile_picture,
                            name: user?.profile.first_name ?? 'Loading name',
                            size: 24.h,
                            backgroundColor: AppColors.surface,
                            onTap: () {
                              if (user != null) {
                                // Scaffold.of(context).openDrawer();
                                // widget.onProfileTap?.call();
                                // setState(() {
                                //   _selectedNavIndex = 3;
                                // });

                                widget.onNavChange?.call(3);
                              }
                            },
                          );
                        },
                        error: (object, stack) {
                          return Container(
                            width: 24.h,
                            height: 24.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                            ),
                          );
                        },
                        loading: () {
                          return Container(
                            width: 24.h,
                            height: 24.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
