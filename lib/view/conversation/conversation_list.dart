import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/provider/conversation.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/socket/socket.dart';
import 'package:fanari_v2/view/conversation/chat_texts.dart';
import 'package:fanari_v2/view/conversation/group/create_group_members.dart';
import 'package:fanari_v2/view/conversation/single/create_single_search.dart';
import 'package:fanari_v2/view/conversation/widgets/conversation_item.dart';
import 'package:fanari_v2/view/conversation/widgets/horizontal_options.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  Widget _searchWidget() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 40.h,
        margin: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 18.w,
          bottom: 18.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            CustomSvg(
              'assets/icons/search.svg',
              color: AppColors.text,
              width: 20.w,
              height: 20.w,
            ),
            SizedBox(width: 12.w),
            Text(
              'Search ...',
              style: TextStyle(color: AppColors.text, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _skeletons() {
    return [
      ConversationItem.skeleton(context),
      ConversationItem.skeleton(context, textWidth: 240.w),
      ConversationItem.skeleton(context, textWidth: 272.w),
      ConversationItem.skeleton(context, textWidth: 148.w),
      ConversationItem.skeleton(context, textWidth: 240.w),
    ];
  }

  bool _refreshing = false;

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await ref.read(conversationNotifierProvider.notifier).reload();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _refreshing = false);
    });
  }

  @override
  void initState() {
    super.initState();
    CustomSocket.instance.enter_chat_list_page();
  }

  @override
  void dispose() {
    CustomSocket.instance.leave_chat_list_page();
    super.dispose();
  }

  final List<String> _chatOptions = [
    "All",
    "Unread",
    "Group",
    "Online",
    "Favorites",
    "Muted",
    "Blocked",
    "Blocked by",
  ];

  String _selectedOption = "All";
  bool _selectMode = false;
  List<String> _selectedConversations = [];

  List<ConversationModel> _filterConversations(
    List<ConversationModel> conversations,
  ) {
    switch (_selectedOption) {
      case "Group":
        return conversations
            .where((c) => c.core.type == ConversationType.Group)
            .toList();
      case "Favorites":
        return conversations.where((c) => c.common_metadata.favorite).toList();
      case "Unread":
        return conversations
            .where((c) => c.texts.isNotEmpty && !c.texts.first.my_text)
            .toList();
      case "Online":
        return conversations
            .where(
              (c) =>
                  c.core.type == ConversationType.Single &&
                  c.single_metadata!.online,
            )
            .toList();
      case "Muted":
        return conversations.where((c) => c.common_metadata!.muted).toList();
      case "Blocked":
        return conversations
            .where(
              (c) =>
                  c.core.type == ConversationType.Single &&
                  c.single_metadata!.is_blocked,
            )
            .toList();
      case "Blocked by":
        return conversations
            .where(
              (c) =>
                  c.core.type == ConversationType.Single &&
                  c.single_metadata!.am_blocked,
            )
            .toList();
      default:
        return conversations;
    }
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      width: double.infinity,
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 272),
        crossFadeState: _selectedConversations.isEmpty
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        firstChild: Row(
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
              'Chats',
              style: TextStyle(color: AppColors.text, fontSize: 19.sp),
            ),
          ],
        ),
        secondChild: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectMode = false;
                  _selectedConversations = [];
                });
              },
              child: Icon(Icons.close_rounded, size: 24, color: AppColors.text),
            ),
            SizedBox(width: 12.w),
            Text(
              '${_selectedConversations.length} Selected',
              style: TextStyle(color: AppColors.text, fontSize: 19.sp),
            ),
            Spacer(),
            SizedBox(width: 12),
            CustomSvg(
              'assets/icons/delete.svg',
              color: AppColors.text,
              size: 20,
            ),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  List<Widget> _emptyChatWidget() {
    return [
      SizedBox(height: 96.w),
      CustomSvg(
        'assets/icons/chat.svg',
        color: AppColors.text.withValues(alpha: 0.7),
        width: 96.w,
        height: 96.w,
      ),
      SizedBox(height: 36.w),
      Text(
        'No Previous Conversations',
        style: TextStyle(
          color: AppColors.text,
          fontSize: 22.sp,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 12.w),
      SizedBox(
        width: .55.sw,
        child: Text(
          'Text a friend or create a group to get started.',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }

  List<String> _onlineMembers = [
    'Sabbir',
    'Sabina',
    'Sabit',
    'Sabbir',
    'Sabina',
    'Sabit',
  ];

  Widget _onlineAvatar(String name) {
    return Padding(
      padding: EdgeInsets.only(right: 18.w),
      child: Column(
        spacing: 4.w,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Text(
            name,
            style: TextStyle(color: AppColors.text, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _addNewChat() {
    return Container(
      margin: EdgeInsets.only(right: 18.w),
      child: Column(
        spacing: 4.w,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary),
                ),
              ),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.text.withValues(alpha: 0.3),
                  ),
                  color: AppColors.secondary,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.text,
                  size: 12.w,
                ),
              ),
            ],
          ),
          Text(
            'New Chat',
            style: TextStyle(color: AppColors.text, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  bool _plusOptionOpen = false;

  @override
  Widget build(BuildContext context) {
    final conversationsProvider = ref.watch(conversationNotifierProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.surface,
        child: Stack(
          children: [
            LiquidPullToRefresh(
              onRefresh: _onRefresh,
              height: 124.h,
              showChildOpacityTransition: false,
              animSpeedFactor: 2.0,
              color: AppColors.surface,
              backgroundColor: AppColors.secondary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SafeArea(bottom: false, child: SizedBox(height: 12.h)),
                        _header(),
                        _searchWidget(),
                        // SingleChildScrollView(
                        //   scrollDirection: Axis.horizontal,
                        //   child: Row(
                        //     children: [
                        //       SizedBox(width: 20.w),
                        //       _addNewChat(),
                        //       ..._onlineMembers
                        //           .map((e) => _onlineAvatar(e))
                        //           .toList(),
                        //       SizedBox(width: 20.w),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(height: 24.h),
                        HorizontalOptions(
                          options: _chatOptions,
                          selectedOption: _selectedOption,
                          onChange: (option) {
                            setState(() {
                              _selectedOption = option;
                            });
                          },
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                  if (!_refreshing)
                    SliverList(
                      delegate: conversationsProvider.when(
                        data: (conversations) {
                          final filtered = _filterConversations(conversations);

                          if (filtered.isEmpty) {
                            return SliverChildListDelegate(_emptyChatWidget());
                          }

                          return SliverChildBuilderDelegate((context, index) {
                            final item = filtered[index];

                            return ConversationItem(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return ChatTextsScreen(
                                        conversation_id: item.core.uuid,
                                      );
                                    },
                                  ),
                                );
                              },
                              model: item,
                              bottomBorder: index != filtered.length - 1,
                              onSelect: (id) {
                                if (_selectedConversations.isEmpty) {
                                  setState(() {
                                    _selectMode = true;
                                  });
                                }
                                setState(() {
                                  _selectedConversations.add(id);
                                });
                              },
                              onDeSelect: (id) {
                                setState(() {
                                  _selectedConversations.remove(id);
                                });

                                if (_selectedConversations.isEmpty) {
                                  setState(() {
                                    _selectMode = false;
                                  });
                                }
                              },
                              selectMode: _selectMode,
                              selected: _selectedConversations.contains(
                                item.core.uuid,
                              ),
                            );
                          }, childCount: filtered.length);
                        },
                        error: (error, stackTrace) {
                          return SliverChildListDelegate(_skeletons());
                        },
                        loading: () {
                          return SliverChildListDelegate(_skeletons());
                        },
                      ),
                    ),
                  if (_refreshing)
                    SliverList(delegate: SliverChildListDelegate(_skeletons())),
                  SliverToBoxAdapter(child: SizedBox(height: 96.h)),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.only(right: 24.w, bottom: 20.w),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 272),
                        height: _plusOptionOpen ? 48.w * 3 + (18.w * 2) : 0,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return CreateSingleSearch();
                                      },
                                    ),
                                  );
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Start new conversation',
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          BoxShadow(
                                            color: Color(0xff242424),
                                            blurRadius: 20.w,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Container(
                                      width: 48.w,
                                      height: 48.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(
                                          24.r,
                                        ),
                                      ),
                                      child: Center(
                                        child: CustomSvg(
                                          'assets/icons/user_plus.svg',
                                          color: AppColors.text,
                                          width: 24.w,
                                          height: 24.w,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 18.w),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return CreateGroupMembers();
                                      },
                                    ),
                                  );
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Create new group',
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          BoxShadow(
                                            color: Color(0xff242424),
                                            blurRadius: 20.w,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Container(
                                      width: 48.w,
                                      height: 48.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(
                                          24.r,
                                        ),
                                      ),
                                      child: Center(
                                        child: CustomSvg(
                                          'assets/icons/multiple_user.svg',
                                          color: AppColors.text,
                                          width: 24.w,
                                          height: 24.w,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _plusOptionOpen = !_plusOptionOpen;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 272),
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: _plusOptionOpen
                                ? AppColors.secondary
                                : AppColors.primary,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24.r),
                              topRight: Radius.circular(24.r),
                              bottomLeft: Radius.circular(24.r),
                              bottomRight: Radius.circular(6.r),
                            ),
                          ),
                          child: Center(
                            child: _plusOptionOpen
                                ? Icon(
                                    Icons.close,
                                    color: AppColors.text,
                                    size: 20.w,
                                  )
                                : CustomSvg(
                                    'assets/icons/chat_add.svg',
                                    color: AppColors.text,
                                    width: 24.w,
                                    height: 24.w,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
