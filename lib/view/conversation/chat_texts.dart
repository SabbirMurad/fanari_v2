import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/constants/local_storage.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/media/image.dart';
import 'package:fanari_v2/model/outgoing_text.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/provider/conversation.dart';
import 'package:fanari_v2/provider/author.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/socket/socket.dart';
import 'package:fanari_v2/model/media/video.dart';
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:fanari_v2/view/conversation/dm_profile_view.dart';
import 'package:fanari_v2/view/conversation/group_info_view.dart';
import 'package:fanari_v2/view/conversation/widgets/text_item.dart';
import 'package:fanari_v2/view/home/widgets/comment_input.dart';
import 'package:fanari_v2/view/profile/profile.dart';
import 'package:fanari_v2/widgets/cross_fade_box.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils/media.dart' as media_utils;
import 'package:fanari_v2/utils.dart' as utils;

class ChatTextsScreen extends ConsumerStatefulWidget {
  final String conversation_id;

  const ChatTextsScreen({super.key, required this.conversation_id});

  @override
  ConsumerState<ChatTextsScreen> createState() => _ChatTextsScreenState();
}

class _ChatTextsScreenState extends ConsumerState<ChatTextsScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _selectMode = false;
  List<String> _selectedTexts = [];
  String? _replyingTo;

  @override
  void initState() {
    super.initState();

    // Load initial texts and mark conversation as read
    Future.microtask(() {
      final notifier = ref.read(conversationNotifierProvider.notifier);
      notifier.load_initial_texts(widget.conversation_id);
      notifier.mark_as_read(widget.conversation_id);
    });

    // Listen for scroll to load more (reverse list: top = older messages)
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(conversationNotifierProvider.notifier)
          .load_more_texts(widget.conversation_id);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    CustomSocket.instance.leave_conversation();

    super.dispose();
  }

  Widget _textSkeleton({required bool isMe, required double width}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ColorFadeBox(
        width: width,
        height: 40.h,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
          bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
          bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
        ),
      ),
    );
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
              onTap: () {
                if (model.core.type == ConversationType.Group) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return GroupInfoView(
                          group: const GroupInfo(
                            name: 'Design Team',
                            description:
                                'UI/UX team workspace for mockups and design reviews.',
                            avatarInitials: 'DT',
                            avatarColor: Color(0xFF27AE60),
                            members: [
                              GroupMember(
                                name: 'Alice M.',
                                avatarInitials: 'A',
                                avatarColor: Color(0xFFE74C3C),
                                role: MemberRole.admin,
                                isOnline: true,
                              ),
                              GroupMember(
                                name: 'Bob K.',
                                avatarInitials: 'B',
                                avatarColor: Color(0xFF1A6BFF),
                                role: MemberRole.admin,
                                isOnline: true,
                              ),
                              GroupMember(
                                name: 'Carol T.',
                                avatarInitials: 'C',
                                avatarColor: Color(0xFF27AE60),
                                role: MemberRole.member,
                                isOnline: false,
                              ),
                              GroupMember(
                                name: 'David R.',
                                avatarInitials: 'D',
                                avatarColor: Color(0xFFF39C12),
                                role: MemberRole.member,
                                isOnline: false,
                              ),
                              GroupMember(
                                name: 'Eve S.',
                                avatarInitials: 'E',
                                avatarColor: Color(0xFF9B59B6),
                                role: MemberRole.member,
                                isOnline: true,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return DMProfileView(
                          user: UserProfile(
                            name: 'Alice M.',
                            phone: '+1 555 0001',
                            avatarInitials: 'A',
                            avatarColor: const Color(0xFFE74C3C),
                            isOnline: true,
                          ),
                        );
                      },
                    ),
                  );
                }
              },
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

  Widget _timeDivider(int created_at) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      child: Row(
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
            utils.pretty_date(created_at),
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
  }

  static const int _shortGap = 1000 * 60 * 10; // 10 minutes between adjacent
  static const int _maxGap = 1000 * 60 * 60; // 1 hour since last divider

  /// Precomputes which indices should show a time divider. O(n) single pass.
  /// The list is reversed (index 0 = newest), so we iterate from the oldest
  /// (end of list) towards newest.
  Set<int> _computeDividerIndices(List<TextModel> texts) {
    final dividers = <int>{};
    if (texts.isEmpty) return dividers;

    // Oldest message (last index) always gets a divider
    final lastIndex = texts.length - 1;
    dividers.add(lastIndex);
    int lastDividerTime = texts[lastIndex].created_at;

    // Walk from oldest to newest (high index to low)
    for (int i = lastIndex - 1; i >= 0; i--) {
      final text = texts[i];
      final prev = texts[i + 1];

      final bool adjacentGap =
          (text.created_at - prev.created_at).abs() > _shortGap;
      final bool accumulatedGap =
          (text.created_at - lastDividerTime).abs() > _maxGap;

      if (adjacentGap || accumulatedGap) {
        dividers.add(i);
        lastDividerTime = text.created_at;
      }
    }

    return dividers;
  }

  /// Builds a single text item at [index] in the reversed list.
  /// Since the ListView is reversed, index 0 is the newest message.
  /// The "previous" message chronologically is at index + 1.
  Widget _buildTextItem(List<TextModel> texts, int index, Set<int> dividers) {
    final text = texts[index];
    final prev = index + 1 < texts.length ? texts[index + 1] : null;

    final bool differentOwner = prev == null || prev.owner != text.owner;
    final bool timeGap = dividers.contains(index);

    final bool showProfile = differentOwner || timeGap;

    Widget spacing;
    if (timeGap) {
      spacing = _timeDivider(text.created_at);
    } else if (differentOwner) {
      spacing = SizedBox(height: 24.h);
    } else {
      spacing = SizedBox(height: 6.h);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        spacing,
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
          onReply: () {},
          seen: text.my_text && text.seen_by.isNotEmpty,
        ),
      ],
    );
  }

  void _onMessageSend(CommentInputSubmitValue message) async {
    if (message.text != null && message.text!.isNotEmpty) {
      CustomSocket.instance.send_text(
        SocketOutgoingText(
          conversation_id: widget.conversation_id,
          type: TextType.Text,
          text: message.text,
        ),
      );
    }

    if (message.images != null && message.images!.length > 0) {
      final my_id = await LocalStorage.user_id.get();

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
          .add_message(
            conversation_id: widget.conversation_id,
            message_input: temp_text,
          );

      final images = await media_utils.upload_images(
        images: message.images!,
        used_at: media_utils.AssetUsedAt.Chat,
        temporary: false,
      );

      if (images == null) {
        printLine('Failed to upload image');
        return;
      }

      CustomSocket.instance.send_text(
        SocketOutgoingText(
          conversation_id: widget.conversation_id,
          type: TextType.Image,
          images: images,
        ),
      );
    }

    if (message.videoPath != null) {
      final my_id = await LocalStorage.user_id.get();
      final now = DateTime.now().microsecondsSinceEpoch;

      final thumbnail_bytes = message.videoThumbnail!.readAsBytesSync();

      final temp_thumbnail = ImageModel(
        uuid: 'temp_$now',
        webp_url: 'temp',
        original_url: 'temp',
        blur_hash: '',
        width: 16,
        height: 9,
        provider: MemoryImage(thumbnail_bytes),
        local_bytes: thumbnail_bytes,
        local: true,
      );

      final temp_video = VideoModel(
        uuid: 'temp_$now',
        video_url: '',
        thumbnail: temp_thumbnail,
        local: true,
        local_thumbnail_bytes: thumbnail_bytes,
      );

      final temp_text = TextModel(
        uuid: 'temp_$now',
        owner: my_id!,
        conversation_id: widget.conversation_id,
        my_text: true,
        seen_by: [],
        created_at: DateTime.now().millisecondsSinceEpoch,
        type: TextType.Video,
        video: temp_video,
      );

      ref
          .read(conversationNotifierProvider.notifier)
          .add_message(
            conversation_id: widget.conversation_id,
            message_input: temp_text,
          );

      final video_id = await media_utils.upload_video(path: message.videoPath!);

      if (video_id == null) {
        printLine('Failed to upload video');
        return;
      }

      final uploaded_video = VideoModel(
        uuid: video_id,
        video_url: '',
        thumbnail: temp_thumbnail,
      );

      CustomSocket.instance.send_text(
        SocketOutgoingText(
          conversation_id: widget.conversation_id,
          type: TextType.Video,
          video: uploaded_video,
        ),
      );
    }
  }

  Widget _buildTextList(ConversationModel conversation) {
    final texts = conversation.texts;
    final dividers = _computeDividerIndices(texts);

    return ListView.builder(
      padding: EdgeInsets.all(0),
      reverse: true,
      controller: _scrollController,
      // +2 for top/bottom padding, +1 if loading more
      itemCount:
          texts.length + 2 + (conversation.control.texts_loading ? 1 : 0),
      itemBuilder: (context, index) {
        // Bottom padding (index 0 in reversed list)
        if (index == 0) return SizedBox(height: 96.h);

        final textIndex = index - 1;

        // Text items
        if (textIndex < texts.length) {
          return _buildTextItem(texts, textIndex, dividers);
        }

        // Loading skeleton at the top
        if (conversation.control.texts_loading && textIndex == texts.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Column(
              children: [
                _textSkeleton(isMe: true, width: 180.w),
                SizedBox(height: 8.h),
                _textSkeleton(isMe: false, width: 220.w),
                SizedBox(height: 8.h),
                _textSkeleton(isMe: true, width: 140.w),
              ],
            ),
          );
        }

        // Top padding
        return SizedBox(height: 124.h);
      },
    );
  }

  Widget _buildInitialLoading() {
    return ListView(
      padding: EdgeInsets.only(
        top: 124.h,
        bottom: 96.h,
        left: 16.w,
        right: 16.w,
      ),
      reverse: true,
      children: [
        _textSkeleton(isMe: true, width: 180.w),
        SizedBox(height: 8.h),
        _textSkeleton(isMe: false, width: 220.w),
        SizedBox(height: 8.h),
        _textSkeleton(isMe: true, width: 140.w),
        SizedBox(height: 8.h),
        _textSkeleton(isMe: false, width: 200.w),
        SizedBox(height: 8.h),
        _textSkeleton(isMe: true, width: 260.w),
        SizedBox(height: 8.h),
        _textSkeleton(isMe: false, width: 160.w),
        SizedBox(height: 8.h),
        _textSkeleton(isMe: true, width: 200.w),
        SizedBox(height: 8.h),
        _textSkeleton(isMe: false, width: 240.w),
      ],
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

    CustomSocket.instance.enter_conversation(target_conversation.core.uuid);

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
              child: target_conversation.control.initial_text_loaded
                  ? _buildTextList(target_conversation)
                  : _buildInitialLoading(),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: _header(target_conversation),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child:
                  (target_conversation.core.type == ConversationType.Group ||
                      (!target_conversation.single_metadata!.is_blocked &&
                          !target_conversation.single_metadata!.am_blocked))
                  ? CommentInputWidget(
                      show_typing: target_conversation.control.typing,
                      typing_name: target_conversation.control.typing_name,
                      onSend: _onMessageSend,
                      onTyping: () {
                        if (myself == null) return;

                        CustomSocket.instance.send_typing(
                          conversation_id: widget.conversation_id,
                          user_id: myself.core.uuid,
                          name: myself.profile.first_name,
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(24, 24, 24, 0.1),
                            Color.fromRGBO(24, 24, 24, 0.95),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Cant send messages here.',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              target_conversation.single_metadata!.am_blocked
                                  ? 'You have blocked this user. Request unblock to send messages.'
                                  : 'You have blocked this user. Unblock to send messages.',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 12.h),
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
