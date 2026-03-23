import 'dart:async';

import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/user_search.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:fanari_v2/view/conversation/group/create_group_details.dart';
import 'package:fanari_v2/widgets/cross_fade_box.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/input_field_v_one.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart' as utils;

class CreateGroupMembers extends StatefulWidget {
  const CreateGroupMembers({super.key});

  @override
  State<CreateGroupMembers> createState() => _CreateGroupMembersState();
}

class _CreateGroupMembersState extends State<CreateGroupMembers> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

  List<UserSearchModel> _selectedUsers = [];
  List<UserSearchModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchUsers(query);
    });
  }

  Future<void> _searchUsers(String query) async {
    final response = await utils.CustomHttp.get(
      endpoint: '/profile/search',
      queries: {'q': query, 'exclude_self': true},
    );

    if (!mounted) return;

    if (response.ok) {
      final results = UserSearchModel.fromJsonList(response.data['results']);
      setState(() {
        _searchResults = results
            .where((u) => !_selectedUsers.any((s) => s.uuid == u.uuid))
            .toList();
        _isSearching = false;
      });
    } else {
      setState(() => _isSearching = false);
    }
  }

  Widget _selectedUserWidget(UserSearchModel user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondary, width: 1.w),
        borderRadius: BorderRadius.circular(24.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NamedAvatar(loading: false, name: user.first_name, size: 20.w),
          SizedBox(width: 6.w),
          Text(
            user.first_name + ' ' + user.last_name,
            style: TextStyle(color: AppColors.text, fontSize: 12.sp),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedUsers.remove(user);
              });
            },
            child: Icon(Icons.close, color: AppColors.text, size: 16.w),
          ),
        ],
      ),
    );
  }

  Widget _searchItemWidget(UserSearchModel user, {bool bottom_border = true}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (!_selectedUsers.any((s) => s.uuid == user.uuid)) {
            _selectedUsers.add(user);
          }
          _searchResults.remove(user);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: bottom_border
                ? BorderSide(color: AppColors.secondary, width: 1.w)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NamedAvatar(loading: false, name: user.first_name, size: 32.w),
            SizedBox(width: 12.w),
            Text(
              user.first_name + ' ' + user.last_name,
              style: TextStyle(color: AppColors.text, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
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
          'Create new Group',
          style: TextStyle(color: AppColors.text, fontSize: 19.sp),
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            if (_selectedUsers.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return CreateGroupDetails(
                      members: _selectedUsers.map((u) => u.uuid).toList(),
                    );
                  },
                ),
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _selectedUsers.isEmpty
                  ? AppColors.secondary
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(bottom: false, child: SizedBox(height: 12.h)),
              _header(),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Text(
                    'Selected member',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Divider(color: AppColors.text, thickness: 1.w),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    _selectedUsers.length.toString(),
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.w,
                children: _selectedUsers.map(_selectedUserWidget).toList(),
              ),
              SizedBox(height: 24.h),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.text)),
                ),
                child: Row(
                  spacing: 6.w,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomSvg(
                      'assets/icons/search.svg',
                      color: AppColors.text,
                      size: 20.w,
                    ),
                    Expanded(
                      child: InputFieldVOne(
                        height: 50.h,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                        hintText: 'Search people ...',
                        controller: _searchController,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              if (_isSearching)
                ...List.generate(
                  4,
                  (index) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: index < 3
                            ? BorderSide(color: AppColors.secondary, width: 1.w)
                            : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      children: [
                        ColorFadeBox(
                          width: 32.w,
                          height: 32.w,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        SizedBox(width: 12.w),
                        ColorFadeBox(
                          width: [140.w, 100.w, 170.w, 120.w][index],
                          height: 14.h,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_isSearching &&
                  _searchResults.isEmpty &&
                  _searchController.text.trim().isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.5),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              if (!_isSearching)
                ..._searchResults.asMap().entries.map((entry) {
                  final UserSearchModel item = entry.value;
                  final int index = entry.key;

                  return _searchItemWidget(
                    item,
                    bottom_border: index < _searchResults.length - 1,
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
