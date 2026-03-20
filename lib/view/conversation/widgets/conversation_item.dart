import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/provider/conversation.dart';
import 'package:fanari_v2/widgets/bouncing_three_dot.dart';
import 'package:fanari_v2/widgets/cross_fade_box.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:flutter/material.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConversationItem extends ConsumerStatefulWidget {
  final bool bottomBorder;
  final ConversationModel model;
  final void Function()? onTap;
  final bool selectMode;
  final bool selected;
  final Function(String)? onSelect;
  final Function(String)? onDeSelect;

  const ConversationItem({
    super.key,
    this.bottomBorder = true,
    required this.model,
    required this.selectMode,
    required this.selected,
    this.onSelect,
    this.onDeSelect,
    this.onTap,
  });

  static Widget skeleton(BuildContext context, {double? textWidth}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18.h),
        child: Row(
          children: [
            ColorFadeBox(
              width: 56.w,
              height: 56.w,
              borderRadius: BorderRadius.circular(28.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ColorFadeBox(
                    width: 84.w,
                    height: 13.h,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  SizedBox(height: 12.h),
                  ColorFadeBox(
                    width: textWidth ?? 1.sw - 40.w - 56.w - 12.w,
                    height: 13.h,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  ConsumerState<ConversationItem> createState() => _ConversationItemState();
}

class _ConversationItemState extends ConsumerState<ConversationItem> {
  @override
  void initState() {
    super.initState();
  }

  /// Returns the most recent text to display in the conversation preview.
  /// Prefers texts list (populated after opening conversation), falls back to last_text from API.
  TextModel? get _preview_text {
    if (widget.model.texts.isNotEmpty) return widget.model.texts.first;
    return widget.model.last_text;
  }

  Color? _bgColor() {
    if (widget.selected) return AppColors.primary.withValues(alpha: 0.5);
    return null;
  }

  FontWeight _textWeight() {
    if (widget.model.unread_count > 0) return FontWeight.w600;
    return FontWeight.w400;
  }

  _openMoreOptions() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      elevation: 0,
      // barrierColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                // Do nothing here, this prevents the gesture detector of the whole container
              },
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Container(
                    width: 1.sw - 40.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 35.w,
                    ),
                    margin: EdgeInsets.only(bottom: 20.w),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _moreOptionItem(
                          icon: 'assets/icons/more_options/select.svg',
                          text: 'Select',
                          onTap: () {
                            widget.onSelect?.call(widget.model.core.uuid);
                          },
                          padding: EdgeInsets.only(bottom: 14.h),
                        ),
                        _moreOptionItem(
                          icon: 'assets/icons/more_options/favorite.svg',
                          text: widget.model.common_metadata.favorite
                              ? 'Unfavorite'
                              : 'Favorite',
                          onTap: () {
                            ref
                                .read(conversationNotifierProvider.notifier)
                                .toggle_favorite(widget.model.core.uuid);
                          },
                        ),
                        _moreOptionItem(
                          icon: 'assets/icons/more_options/mute.svg',
                          text: widget.model.common_metadata.muted
                              ? 'Unmute'
                              : 'Mute',
                          color: !widget.model.common_metadata.muted
                              ? Colors.red[400]
                              : null,
                          onTap: () {
                            ref
                                .read(conversationNotifierProvider.notifier)
                                .toggle_mute(widget.model.core.uuid);
                          },
                        ),
                        _moreOptionItem(
                          icon: 'assets/icons/more_options/delete.svg',
                          text: 'Delete conversation',
                          color: Colors.red[400],
                          onTap: () {},
                        ),
                        if (widget.model.core.type == ConversationType.Group)
                          _moreOptionItem(
                            icon: 'assets/icons/more_options/logout.svg',
                            text: 'Leave ${widget.model.group_metadata!.name}',
                            onTap: () {},
                            color: Colors.red[400],
                            padding: EdgeInsets.only(top: 14.h),
                          ),
                        if (widget.model.core.type == ConversationType.Single)
                          _moreOptionItem(
                            icon: 'assets/icons/more_options/not_allowed.svg',
                            text:
                                'Block ${widget.model.single_metadata!.first_name}',
                            onTap: () {
                              ref
                                  .read(conversationNotifierProvider.notifier)
                                  .toggle_block(
                                    conversation_id: widget.model.core.uuid,
                                    user_id:
                                        widget.model.single_metadata!.user_id,
                                  );
                            },
                            color: Colors.red[400],
                            padding: EdgeInsets.only(top: 14.h),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _moreOptionItem({
    required String icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
    EdgeInsetsGeometry? padding,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: padding ?? EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              child: CustomSvg(
                icon,
                height: 20.w,
                width: 20.w,
                fit: BoxFit.contain,
                color: color ?? AppColors.text,
              ),
            ),
            SizedBox(width: 18.w),
            Text(
              text,
              style: TextStyle(fontSize: 14.sp, color: color ?? AppColors.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarWidget() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 4.w),
          child: Hero(
            tag: 'conversation_image_' + widget.model.core.uuid,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  NamedAvatar(
                    loading: false,
                    image: widget.model.core.type == ConversationType.Group
                        ? widget.model.group_metadata!.image
                        : widget.model.single_metadata!.image,
                    name:
                        widget.model.common_metadata.muted ||
                            (widget.model.core.type ==
                                    ConversationType.Single &&
                                widget.model.single_metadata!.is_blocked)
                        ? ' '
                        : widget.model.core.type == ConversationType.Group
                        ? widget.model.group_metadata!.name
                        : widget.model.single_metadata!.first_name,
                    size: 56.w,
                  ),
                  if (widget.model.common_metadata.muted ||
                      (widget.model.core.type == ConversationType.Single &&
                          widget.model.single_metadata!.is_blocked))
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.4),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Center(
                        child: widget.model.common_metadata.muted
                            ? CustomSvg(
                                'assets/icons/more_options/mute.svg',
                                width: 24.w,
                                height: 24.w,
                              )
                            : CustomSvg(
                                'assets/icons/more_options/not_allowed.svg',
                                width: 24.w,
                                height: 24.w,
                                color: Colors.white,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (widget.model.core.type == ConversationType.Single)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: widget.model.single_metadata!.online
                  ? Colors.green[400]!.withValues(alpha: 0.5)
                  : Color.fromARGB(255, 102, 105, 103),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              widget.model.single_metadata!.online ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 8.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _textWidget(TextModel? preview) {
    if (preview == null) {
      return Text(
        'You can now start a conversation',
        style: TextStyle(
          color: AppColors.text,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    String text = 'Default';

    if (preview.type == TextType.Text) {
      text = preview.text!;
    } else if (preview.type == TextType.Video) {
      text = 'Video';
    } else if (preview.type == TextType.Image) {
      text =
          '${preview.images!.length} image${preview.images!.length > 1 ? 's' : ''}';
    } else if (preview.type == TextType.Audio) {
      text = 'Voice message';
    } else if (preview.type == TextType.Attachment) {
      text = 'Attachment';
    } else {
      return SizedBox.shrink();
    }

    return Text(
      text,
      style: TextStyle(
        color: AppColors.text,
        fontSize: 13.sp,
        fontWeight: _textWeight(),
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _textIconWidget(TextModel preview) {
    String icon = 'default';

    if (preview.type == TextType.Image) {
      icon = 'assets/icons/post/gallery.svg';
    } else if (preview.type == TextType.Video) {
      icon = 'assets/icons/post/video.svg';
    } else if (preview.type == TextType.Audio) {
      icon = 'assets/icons/audio.svg';
    } else if (preview.type == TextType.Attachment) {
      icon = 'assets/icons/attachment.svg';
    } else {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(right: 6.w),
      child: CustomSvg(
        icon,
        size: 18.w,
        fit: BoxFit.fitWidth,
        color: AppColors.text,
      ),
    );
  }

  Widget _previewBuilder() {
    return Builder(
      builder: (context) {
        final preview = _preview_text;
        return Row(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.model.control.typing) ...[
                      Text(
                        widget.model.core.type == ConversationType.Group
                            ? '${widget.model.control.typing_name} is typing'
                            : 'Typing',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      BouncingDots(dotSize: 3, gap: 4),
                    ],
                    if (!widget.model.control.typing) ...[
                      if (preview != null &&
                          preview.my_text &&
                          widget.model.core.type == ConversationType.Single)
                        Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: Icon(
                            Icons.done_all_rounded,
                            size: 18.w,
                            color:
                                preview.seen_by.contains(
                                  widget.model.single_metadata!.user_id,
                                )
                                ? AppColors.primary
                                : AppColors.hintText,
                          ),
                        ),
                      if (preview != null) _textIconWidget(preview),
                      Expanded(child: _textWidget(preview)),
                    ],
                  ],
                ),
              ),
            ),
            if (preview != null)
              Container(
                margin: EdgeInsets.only(left: 6, right: 6),
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.text.withValues(alpha: .8),
                ),
              ),
            if (preview != null)
              Text(
                utils.time_ago(
                  DateTime.fromMillisecondsSinceEpoch(preview.created_at),
                ),
                style: TextStyle(
                  color: AppColors.text.withValues(alpha: .8),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (widget.model.unread_count > 0)
              Container(
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  widget.model.unread_count > 99
                      ? '99+'
                      : widget.model.unread_count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.selectMode) {
          if (widget.selected) {
            widget.onDeSelect?.call(widget.model.core.uuid);
          } else {
            widget.onSelect?.call(widget.model.core.uuid);
          }
          return;
        }

        widget.onTap?.call();
      },
      onLongPress: () {
        if (widget.selected || widget.selectMode) return;
        _openMoreOptions();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        color: _bgColor(),
        child: Container(
          decoration: BoxDecoration(
            border: widget.bottomBorder
                ? Border(bottom: BorderSide(color: AppColors.secondary))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 2.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: widget.model.unread_count > 0
                      ? AppColors.primary
                      : Colors.transparent,
                ),
              ),
              SizedBox(width: widget.model.unread_count > 0 ? 6.w : 8.w),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),

                  child: Row(
                    children: [
                      _avatarWidget(),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        child: Hero(
                                          tag:
                                              'conversation_name_' +
                                              widget.model.core.uuid,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Text(
                                              widget.model.core.type ==
                                                      ConversationType.Group
                                                  ? widget
                                                        .model
                                                        .group_metadata!
                                                        .name
                                                  : widget
                                                            .model
                                                            .single_metadata!
                                                            .first_name +
                                                        ' ' +
                                                        widget
                                                            .model
                                                            .single_metadata!
                                                            .last_name,
                                              style: TextStyle(
                                                color: AppColors.text,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (widget.model.common_metadata.favorite)
                                      Icon(
                                        Icons.favorite_rounded,
                                        size: 20.w,
                                        color: Colors.red[400],
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2.w),
                              _previewBuilder(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
