import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/constants/credential.dart';
import 'package:fanari_v2/model/post.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/heart_beat_animation.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:fanari_v2/widgets/status_widget.dart';
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
              fit: BoxFit.fitHeight,
            ),
            unselectedChild: CustomSvg(
              'assets/icons/heart.svg',
              color: AppColors.text,
              height: 20.h,
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
              fit: BoxFit.fitHeight,
            ),
            unselectedChild: CustomSvg(
              'assets/icons/bookmark.svg',
              color: AppColors.text,
              height: 20.h,
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
                          fontSize: 13,
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
              // _openMoreOptions(ref);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          _postTopBar(),
          if (widget.model.caption != null)
            StatusWidget(
              text: widget.model.caption!,
              width: 1.sw - 40.w,
              mentions: widget.model.mentions,
            ),
          _postInteractions(),
        ],
      ),
    );
  }
}
