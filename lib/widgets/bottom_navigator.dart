import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    // final user = ref.watch(userNotifierProvider);

    // final hasUnseenNotifications = ref
    //     .watch(notificationsNotifierProvider)
    //     .when(
    //       data: (data) {
    //         return data.any((element) => !element.seen);
    //       },
    //       error: (error, stackTrace) => false,
    //       loading: () => false,
    //     );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.85),
            AppColors.secondary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 12.w,
            bottom: 8.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _navItem('Home', 0),
              _navItem('Search', 1),
              GestureDetector(
                onTap: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (_) {
                  //       return CreatePost(
                  //         onPostCreated: () {
                  //           //TODO:
                  //         },
                  //       );
                  //     },
                  //   ),
                  // );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24.h,
                      height: 24.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.text, width: 1.48),
                      ),
                      child: Icon(Icons.add, color: AppColors.text, size: 16.w),
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
                    NamedAvatar(
                      loading: false,
                      name: 'Sabbir Hassan',
                      size: 24.h,
                      backgroundColor: AppColors.surface,
                    ),
                    // user.when(
                    //   data: (user) {
                    //     return NamedAvatar(
                    //       loading: user == null,
                    //       imageUrl: user?.profilePicture?.url,
                    //       name: user?.fullName ?? 'Loading name',
                    //       size: _profileSize.sh,
                    //       onTap: () {
                    //         if (user != null) {
                    //           // Scaffold.of(context).openDrawer();
                    //           // widget.onProfileTap?.call();
                    //           setState(() {
                    //             _selectedNavIndex = 3;
                    //           });

                    //           widget.onNavChange?.call(3);
                    //         }
                    //       },
                    //     );
                    //   },
                    //   error: (object, stack) {
                    //     return Container(
                    //       width: _profileSize.sh,
                    //       height: _profileSize.sh,
                    //       decoration: BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         color: Theme.of(context).colorScheme.secondary,
                    //       ),
                    //       child: Center(
                    //         child: Icon(
                    //           Icons.error_outline_rounded,
                    //           color: Theme.of(context).colorScheme.error,
                    //           size: 20,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   loading: () {
                    //     return Container(
                    //       width: _profileSize.sh,
                    //       height: _profileSize.sh,
                    //       decoration: BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         color: Theme.of(context).colorScheme.secondary,
                    //       ),
                    //     );
                    //   },
                    // ),
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
    );
  }
}
