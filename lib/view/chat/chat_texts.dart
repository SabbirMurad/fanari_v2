import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/providers/conversation.dart';
import 'package:fanari_v2/providers/myself.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/socket.dart';
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

  bool _selectMode = false;
  List<String> _selectedTexts = [];
  String? _replyingTo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    CustomSocket.instance.openedConversationId = null;

    super.dispose();
  }

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
                          if (model.core.type == ConversationType.Single &&
                              model.single_metadata!.online)
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

  SliverChildDelegate _textWidgets(List<TextModel> texts) {
    List<Widget> widgets = [];

    String previousTextOwner = '';
    int previousTextTime = 0;

    for (var text in texts) {
      bool showProfile = false;
      bool differentProfile = false;
      if (previousTextOwner != text.owner) {
        showProfile = true;
        differentProfile = true;
      } else {
        showProfile = false;
        differentProfile = false;
      }

      previousTextOwner = text.owner;

      bool addTimeDivider = false;

      if (previousTextTime == 0 ||
          previousTextTime + 1000 * 60 * 10 < text.created_at) {
        addTimeDivider = true;
        showProfile = true;
      } else {
        addTimeDivider = false;
      }

      previousTextTime = text.created_at;

      if (addTimeDivider) {
        widgets.add(SizedBox(height: 18));
        widgets.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 0.8,
                width: (1.sw / 2) - 12 - (150 / 2),
                color: Theme.of(
                  context,
                ).colorScheme.tertiary.withValues(alpha: .2),
              ),
              Container(
                // color: Colors.green,
                width: 150,
                child: Center(
                  child: Text(
                    utils.prettyDate(text.created_at),
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.tertiary.withValues(alpha: .3),
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              Container(
                height: .8,
                width: (1.sw / 2) - 12 - (150 / 2),
                color: Theme.of(
                  context,
                ).colorScheme.tertiary.withValues(alpha: .2),
              ),
            ],
          ),
        );
        widgets.add(SizedBox(height: 18));
      } else if (differentProfile) {
        widgets.add(SizedBox(height: 24));
      } else {
        widgets.add(SizedBox(height: 6));
      }

      widgets.add(
        TextItemWidget(
          onSelect: (id) {
            if (_selectedTexts.isEmpty) {
              setState(() {
                _selectMode = true;
              });
            }
            setState(() {
              _selectedTexts.add(id);
            });
          },
          onDeSelect: (id) {
            setState(() {
              _selectedTexts.remove(id);
            });

            if (_selectedTexts.isEmpty) {
              setState(() {
                _selectMode = false;
              });
            }
          },
          selectMode: _selectMode,
          model: text,
          showProfile: showProfile,
          selected: _selectedTexts.contains(text.uuid),
          // ownerImage: widget.model.image?.url,
          // ownerName: widget.model.name,
          onReply: () {
            // setState(() {
            //   _replyingTo = text.type == MessageType.Text
            //       ? text.text!
            //       : '%${text.type.name}%';
            // });
          },
        ),
      );
    }

    return SliverChildBuilderDelegate((context, index) {
      return widgets[index];
    }, childCount: widgets.length);
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

    CustomSocket.instance.openedConversationId = target_conversation.core.uuid;

    final myself = ref
        .watch(myselfNotifierProvider)
        .when(
          data: (data) => data,
          error: (error, stackTrace) => null,
          loading: () => null,
        );

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
                reverse: true,
                physics: AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: 72.h)),
                  // if (target_conversation.initial_text_loaded)
                  SliverList(delegate: _textWidgets(target_conversation.texts)),
                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),
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
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CommentInputWidget(
                showTyping: target_conversation.typing,
                onSend: (message) {
                  if (myself == null) return;
                  CustomSocket.instance.sendText(
                    SocketOutgoingTextModel(
                      conversation_id: widget.conversation_id,
                      type: TextType.Text,
                      text: message.text,
                    ),
                  );
                },
                onTyping: () {
                  if (myself == null) return;

                  CustomSocket.instance.sendTyping(
                    conversation_id: widget.conversation_id,
                    user_id: myself.core.uuid,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
