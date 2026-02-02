import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/view/chat/widgets/text_item.dart';
import 'package:fanari_v2/view/home/widgets/comment_input.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart' as utils;

class ChatTextsScreen extends StatefulWidget {
  final String conversationId;
  final ConversationModel model;

  const ChatTextsScreen({
    super.key,
    required this.conversationId,
    required this.model,
  });

  @override
  State<ChatTextsScreen> createState() => _ChatTextsScreenState();
}

class _ChatTextsScreenState extends State<ChatTextsScreen> {
  ScrollController _scrollController = ScrollController();

  Widget _header() {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: const EdgeInsets.all(0.0),
            onPressed: () {
              AppRoutes.pop();
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: 20.w,
              color: AppColors.text,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (_) {
                //       return ProfilePage(
                //         userId: widget.model.user_id,
                //         myProfile: false,
                //       );
                //     },
                //   ),
                // );
              },
              child: Row(
                children: [
                  NamedAvatar(
                    loading: false,
                    image: widget.model.core.type == ConversationType.Group
                        ? widget.model.group_metadata!.image
                        : widget.model.single_metadata!.image,
                    name: widget.model.core.type == ConversationType.Group
                        ? widget.model.group_metadata!.name
                        : widget.model.single_metadata!.first_name,
                    size: 40.w,
                  ),
                  SizedBox(width: 6.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: 'conversation_name_' + widget.model.core.uuid,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            widget.model.core.type == ConversationType.Group
                                ? widget.model.group_metadata!.name
                                : widget.model.single_metadata!.first_name +
                                      ' ' +
                                      widget.model.single_metadata!.last_name,
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (widget.model.core.type == ConversationType.Single)
                            Container(
                              width: 10.w,
                              height: 10.w,
                              margin: EdgeInsets.only(right: 6.w),
                              decoration: BoxDecoration(
                                color: widget.model.single_metadata!.online
                                    ? Colors.green[400]
                                    : Color.fromARGB(255, 102, 105, 103),
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (widget.model.core.type == ConversationType.Single)
                            Text(
                              widget.model.single_metadata!.online
                                  ? 'Online'
                                  : 'Last seen - ${utils.timeAgo(DateTime.fromMillisecondsSinceEpoch(widget.model.single_metadata!.last_seen))}',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (_) {
              //       return CallPage(
              //         username: widget.model.name,
              //         image: widget.model.image,
              //       );
              //     },
              //   ),
              // );
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.videocam, size: 24.w, color: AppColors.text),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.call, size: 20.w, color: AppColors.text),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.more_vert_rounded,
                size: 24.w,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColors.surface,
        height: double.infinity,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    titleSpacing: 0.0,
                    title: _header(),
                    floating: true,
                    snap: true,
                    automaticallyImplyLeading: false,
                    actions: [Container()],
                    expandedHeight: 40.h,
                    surfaceTintColor: AppColors.surface,
                    backgroundColor: AppColors.surface,
                    shadowColor: AppColors.containerBg,
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return TextItemWidget(model: widget.model.texts[index]);
                    }, childCount: widget.model.texts.length),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 96.h)),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CommentInputWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
