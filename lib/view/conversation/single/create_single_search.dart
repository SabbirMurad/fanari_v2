import 'dart:async';

import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/user_search.dart';
import 'package:fanari_v2/provider/conversation.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/view/conversation/chat_texts.dart';
import 'package:fanari_v2/widgets/cross_fade_box.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/input_field_v_one.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart' as utils;

class CreateSingleSearch extends ConsumerStatefulWidget {
  const CreateSingleSearch({super.key});

  @override
  ConsumerState<CreateSingleSearch> createState() => _CreateSingleSearchState();
}

class _CreateSingleSearchState extends ConsumerState<CreateSingleSearch> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

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
        _searchResults = results;
        _isSearching = false;
      });
    } else {
      setState(() => _isSearching = false);
    }
  }

  bool creatingConversation = false;
  Widget _searchItemWidget(UserSearchModel user, {bool bottom_border = true}) {
    return GestureDetector(
      onTap: () async {
        if (creatingConversation) return;

        setState(() {
          creatingConversation = true;
        });

        final conversation_id = await ref
            .read(conversationNotifierProvider.notifier)
            .create_single_conversation(target_user: user.uuid);

        setState(() {
          creatingConversation = false;
        });

        if (conversation_id == null) return;

        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return ChatTextsScreen(conversation_id: conversation_id);
            },
          ),
        );
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
          'Start new conversation',
          style: TextStyle(color: AppColors.text, fontSize: 19.sp),
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
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12.r),
                  // border: Border(bottom: BorderSide(color: AppColors.text)),
                ),
                child: Row(
                  spacing: 6.w,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomSvg(
                      'assets/icons/search.svg',
                      color: AppColors.text,
                      size: 20.w,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: AppColors.text),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search ...',
                          hintStyle: TextStyle(
                            color: AppColors.text,
                            fontSize: 14.sp,
                          ),
                        ),
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
