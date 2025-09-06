import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/constants/credential.dart';
import 'package:fanari_v2/model/post.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/view/home/widgets/poll.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/glass_container.dart';
import 'package:fanari_v2/widgets/heart_beat_animation.dart';
import 'package:fanari_v2/widgets/image_video_carousel.dart';
import 'package:fanari_v2/widgets/link_preview.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:fanari_v2/widgets/status_widget.dart';
import 'package:fanari_v2/widgets/youtube_attachment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fanari_v2/utils.dart' as utils;

class PostWidget extends StatefulWidget {
  final PostModel model;

  const PostWidget({super.key, required this.model});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;
  bool _openingShare = false;

  @override
  void initState() {
    super.initState();
    _calculateCarouselHeight();
  }

  bool _bookMarked = false;
  Widget _postInteractions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.secondary)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              height: 20.h,
              width: 20.h,
              fit: BoxFit.fitHeight,
            ),
            unselectedChild: CustomSvg(
              'assets/icons/heart.svg',
              color: AppColors.text,
              height: 20.h,
              width: 20.h,
              fit: BoxFit.fitHeight,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            utils.formatNumberMagnitude(widget.model.like_count.toDouble()),
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () {
              // _openComments(context);
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (_) {
              //       return PostDetailsPage(
              //         postId: widget.postData.uuid,
              //         model: widget.postData,
              //       );
              //     },
              //   ),
              // );
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 24),
                  CustomSvg(
                    'assets/icons/comment.svg',
                    color: AppColors.text,
                    height: 20.h,
                    width: 20.h,
                    fit: BoxFit.fitHeight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    utils.formatNumberMagnitude(
                      widget.model.comment_count.toDouble(),
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
          const Spacer(),
          GestureDetector(
            onTap: () async {
              if (_openingShare) return;
              _openingShare = true;
              final box = context.findRenderObject() as RenderBox?;

              await Share.share(
                "${AppCredentials.domain}/post/${widget.model.uuid}",
                subject: 'this is the subject',
                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
              );

              _openingShare = false;
            },
            child: CustomSvg(
              'assets/icons/share.svg',
              color: AppColors.text,
              height: 20.h,
              width: 20.h,
              fit: BoxFit.fitHeight,
            ),
          ),
          SizedBox(width: 24.w),
          HeartBeatAnimation(
            onChange: () {
              setState(() {
                _bookMarked = !_bookMarked;
              });
            },
            selected: _bookMarked,
            duration: const Duration(milliseconds: 160),
            scale: 1.2,
            selectedChild: CustomSvg(
              'assets/icons/bookmark_fill.svg',
              color: AppColors.text,
              height: 20.h,
              width: 20.h,
              fit: BoxFit.fitHeight,
            ),
            unselectedChild: CustomSvg(
              'assets/icons/bookmark.svg',
              color: AppColors.text,
              height: 20.h,
              width: 20.h,
              fit: BoxFit.fitHeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _postTopBar() {
    return Container(
      padding: EdgeInsets.only(bottom: 18.h, top: 24.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                AppRoutes.push(AppRoutes.landing);
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: NamedAvatar(
                      loading: false,
                      imageUrl: widget.model.owner.image?.url,
                      name: widget.model.owner.name,
                      size: 40.w,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.model.owner.name,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        utils.prettyDate(widget.model.created_at),
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _openMoreOptions();
            },
            icon: Container(
              child: Icon(
                Icons.more_horiz_rounded,
                color: AppColors.text.withValues(alpha: 0.6),
                size: 24.h,
              ),
            ),
          ),
        ],
      ),
    );
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
                  child: GlassContainer(
                    blurStrength: 12,
                    width: 1.sw - 40.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 35.w,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _moreOptionItem(
                          icon: 'assets/icons/more_options/share.svg',
                          text: 'Share',
                          onTap: () {},
                          padding: EdgeInsets.only(bottom: 14.h),
                        ),
                        _moreOptionItem(
                          icon: 'assets/icons/more_options/copy.svg',
                          text: 'Copy Post URL',
                          onTap: () {},
                        ),
                        _moreOptionItem(
                          icon: 'assets/icons/more_options/bookmark.svg',
                          text: 'Bookmark',
                          onTap: () {},
                        ),
                        _moreOptionItem(
                          icon: 'assets/icons/more_options/dislike.svg',
                          text: 'Not Interested',
                          onTap: () {},
                        ),
                        _moreOptionItem(
                          icon: 'assets/icons/more_options/not_allowed.svg',
                          text: 'Report',
                          onTap: () {},
                          color: Colors.red[400],
                          padding: EdgeInsets.only(top: 14.h, bottom: 28.h),
                        ),
                        Container(
                          width: double.infinity,
                          height: 1.h,
                          color: AppColors.text.withValues(alpha: 0.5),
                        ),
                        _moreOptionItem(
                          icon: 'assets/icons/more_options/eye.svg',
                          text: 'View Profile',
                          onTap: () {},
                          padding: EdgeInsets.only(bottom: 14.h, top: 28.h),
                        ),
                        _moreOptionItem(
                          icon: 'assets/icons/more_options/follow.svg',
                          text: 'Follow Sabbir',
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

  double carouselWidth = 1.sw;
  double carouselHeight = 0;
  void _calculateCarouselHeight() {
    for (var image in widget.model.images) {
      double height = (1.sw * image.height) / image.width;

      if (height > carouselHeight) {
        carouselHeight = height;
      }
    }

    for (var video in widget.model.videos) {
      double height = (1.sw * video.height) / video.width;

      if (height > carouselHeight) {
        carouselHeight = height;
      }
    }

    if (carouselHeight > 1.sw * 1.25) {
      carouselHeight = 1.sw * 1.25;
    }

    if (widget.model.images.length + widget.model.videos.length == 1) {
      if (widget.model.images.length == 1) {
        final image = widget.model.images.first;
        carouselHeight = (1.sw * image.height) / image.width;
      } else {
        final video = widget.model.videos.first;
        carouselHeight = (1.sw * video.height) / video.width;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _postTopBar(),
          if (widget.model.caption != null)
            StatusWidget(
              text: widget.model.caption!,
              width: 1.sw - 40.w,
              mentions: widget.model.mentions,
              truncatedLines:
                  (widget.model.images.isEmpty &&
                      widget.model.videos.isEmpty &&
                      widget.model.link_preview == null &&
                      widget.model.youtube_attachment == null)
                  ? 10
                  : 3,
            ),
          if (widget.model.link_preview != null)
            MyLinkPreview(
              padding: EdgeInsets.only(top: 12.h),
              image: widget.model.link_preview!.image != null
                  ? widget.model.link_preview!.image!.url
                  : null,
              title: widget.model.link_preview!.title,
              description: widget.model.link_preview!.description,
            ),
          if (widget.model.youtube_attachment != null)
            YoutubeAttachmentWidget(
              padding: EdgeInsets.only(top: 12.h),
              width: 1.sw - 40.w,
              model: widget.model.youtube_attachment!,
            ),
          if (widget.model.images.isNotEmpty || widget.model.videos.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: ImageVideoCarousel(
                borderRadius: BorderRadius.circular(10.r),
                images: widget.model.images,
                videos: widget.model.videos,
                height: carouselHeight,
                width: carouselWidth,
              ),
            ),
          if (widget.model.poll != null)
            PollWidget(
              model: widget.model.poll!,
              padding: EdgeInsets.only(top: 12.h),
            ),
          _postInteractions(),
        ],
      ),
    );
  }
}
