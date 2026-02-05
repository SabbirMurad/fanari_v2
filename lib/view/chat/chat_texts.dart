import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/providers/conversation.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/view/chat/widgets/text_item.dart';
import 'package:fanari_v2/view/home/widgets/comment_input.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart' as utils;
 
class ChatTextsScreen extends ConsumerStatefulWidget {
  final String conversation_id;

  const ChatTextsScreen({super.key, required this.conversation_id});

  @override
  ConsumerState<ChatTextsScreen> createState() => _ChatTextsScreenState();
}

class _ChatTextsScreenState extends ConsumerState<ChatTextsScreen> {
  ScrollController _scrollController = ScrollController();

  Widget _header(ConversationModel model) {
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
                    image: model.core.type == ConversationType.Group
                        ? model.group_metadata!.image
                        : model.single_metadata!.image,
                    name: model.core.type == ConversationType.Group
                        ? model.group_metadata!.name
                        : model.single_metadata!.first_name,
                    size: 40.w,
                  ),
                  SizedBox(width: 6.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: 'conversation_name_' + model.core.uuid,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            model.core.type == ConversationType.Group
                                ? model.group_metadata!.name
                                : model.single_metadata!.first_name +
                                      ' ' +
                                      model.single_metadata!.last_name,
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
                          if (model.core.type == ConversationType.Single)
                            Container(
                              width: 10.w,
                              height: 10.w,
                              margin: EdgeInsets.only(right: 6.w),
                              decoration: BoxDecoration(
                                color: model.single_metadata!.online
                                    ? Colors.green[400]
                                    : Color.fromARGB(255, 102, 105, 103),
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (model.core.type == ConversationType.Single)
                            Text(
                              model.single_metadata!.online
                                  ? 'Online'
                                  : 'Last seen - ${utils.timeAgo(DateTime.fromMillisecondsSinceEpoch(model.single_metadata!.last_seen))}',
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
    final conversations = ref
        .watch(conversationNotifierProvider)
        .when(
          data: (data) => data,
          error: (error, stackTrace) => null,
          loading: () => null,
        );

    final target_conversation = conversations!
        .where((element) => element.core.uuid == widget.conversation_id)
        .first;

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
                    title: _header(target_conversation),
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
                  if (target_conversation.initial_text_loaded)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return TextItemWidget(
                          model: target_conversation.texts[index],
                        );
                      }, childCount: target_conversation.texts.length),
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: 96.h)),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CommentInputWidget(
                onSend: (text) {
                  
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
