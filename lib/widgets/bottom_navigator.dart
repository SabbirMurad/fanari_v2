import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  ConsumerState<CustomBottomNavigator> createState() => _CustomBottomNavigatorState();
}

class _CustomBottomNavigatorState extends ConsumerState<CustomBottomNavigator> {
  late int? _selectedNavIndex = widget.selectedNavIndex;

  final _iconSize = 0.020;
  final _profileSize = 0.028;

  Widget _navItem(String name, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });

        widget.onNavChange?.call(index);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/bottom_nav/${name.toLowerCase()}${_selectedNavIndex == index ? '_fill' : ''}.svg',
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.tertiary,
                BlendMode.srcIn,
              ),
              width: _iconSize.sh,
              height: _iconSize.sh,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: 10,
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
      padding: const EdgeInsets.only(left: 32, right: 32, top: 8),
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        bottom: true,
        top: false,
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
                    width: 0.028.sh,
                    height: 0.028.sh,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.tertiary,
                        width: 1.48,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Post',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            _navItem('Notification', 2),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}