import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/view/chat/widgets/multiple_image_card.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/link_preview.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:fanari_v2/widgets/status_widget.dart';
import 'package:fanari_v2/widgets/youtube_attachment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fanari_v2/utils.dart' as utils;

class TextItemWidget extends StatefulWidget {
  final TextModel model;
  final bool selectMode;
  final bool selected;
  final Function(String)? onSelect;
  final Function(String)? onDeSelect;
  final Function()? onReply;
  final bool showProfile;
  final EdgeInsetsGeometry? margin;

  const TextItemWidget({
    super.key,
    required this.model,
    this.selectMode = false,
    this.selected = false,
    this.onSelect,
    this.margin,
    this.onDeSelect,
    this.onReply,
    this.showProfile = true,
  });

  @override
  State<TextItemWidget> createState() => _TextItemWidgetState();
}

class _TextItemWidgetState extends State<TextItemWidget> {
  double _maxTextWidth = 0.75.sw;
  double _replyButtonOpacity = 0;
  Timer? _timer;
  Timer? _timer2;
  bool _showTime = false;
  double _swipeOffset = 0;
  double _maxSwipeOffset = 50;
  double _swipeFlexibility = 0.65;

  Widget _gestureHandler({required Widget child}) {
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

        setState(() {
          _showTime = true;
        });

        _timer?.cancel();
        _timer = Timer(const Duration(milliseconds: 2000), () {
          setState(() {
            _showTime = false;
          });
        });
      },
      onLongPress: () {
        widget.onSelect?.call(widget.model.uuid);
      },
      onPanUpdate: (details) {
        if (widget.model.my_text) {
          if (_swipeOffset + details.delta.dx > 0 ||
              _swipeOffset + details.delta.dx < (-1 * _maxSwipeOffset))
            return;

          if (_swipeOffset + details.delta.dx < (-1 * (_maxSwipeOffset / 2))) {
            setState(() {
              _replyButtonOpacity = 1;
            });
          }
        } else {
          if (_swipeOffset + details.delta.dx < 0 ||
              _swipeOffset + details.delta.dx > _maxSwipeOffset)
            return;

          if (_swipeOffset + details.delta.dx > (_maxSwipeOffset / 2)) {
            setState(() {
              _replyButtonOpacity = 1;
            });
          }
        }

        setState(() {
          _swipeOffset += details.delta.dx;
        });
      },
      onPanEnd: (details) {
        setState(() {
          _replyButtonOpacity = 0;
        });

        _timer2 = Timer.periodic(Duration(milliseconds: 1), (timer) {
          if (_swipeOffset > 0) {
            if (_swipeOffset < 1) {
              setState(() {
                _swipeOffset = 0;
              });
            } else {
              setState(() {
                _swipeOffset--;
              });
            }
          } else if (_swipeOffset < 0) {
            if (_swipeOffset > -1) {
              setState(() {
                _swipeOffset = 0;
              });
            } else {
              setState(() {
                _swipeOffset++;
              });
            }
          }

          if (_swipeOffset == 0) {
            timer.cancel();
          }
        });
        if (_swipeOffset < 0) {
          if ((_swipeOffset / _swipeFlexibility) <= (-1 * _maxSwipeOffset)) {
            widget.onReply?.call();
          }
        } else {
          if ((_swipeOffset / _swipeFlexibility) >= _maxSwipeOffset) {
            widget.onReply?.call();
          }
        }
      },
      child: child,
    );
  }

  Widget _text() {
    return Container(
      transform: Matrix4.translationValues(_swipeOffset, 0, 0),
      constraints: BoxConstraints(maxWidth: _maxTextWidth),
      child: Column(
        crossAxisAlignment: widget.model.my_text
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: _maxTextWidth),
            decoration: BoxDecoration(
              color: widget.model.my_text
                  ? const Color.fromARGB(255, 163, 186, 255)
                  : AppColors.secondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.r),
                topRight: Radius.circular(10.r),
                bottomLeft: Radius.circular(widget.model.my_text ? 10.r : 4.r),
                bottomRight: Radius.circular(widget.model.my_text ? 4.r : 10.r),
              ),
            ),
            padding: EdgeInsets.all(10.w),
            child: StatusWidget(
              text: widget.model.text!,
              width: _maxTextWidth,
              mentions: [],
              // selectable: false,
              fontSize: 14.sp,
              textColor: widget.model.my_text
                  ? AppColors.surface
                  : AppColors.text,
            ),
          ),
          if (widget.model.youtube_attachment != null)
            YoutubeAttachmentWidget(
              width: _maxTextWidth,
              model: widget.model.youtube_attachment!,
              margin: EdgeInsets.only(top: 12.h),
            ),
          if (widget.model.link_preview != null)
            MyLinkPreview(
              width: _maxTextWidth,
              previewData: widget.model.link_preview!,
              imageWidth: 56.w,
              margin: EdgeInsets.only(top: 12.h),
            ),
        ],
      ),
    );
  }

  Widget _singleImage() {
    double carouselHeight = 0.3.sh;

    double imageWidth =
        (carouselHeight * widget.model.images.first.width) /
        widget.model.images.first.height;
    if (imageWidth > _maxTextWidth) {
      imageWidth = _maxTextWidth;
    }

    final downloadBtn = GestureDetector(
      onTap: () async {
        // _downloadImage(
        //   widget.model.images.first.url,
        //   '${DateTime.now().toString()}.jpg',
        // );
      },
      child: Container(
        width: 36.w,
        height: 36.w,
        margin: EdgeInsets.only(
          right: widget.model.my_text ? 8.w : 0,
          left: widget.model.my_text ? 0 : 8.w,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary,
        ),
        child: Center(
          child: CustomSvg(
            'assets/icons/download.svg',
            color: AppColors.text,
            size: 14.w,
          ),
        ),
      ),
    );

    final imageContainer = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: GestureDetector(
        onTap: () {
          if (widget.selectMode) {
            if (widget.selected) {
              widget.onDeSelect?.call(widget.model.uuid);
            } else {
              widget.onSelect?.call(widget.model.uuid);
            }
            return;
          }

          utils.openImageViewer(
            context: context,
            images: [widget.model.images.first.provider],
          );
        },
        child: CachedNetworkImage(
          imageUrl: widget.model.images.first.url,
          width: imageWidth,
          height: carouselHeight,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return Container(color: Theme.of(context).colorScheme.secondary);
          },
          errorWidget: (context, url, error) {
            return Container(
              color: Theme.of(context).colorScheme.secondary,
              child: Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white,
                  size: imageWidth * 0.30,
                ),
              ),
            );
          },
        ),
      ),
    );

    return Container(
      transform: Matrix4.translationValues(_swipeOffset, 0, 0),
      margin: EdgeInsets.only(
        left: widget.model.my_text ? 8 : 0,
        right: widget.model.my_text ? 0 : 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.model.my_text
            ? [downloadBtn, imageContainer]
            : [imageContainer, downloadBtn],
      ),
    );
  }

  Widget _multipleImagesWidget() {
    return MultipleImageCard(
      images: widget.model.images,
      decoration: widget.model.my_text ? TextDirection.rtl : TextDirection.ltr,
    );
  }

  Widget _typeHandler() {
    if (widget.model.type == TextType.Text) return _text();
    if (widget.model.type == TextType.Image) {
      if (widget.model.images.length == 1) {
        return _singleImage();
      }
      return _multipleImagesWidget();
    }

    // : widget.model.type == TextType.Emoji
    // ? emoji != null
    //       ? _emoji(emoji)
    //       : Container()
    // : widget.model.type == TextType.Audio
    // ? _audioWidget(maxTextWidth)
    return Container(width: 50, height: 50, color: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.selected) return;
        widget.onDeSelect?.call(widget.model.uuid);
      },
      child: Container(
        width: double.infinity,
        color: widget.selected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: .3)
            : null,
        margin: widget.margin ?? EdgeInsets.only(bottom: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.model.my_text
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // if (_replyTo != null) _replyToWidget(maxTextWidth),
            Row(
              mainAxisAlignment: widget.model.my_text
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.model.my_text && widget.showProfile)
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    child: NamedAvatar(
                      loading: false,
                      name: 'Sabbir',
                      size: 36.w,
                    ),
                  ),
                if (!widget.model.my_text && !widget.showProfile)
                  SizedBox(width: 36.w + 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Stack(
                    alignment: widget.model.my_text
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    children: [
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 100),
                        opacity: _replyButtonOpacity,
                        child: SvgPicture.asset(
                          "assets/icons/${widget.model.my_text ? 'enter' : 'enter_rotated'}.svg",
                          width: 24.w,
                          color: AppColors.text,
                        ),
                      ),
                      _gestureHandler(child: _typeHandler()),
                    ],
                  ),
                ),
              ],
            ),
            // if (widget.model.type == MessageType.Image &&
            //     widget.model.images.length > 1)
            //   _multipleImages(),
            // _textTime(),
          ],
        ),
      ),
    );
  }
}
