import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Models ────────────────────────────────────────────────────────────────────

enum MemberRole { admin, member }

class GroupMember {
  final String name;
  final String avatarInitials;
  final Color avatarColor;
  final MemberRole role;
  final bool isOnline;

  const GroupMember({
    required this.name,
    required this.avatarInitials,
    required this.avatarColor,
    required this.role,
    this.isOnline = false,
  });
}

class GroupInfo {
  final String name;
  final String description;
  final String avatarInitials;
  final Color avatarColor;
  final List<GroupMember> members;

  const GroupInfo({
    required this.name,
    required this.description,
    required this.avatarInitials,
    required this.avatarColor,
    required this.members,
  });

  int get onlineCount => members.where((m) => m.isOnline).length;
}

// ── Group Info Screen ─────────────────────────────────────────────────────────

class GroupInfoView extends StatefulWidget {
  final GroupInfo group;

  const GroupInfoView({super.key, required this.group});

  @override
  State<GroupInfoView> createState() => _GroupInfoViewState();
}

class _GroupInfoViewState extends State<GroupInfoView> {
  bool _notificationsMuted = false;

  // ── quick action button ──────────────────────────────────────────────────
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = true,
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
              color: active
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22.sp,
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── role chip ────────────────────────────────────────────────────────────
  Widget _roleChip(MemberRole role) {
    final isAdmin = role == MemberRole.admin;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isAdmin
            ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Member',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: isAdmin
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade600,
        ),
      ),
    );
  }

  // ── member list tile ─────────────────────────────────────────────────────
  Widget _memberTile(GroupMember member) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: member.avatarColor,
            child: Text(
              member.avatarInitials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
              ),
            ),
          ),
          if (member.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        member.name,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: member.isOnline
          ? Text(
              'Online',
              style: TextStyle(fontSize: 12.sp, color: Colors.green),
            )
          : null,
      trailing: _roleChip(member.role),
      onTap: () {},
    );
  }

  // ── section header ───────────────────────────────────────────────────────
  Widget _sectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 0.8,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

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
        title: Text(
          'Group Info',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Edit', style: TextStyle(fontSize: 15.sp)),
          ),
        ],
      ),

      body: ListView(
        children: [
          // ── Group avatar + name + description ───────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
            child: Column(
              children: [
                // Avatar with camera edit overlay
                GestureDetector(
                  onTap: () {},
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44.r,
                        backgroundColor: group.avatarColor,
                        child: Text(
                          group.avatarInitials,
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.w),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  group.name,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${group.members.length} members · ${group.onlineCount} online',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
                SizedBox(height: 8.h),
                Text(
                  group.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20.h),

                // ── Quick actions ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _actionButton(
                      icon: Icons.call_outlined,
                      label: 'Call',
                      onTap: () {},
                    ),
                    SizedBox(width: 28.w),
                    _actionButton(
                      icon: Icons.search_rounded,
                      label: 'Search',
                      onTap: () {},
                    ),
                    SizedBox(width: 28.w),
                    _actionButton(
                      icon: _notificationsMuted
                          ? Icons.notifications_off_outlined
                          : Icons.notifications_outlined,
                      label: _notificationsMuted ? 'Unmute' : 'Mute',
                      active: !_notificationsMuted,
                      onTap: () => setState(
                        () => _notificationsMuted = !_notificationsMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 6, color: Color(0xFFF4F6FA)),

          // ── Shared media strip ─────────────────────────────────────────
          _sectionHeader(
            'Shared Media',
            trailing: TextButton(
              onPressed: () {},
              child: Text('See all', style: TextStyle(fontSize: 13.sp)),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
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
          ),
          SizedBox(height: 12.h),

          const Divider(height: 1, thickness: 6, color: Color(0xFFF4F6FA)),

          // ── Members list ───────────────────────────────────────────────
          _sectionHeader(
            'Members (${group.members.length})',
            trailing: TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.person_add_alt_1_outlined, size: 16.sp),
              label: Text('Add', style: TextStyle(fontSize: 13.sp)),
            ),
          ),

          ...group.members.map(
            (m) => Column(
              children: [
                _memberTile(m),
                if (m != group.members.last)
                  Divider(
                    indent: 72.w,
                    height: 1,
                    thickness: 1,
                    color: const Color(0xFFF0F2F7),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 6, color: Color(0xFFF4F6FA)),

          // ── Settings rows ──────────────────────────────────────────────
          _sectionHeader('Settings'),

          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
            minVerticalPadding: 14.h,
            leading: Icon(Icons.notifications_outlined, size: 22.sp),
            title: Text(
              'Notifications',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
            trailing: Text(
              _notificationsMuted ? 'Muted' : 'On',
              style: TextStyle(color: Colors.grey, fontSize: 13.sp),
            ),
            onTap: () =>
                setState(() => _notificationsMuted = !_notificationsMuted),
          ),
          Divider(
            indent: 56.w,
            height: 1,
            thickness: 1,
            color: const Color(0xFFF0F2F7),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
            minVerticalPadding: 14.h,
            leading: Icon(Icons.lock_outline_rounded, size: 22.sp),
            title: Text(
              'Encryption',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
            trailing: Text(
              'End-to-end',
              style: TextStyle(color: Colors.grey, fontSize: 13.sp),
            ),
            onTap: () {},
          ),
          Divider(
            indent: 56.w,
            height: 1,
            thickness: 1,
            color: const Color(0xFFF0F2F7),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
            minVerticalPadding: 14.h,
            leading: Icon(Icons.link_rounded, size: 22.sp),
            title: Text(
              'Invite via link',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
            onTap: () {},
          ),

          const Divider(height: 1, thickness: 6, color: Color(0xFFF4F6FA)),

          // ── Danger zone ────────────────────────────────────────────────
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
            minVerticalPadding: 14.h,
            leading: Icon(
              Icons.exit_to_app_rounded,
              color: Colors.red,
              size: 22.sp,
            ),
            title: Text(
              'Leave Group',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
              ),
            ),
            onTap: () => _showLeaveDialog(context),
          ),
          Divider(
            indent: 56.w,
            height: 1,
            thickness: 1,
            color: const Color(0xFFF0F2F7),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
            minVerticalPadding: 14.h,
            leading: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
              size: 22.sp,
            ),
            title: Text(
              'Delete Group',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
              ),
            ),
            onTap: () {},
          ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // ── Leave group confirmation dialog ─────────────────────────────────────
  void _showLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        titleTextStyle: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        contentTextStyle: TextStyle(fontSize: 14.sp, color: Colors.black54),
        title: const Text('Leave Group?'),
        content: Text(
          'You will no longer receive messages from "${widget.group.name}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Leave',
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
