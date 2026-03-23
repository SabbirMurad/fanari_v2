import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class UserProfile {
  final String name;
  final String phone;
  final String avatarInitials;
  final Color avatarColor;
  final bool isOnline;
  final List<String> sharedMediaUrls;

  const UserProfile({
    required this.name,
    required this.phone,
    required this.avatarInitials,
    required this.avatarColor,
    required this.isOnline,
    this.sharedMediaUrls = const [],
  });
}

// ── DM Profile Screen ─────────────────────────────────────────────────────────

class DMProfileView extends StatelessWidget {
  final UserProfile user;

  const DMProfileView({super.key, required this.user});

  // ── quick-action button ──────────────────────────────────────────────────
  Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 22.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── info row (icon + label + optional trailing) ───────────────────────────
  Widget _infoTile({
    required IconData icon,
    required String title,
    String? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 22.sp, color: titleColor ?? Colors.black87),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: titleColor ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
            if (onTap != null && trailing != null)
              Icon(Icons.chevron_right, size: 18.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ── shared media grid ────────────────────────────────────────────────────
  Widget _sharedMediaSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shared Media',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () {},
                child: Text('See all', style: TextStyle(fontSize: 13.sp)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 6.w : 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      height: 80.h,
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                        size: 28.sp,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ── App bar ────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56.h,
        leading: BackButton(
          color: Colors.black87,
          style: ButtonStyle(iconSize: WidgetStatePropertyAll(24.sp)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black87, size: 24.sp),
            onPressed: () {},
          ),
        ],
      ),

      body: ListView(
        children: [
          // ── Avatar + name + status ───────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 44.r,
                      backgroundColor: user.avatarColor,
                      child: Text(
                        user.avatarInitials,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Online indicator dot
                    Positioned(
                      bottom: 3.h,
                      right: 3.w,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                          color: user.isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5.w),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8.sp,
                      color: user.isOnline ? Colors.green : Colors.grey,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      user.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: user.isOnline ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  user.phone,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
                SizedBox(height: 20.h),

                // ── Quick actions ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _actionButton(
                      context: context,
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Message',
                      onTap: () {},
                    ),
                    SizedBox(width: 28.w),
                    _actionButton(
                      context: context,
                      icon: Icons.call_outlined,
                      label: 'Call',
                      onTap: () {},
                    ),
                    SizedBox(width: 28.w),
                    _actionButton(
                      context: context,
                      icon: Icons.videocam_outlined,
                      label: 'Video',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F7)),

          // ── Shared media ──────────────────────────────────────────────────
          _sharedMediaSection(context),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F7)),

          // ── Settings rows ──────────────────────────────────────────────
          _infoTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            trailing: 'On',
            onTap: () {},
          ),
          Divider(
            indent: 56.w,
            height: 1,
            thickness: 1,
            color: const Color(0xFFF0F2F7),
          ),
          _infoTile(
            icon: Icons.lock_outline_rounded,
            title: 'Encryption',
            trailing: 'End-to-end',
            onTap: () {},
          ),
          Divider(
            indent: 56.w,
            height: 1,
            thickness: 1,
            color: const Color(0xFFF0F2F7),
          ),
          _infoTile(
            icon: Icons.search_rounded,
            title: 'Search in conversation',
            onTap: () {},
          ),
          Divider(
            indent: 56.w,
            height: 1,
            thickness: 1,
            color: const Color(0xFFF0F2F7),
          ),
          _infoTile(
            icon: Icons.block_rounded,
            title: 'Block User',
            titleColor: Colors.red,
            onTap: () => _showBlockDialog(context),
          ),
          Divider(
            indent: 56.w,
            height: 1,
            thickness: 1,
            color: const Color(0xFFF0F2F7),
          ),
          _infoTile(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Conversation',
            titleColor: Colors.red,
            onTap: () {},
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  // ── Block confirmation dialog ────────────────────────────────────────────
  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        titleTextStyle: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        contentTextStyle: TextStyle(fontSize: 14.sp, color: Colors.black54),
        title: Text('Block ${user.name}?'),
        content: Text(
          '${user.name} will no longer be able to send you messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Block',
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
