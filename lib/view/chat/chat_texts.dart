import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/constants/local_storage.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/provider/conversation.dart';
import 'package:fanari_v2/provider/author.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/socket.dart';
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:fanari_v2/view/chat/widgets/text_item.dart';
import 'package:fanari_v2/view/home/widgets/comment_input.dart';
import 'package:fanari_v2/view/profile/profile.dart';
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

    CustomSocket.instance.opened_conversation_id = null;

    super.dispose();
  }

  Widget _header(ConversationModel model) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: EdgeInsets.only(bottom: 8.h),
      child: SafeArea(
        bottom: false,
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
                  if (model.core.type == ConversationType.Group) return;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return ProfileScreen(
                          user_id: model.single_metadata!.user_id,
                        );
                      },
                    ),
                  );
                },
                child: Row(
                  children: [
                    Hero(
                      tag: 'conversation_image_' + model.core.uuid,
                      child: Material(
                        color: Colors.transparent,
                        child: NamedAvatar(
                          loading: false,
                          image: model.core.type == ConversationType.Group
                              ? model.group_metadata!.image
                              : model.single_metadata!.image,
                          name: model.core.type == ConversationType.Group
                              ? model.group_metadata!.name
                              : model.single_metadata!.first_name,
                          size: 40.w,
                        ),
                      ),
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
                                    : 'Last seen - ${utils.time_ago(DateTime.fromMillisecondsSinceEpoch(model.single_metadata!.last_seen))}',
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
      ),
    );
  }

  List<Widget> _textWidgets(List<TextModel> texts) {
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
        widgets.add(SizedBox(height: 18.h));
        widgets.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 20.w),
              Expanded(
                child: Container(
                  height: 0.8,
                  width: double.infinity,
                  color: AppColors.border.withValues(alpha: .5),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                utils.pretty_date(text.created_at),
                style: TextStyle(
                  color: AppColors.border.withValues(alpha: .5),
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: .8,
                  width: double.infinity,
                  color: AppColors.border.withValues(alpha: .5),
                ),
              ),
              SizedBox(width: 20.w),
            ],
          ),
        );
        widgets.add(SizedBox(height: 18.h));
      } else if (differentProfile) {
        widgets.add(SizedBox(height: 24.h));
      } else {
        widgets.add(SizedBox(height: 6.h));
      }

      widgets.add(
        TextItemWidget(
          key: Key(text.uuid),
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

    return widgets;
  }

  void _onMessageSend(CommentInputSubmitValue message) async {
    if (message.text != null && message.text!.isNotEmpty) {
      CustomSocket.instance.send_text(
        SocketOutgoingTextModel(
          conversation_id: widget.conversation_id,
          type: TextType.Text,
          text: message.text,
        ),
      );
    }

    if (message.images != null && message.images!.length > 0) {
      final my_id = await LocalStorage.user_id.get();
      printLine('before: ${message.images!.length}');

      List<ImageModel> temp_images = [];
      int now = DateTime.now().microsecondsSinceEpoch;
      for (int i = 0; i < message.images!.length; i++) {
        final image = message.images![i];

        now++;
        temp_images.add(
          ImageModel(
            uuid: 'temp_${now}',
            webp_url: 'temp',
            original_url: 'temp',
            blur_hash: image.meta!.blur_hash,
            width: image.meta!.width.toDouble(),
            height: image.meta!.height.toDouble(),
            provider: MemoryImage(image.meta!.bytes),
            local_bytes: image.meta!.bytes,
            local: true,
          ),
        );
      }

      TextModel temp_text = TextModel(
        uuid: 'temp_${now}',
        owner: my_id!,
        conversation_id: widget.conversation_id,
        my_text: true,
        seen_by: [],
        created_at: DateTime.now().millisecondsSinceEpoch,
        type: TextType.Image,
        images: temp_images,
      );

      ref
          .read(conversationNotifierProvider.notifier)
          .addMessage(
            conversation_id: widget.conversation_id,
            message: temp_text,
          );
      printLine('after: ${message.images!.length}');

      final images = await utils.upload_images(
        images: message.images!,
        used_at: utils.AssetUsedAt.Chat,
        temporary: false,
      );

      if (images == null) {
        printLine('Failed to upload image');
        return;
      }

      CustomSocket.instance.send_text(
        SocketOutgoingTextModel(
          conversation_id: widget.conversation_id,
          type: TextType.Image,
          images: images,
        ),
      );
    }
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

    CustomSocket.instance.opened_conversation_id =
        target_conversation.core.uuid;

    final myself = ref
        .watch(authorNotifierProvider)
        .whenOrNull(data: (data) => data);

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColors.surface,
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: ListView(
                padding: EdgeInsets.all(0),
                reverse: true,
                controller: _scrollController,
                children: [
                  SizedBox(height: 72.h),
                  ..._textWidgets(target_conversation.texts),
                  SizedBox(height: 124.h),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: _header(target_conversation),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CommentInputWidget(
                showTyping: target_conversation.typing,
                onSend: _onMessageSend,
                onTyping: () {
                  if (myself == null) return;

                  CustomSocket.instance.send_typing(
                    conversation_id: widget.conversation_id,
                    user_id: myself.core.uuid,
                    name: myself.profile.first_name,
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
