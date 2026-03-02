import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/youtube.dart';
import 'package:fanari_v2/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class YoutubeAttachmentWidget extends StatefulWidget {
  final double width;
  final YoutubeModel model;
  final Color? textColor;
  final Color? sidebarColor;
  final BorderRadius? sidebarBorderRadius;
  final double sidebarWidth;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  static String openExternalIcon =
      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><g transform="translate(-3 -3)"><path d="M10.651,6a.875.875,0,0,0,0,1.749h4.858L8.256,15a.875.875,0,0,0,1.237,1.237l7.252-7.252v4.858a.875.875,0,1,0,1.749,0V6.875A.875.875,0,0,0,17.62,6Z" transform="translate(3.441 2.065)" fill="#f9f9f9"/><path d="M19.741,27a4.287,4.287,0,0,0,4.234-3.617A4.288,4.288,0,0,0,27,19.286v-12A4.286,4.286,0,0,0,22.714,3h-12A4.288,4.288,0,0,0,6.6,6.081,4.287,4.287,0,0,0,3,10.312V21a6,6,0,0,0,6,6ZM4.714,10.312A2.572,2.572,0,0,1,6.429,7.887v11.4a4.286,4.286,0,0,0,4.286,4.286H22.166a2.573,2.573,0,0,1-2.425,1.714H9A4.286,4.286,0,0,1,4.714,21Zm6-5.6h12a2.571,2.571,0,0,1,2.571,2.571v12a2.571,2.571,0,0,1-2.571,2.571h-12a2.571,2.571,0,0,1-2.571-2.571v-12A2.571,2.571,0,0,1,10.714,4.714Z" fill="#f9f9f9"/></g></svg>';

  static String playIcon =
      '<svg xmlns="http://www.w3.org/2000/svg" width="16.532" height="19.839" viewBox="0 0 16.532 19.839"><path d="M111.975,72.726,97.591,64.165A1.085,1.085,0,0,0,97.028,64a1.031,1.031,0,0,0-1.023,1.033H96V82.806h.005a1.031,1.031,0,0,0,1.023,1.033,1.182,1.182,0,0,0,.579-.176l14.368-8.55a1.555,1.555,0,0,0,0-2.387Z" transform="translate(-96 -64)" fill="#f9f9f9"/></svg>';

  static String youtubeIcon =
      '<svg xmlns="http://www.w3.org/2000/svg" width="32.579" height="22.907" viewBox="0 0 32.579 22.907"><g transform="translate(-26.001 -94.282)"><g transform="translate(26.001 94.282)"><path d="M57.9,97.866a4.094,4.094,0,0,0-2.88-2.9c-2.541-.685-12.728-.685-12.728-.685s-10.188,0-12.729.685a4.094,4.094,0,0,0-2.88,2.9,46.092,46.092,0,0,0,0,15.785,4.033,4.033,0,0,0,2.88,2.853c2.541.685,12.729.685,12.729.685s10.188,0,12.728-.685a4.033,4.033,0,0,0,2.88-2.853,46.093,46.093,0,0,0,0-15.785Z" transform="translate(-26.001 -94.282)" fill="red"/><path d="M208.954,197.618V187.93l8.515,4.844Z" transform="translate(-195.996 -181.297)" fill="#fff"/></g></g></svg>';

  const YoutubeAttachmentWidget({
    super.key,
    required this.width,
    required this.model,
    this.textColor,
    this.padding,
    this.margin,
    this.sidebarColor,
    this.sidebarBorderRadius,
    this.backgroundColor,
    this.sidebarWidth = 8,
  });

  @override
  State<YoutubeAttachmentWidget> createState() =>
      _YoutubeAttachmentWidgetState();
}

class _YoutubeAttachmentWidgetState extends State<YoutubeAttachmentWidget> {
  late double thumbnailWidth = widget.width;
  late double thumbnailHeight =
      widget.model.thumbnail.height > widget.model.thumbnail.width
      ? thumbnailWidth * (16 / 9)
      : thumbnailWidth * (9 / 16);

  late String _embedHtml =
      '''
    <iframe width="${thumbnailWidth * MediaQuery.of(context).devicePixelRatio}" height="${thumbnailHeight * MediaQuery.of(context).devicePixelRatio}" src="https://www.youtube.com/embed/${widget.model.id}?autoplay=1&mute=1&rel=0&showinfo=0&modestbranding=0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
                      ''';

  @override
  void initState() {
    super.initState();
  }

  bool _isPlaying = false;
  bool _loading = false;

  Widget _iconAndDuration() {
    return Positioned(
      bottom: 0,
      child: Container(
        width: thumbnailWidth - 24.w,
        margin: EdgeInsets.only(bottom: 12.w),
        child: Row(
          children: [
            SvgPicture.string(
              YoutubeAttachmentWidget.youtubeIcon,
              height: 22.w,
            ),
            Spacer(),
            Text(
              widget.model.content_details.duration,
              style: TextStyle(
                color: widget.textColor ?? AppColors.text,
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
                shadows: [
                  BoxShadow(color: Color(0xff242424), blurRadius: 20.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return GlassContainer(
      padding: EdgeInsets.symmetric(vertical: 14.w, horizontal: 32.w),
      borderRadius: BorderRadius.circular(28.r),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isPlaying = true;
                _loading = true;
              });

              Future.delayed(const Duration(milliseconds: 2500), () {
                setState(() {
                  _loading = false;
                });
              });
            },
            child: SvgPicture.string(
              YoutubeAttachmentWidget.playIcon,
              width: 22.w,
              height: 22.w,
            ),
          ),
          SizedBox(width: 36.w),
          GestureDetector(
            onTap: () {
              launchUrl(
                Uri.parse(widget.model.url),
                mode: LaunchMode.externalApplication,
              );
            },
            child: SvgPicture.string(
              YoutubeAttachmentWidget.openExternalIcon,
              width: 22.w,
              height: 22.w,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: thumbnailWidth,
      padding: widget.padding,
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (_isPlaying)
                Container(
                  width: thumbnailWidth,
                  height: thumbnailHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(10.r),
                    child: HtmlWidget(_embedHtml),
                  ),
                ),
              if (!_isPlaying || _loading)
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(10.r),
                  child: CachedNetworkImage(
                    imageUrl: widget.model.thumbnail.url,
                    width: thumbnailWidth,
                    fit: BoxFit.cover,
                    height: thumbnailHeight,
                    placeholder: (context, url) {
                      return Container(
                        color: AppColors.secondary,
                        width: thumbnailWidth,
                        height: thumbnailHeight,
                      );
                    },
                    errorWidget: (context, url, error) =>
                        Icon(Icons.error, color: AppColors.primary),
                  ),
                ),
              if (!_isPlaying && !_loading) _iconAndDuration(),
              if (!_isPlaying && !_loading) _actionButtons(),
              if (_loading)
                Container(
                  width: 52.w,
                  height: 52.w,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3.5,
                  ),
                ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    launchUrl(
                      Uri.parse(widget.model.url),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.model.title,
                        style: TextStyle(
                          color: widget.textColor ?? AppColors.text,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.model.channel_title,
                        style: TextStyle(
                          color: widget.textColor ?? AppColors.textSecondary,
                          fontSize: 13.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.model.statistics.view_count != null)
                Padding(
                  padding: EdgeInsets.only(left: 8.w, top: 4.h),
                  child: Text(
                    '${utils.format_number_magnitude(widget.model.statistics.view_count!.toDouble()).toString()} Views',
                    style: TextStyle(
                      color: widget.textColor ?? AppColors.text,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
