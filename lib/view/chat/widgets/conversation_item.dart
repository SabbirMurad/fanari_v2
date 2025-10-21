import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/widgets/bouncing_three_dot.dart';
import 'package:fanari_v2/widgets/cross_fade_box.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:flutter/material.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConversationItem extends StatefulWidget {
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
  State<ConversationItem> createState() => _ConversationItemState();
}

class _ConversationItemState extends State<ConversationItem> {
  Color? _bgColor() {
    if (widget.selected) return AppColors.primary.withValues(alpha: 0.2);
    if (widget.model.texts.isEmpty) return null;

    if (widget.model.texts.last.my_text) return null;

    if (widget.model.texts.last.seen_by.contains(widget.model.user_id))
      return null;

    return AppColors.surface;
  }

  FontWeight _textWeight() {
    if (widget.model.texts.isEmpty) return FontWeight.w400;

    if (widget.model.texts.last.my_text) return FontWeight.w400;

    if (widget.model.texts.last.seen_by.contains(widget.model.user_id))
      return FontWeight.w400;

    return FontWeight.w600;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.selectMode) {
          if (widget.selected) {
            widget.onDeSelect?.call(widget.model.uuid);
          } else {
            widget.onSelect?.call(widget.model.uuid);
          }
          return;
        }

        widget.onTap?.call();
      },
      onLongPress: () {
        if (widget.selected) return;
        widget.onSelect?.call(widget.model.uuid);
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
                alignment: Alignment(0.9, 0.8),
                children: [
                  NamedAvatar(
                    loading: false,
                    imageUrl: widget.model.image?.url,
                    name: widget.model.name,
                    size: 56.w,
                  ),
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: widget.model.online
                          ? Colors.green[400]
                          : Color.fromARGB(255, 102, 105, 103),
                      shape: BoxShape.circle,
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
                    Hero(
                      tag: (widget.model.uuid + 'name'),
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          widget.model.name,
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
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
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
                                if (widget.model.texts.isEmpty)
                                  Text(
                                    'You can now start a conversation',
                                    style: TextStyle(
                                      color: AppColors.text,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (widget.model.texts.isNotEmpty) ...[
                                  if (widget.model.texts.last.type ==
                                      TextType.Text)
                                    Text(
                                      widget.model.texts.last.text!,
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontSize: 13.sp,
                                        fontWeight: _textWeight(),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (widget.model.texts.last.type ==
                                      TextType.Image)
                                    Row(
                                      children: [
                                        CustomSvg(
                                          'assets/icons/gallery.svg',
                                          size: 18.w,
                                          fit: BoxFit.fitWidth,
                                          color: AppColors.text,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          '${widget.model.texts.last.images.length} image${widget.model.texts.last.images.length > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            color: AppColors.text,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (widget.model.texts.last.type ==
                                      TextType.Audio)
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
                                  if (widget.model.texts.last.type ==
                                      TextType.Attachment)
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
                        ),
                        if (widget.model.texts.isNotEmpty)
                          Container(
                            margin: EdgeInsets.only(left: 6, right: 6),
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.text.withValues(alpha: .8),
                            ),
                          ),
                        if (widget.model.texts.isNotEmpty)
                          Text(
                            utils.timeAgo(
                              DateTime.fromMillisecondsSinceEpoch(
                                widget.model.texts.last.created_at,
                              ),
                            ),
                            style: TextStyle(
                              color: AppColors.text.withValues(alpha: .8),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
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
