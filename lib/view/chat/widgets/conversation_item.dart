import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/provider/conversation.dart';
import 'package:fanari_v2/utils/print_helper.dart';
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
  /// Returns the most recent text to display in the conversation preview.
  /// Prefers texts list (populated after opening conversation), falls back to last_text from API.
  TextModel? get _preview_text {
    if (widget.model.texts.isNotEmpty) return widget.model.texts.first;
    return widget.model.last_text;
  }

  Color? _bgColor() {
    if (widget.selected) return AppColors.primary.withValues(alpha: 0.2);
    final preview = _preview_text;
    if (preview == null) return null;

    if (preview.my_text) return null;

    // TODO: Fix
    // if (preview.seen_by.contains(widget.model.user_id))
    return null;

    return AppColors.surface;
  }

  FontWeight _textWeight() {
    final preview = _preview_text;
    if (preview == null) return FontWeight.w400;

    if (preview.my_text) return FontWeight.w400;

    // TODO: Fix
    // if (preview.seen_by.contains(widget.model.user_id))
    return FontWeight.w400;

    return FontWeight.w600;
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
                          text: widget.model.common_metadata.is_favorite
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
                          text: widget.model.common_metadata.is_muted
                              ? 'Unmute'
                              : 'Mute',
                          color: !widget.model.common_metadata.is_muted
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
                        _moreOptionItem(
                          icon: 'assets/icons/more_options/not_allowed.svg',
                          text: 'Block Sabbir',
                          onTap: () {},
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
          width: 1.sw - 40.w,
          padding: EdgeInsets.symmetric(vertical: 18.h),
          decoration: BoxDecoration(
            border: widget.bottomBorder
                ? Border(bottom: BorderSide(color: AppColors.secondary))
                : null,
          ),
          child: Row(
            children: [
              Stack(
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
                              image:
                                  widget.model.core.type ==
                                      ConversationType.Group
                                  ? widget.model.group_metadata!.image
                                  : widget.model.single_metadata!.image,
                              name: widget.model.common_metadata.is_muted
                                  ? ' '
                                  : widget.model.core.type ==
                                        ConversationType.Group
                                  ? widget.model.group_metadata!.name
                                  : widget.model.single_metadata!.first_name,
                              size: 56.w,
                            ),
                            if (widget.model.common_metadata.is_muted)
                              Container(
                                width: 56.w,
                                height: 56.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.4),
                                ),
                                child: Center(
                                  child: CustomSvg(
                                    'assets/icons/more_options/mute.svg',
                                    width: 24.w,
                                    height: 24.w,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: widget.model.single_metadata!.online
                            ? Colors.green[400]!.withValues(alpha: 0.5)
                            : Color.fromARGB(255, 102, 105, 103),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        widget.model.single_metadata!.online
                            ? 'Online'
                            : 'Offline',
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Container(
                width: 1.sw - 40.w - 56.w - 12.w,
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
                                        ? widget.model.group_metadata!.name
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
                          if (widget.model.common_metadata.is_favorite)
                            Icon(
                              Icons.star_rate_rounded,
                              size: 24.w,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.w),
                    Builder(builder: (context) {
                      final preview = _preview_text;
                      return Row(
                        children: [
                          Row(
                            children: [
                              if (widget.model.typing)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Typing',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    BouncingDots(dotSize: 3, gap: 4),
                                  ],
                                ),
                              if (!widget.model.typing) ...[
                                if (preview == null)
                                  Text(
                                    'You can now start a conversation',
                                    style: TextStyle(
                                      color: AppColors.text,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                if (preview != null) ...[
                                  if (preview.type == TextType.Text)
                                    Text(
                                      preview.text!,
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontSize: 13.sp,
                                        fontWeight: _textWeight(),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  if (preview.type == TextType.Video)
                                    Row(
                                      children: [
                                        CustomSvg(
                                          'assets/icons/post/video.svg',
                                          size: 18.w,
                                          fit: BoxFit.fitWidth,
                                          color: AppColors.text,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Video',
                                          style: TextStyle(
                                            color: AppColors.text,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (preview.type == TextType.Image)
                                    Row(
                                      children: [
                                        CustomSvg(
                                          'assets/icons/post/gallery.svg',
                                          size: 18.w,
                                          fit: BoxFit.fitWidth,
                                          color: AppColors.text,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          '${preview.images!.length} image${preview.images!.length > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            color: AppColors.text,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (preview.type == TextType.Audio)
                                    Row(
                                      children: [
                                        CustomSvg(
                                          'assets/icons/audio.svg',
                                          size: 18.w,
                                          fit: BoxFit.fitWidth,
                                          color: AppColors.text,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Voice message',
                                          style: TextStyle(
                                            color: AppColors.text,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (preview.type == TextType.Attachment)
                                    Row(
                                      children: [
                                        CustomSvg(
                                          'assets/icons/attachment.svg',
                                          size: 14.w,
                                          fit: BoxFit.fitWidth,
                                          color: AppColors.text,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Attachment',
                                          style: TextStyle(
                                            color: AppColors.text,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ],
                            ],
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
                                DateTime.fromMillisecondsSinceEpoch(
                                  preview.created_at,
                                ),
                              ),
                              style: TextStyle(
                                color: AppColors.text.withValues(alpha: .8),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
