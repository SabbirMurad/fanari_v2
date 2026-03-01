import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/comment.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/heart_beat_animation.dart';
import 'package:fanari_v2/widgets/image_video_carousel.dart';
import 'package:fanari_v2/widgets/link_preview.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:fanari_v2/widgets/status_widget.dart';
import 'package:fanari_v2/widgets/youtube_attachment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart' as utils;

class CommentWidget extends StatefulWidget {
  final CommentModel model;

  const CommentWidget({super.key, required this.model});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _calculateCarouselHeight();
  }

  double carouselWidth = 1.sw - 40.w - 32.w - 12.w;
  double carouselHeight = 0;
  void _calculateCarouselHeight() {
    for (var image in widget.model.images) {
      double height = (carouselWidth * image.height) / image.width;

      if (height > carouselHeight) {
        carouselHeight = height;
      }
    }

    if (carouselHeight > carouselWidth * 1.25) {
      carouselHeight = carouselWidth * 1.25;
    }

    if (widget.model.images.length == 1) {
      final image = widget.model.images.first;
      carouselHeight = (carouselWidth * image.height) / image.width;
    }

    setState(() {});
  }

  Widget _commentInteractions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 18.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.secondary)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          HeartBeatAnimation(
            onChange: () {
              if (!_isLiked) {
                // controller.likePost(widget.postData.uuid, ref);
                setState(() {
                  _isLiked = true;
                });
              } else {
                // controller.unlikePost(widget.postData.uuid, ref);
                setState(() {
                  _isLiked = false;
                });
              }
            },
            selected: _isLiked,
            duration: const Duration(milliseconds: 160),
            scale: 1.2,
            selectedChild: CustomSvg(
              'assets/icons/heart_fill.svg',
              color: AppColors.primary,
              height: 18.h,
              width: 18.h,
              fit: BoxFit.fitHeight,
            ),
            unselectedChild: CustomSvg(
              'assets/icons/heart.svg',
              color: AppColors.text,
              height: 18.h,
              width: 18.h,
              fit: BoxFit.fitHeight,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            utils.format_number_magnitude(widget.model.like_count.toDouble()),
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 24),
                  CustomSvg(
                    'assets/icons/comment.svg',
                    color: AppColors.text,
                    height: 18.h,
                    width: 18.h,
                    fit: BoxFit.fitHeight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    utils.format_number_magnitude(
                      widget.model.reply_count.toDouble(),
                    ),
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileInfo() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.model.owner.profile.first_name +
                    ' ' +
                    widget.model.owner.profile.last_name,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                utils.pretty_date(widget.model.created_at),
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            // _openMoreOptions();
          },
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Icon(
              Icons.more_horiz_rounded,
              color: AppColors.text.withValues(alpha: 0.6),
              size: 18.w,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NamedAvatar(
            loading: false,
            image: widget.model.owner.profile.profile_picture,
            name: widget.model.owner.profile.first_name,
            size: 32.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profileInfo(),
                if (widget.model.caption != null)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: StatusWidget(
                      text: widget.model.caption!,
                      width: 1.sw - 40.w - 32.w - 12.w,
                      mentions: widget.model.mentions,
                      truncatedLines:
                          (widget.model.images.isEmpty &&
                              widget.model.link_preview == null &&
                              widget.model.youtube_attachment == null)
                          ? 8.7
                          : 2.5,
                    ),
                  ),
                if (widget.model.link_preview != null)
                  MyLinkPreview(
                    padding: EdgeInsets.only(top: 12.h),
                    previewData: widget.model.link_preview!,
                  ),
                if (widget.model.youtube_attachment != null)
                  YoutubeAttachmentWidget(
                    padding: EdgeInsets.only(top: 12.h),
                    width: 1.sw - 40.w - 32.w - 12.w,
                    model: widget.model.youtube_attachment!,
                  ),
                if (widget.model.images.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: ImageVideoCarousel(
                      borderRadius: BorderRadius.circular(10.r),
                      images: widget.model.images,
                      videos: [],
                      height: carouselHeight,
                      width: carouselWidth,
                    ),
                  ),
                _commentInteractions(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
