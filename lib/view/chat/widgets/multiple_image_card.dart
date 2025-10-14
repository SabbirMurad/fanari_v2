import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart' as utils;
// import 'package:vector_math/vector_math.dart';

class MultipleImageCard extends StatefulWidget {
  final TextDirection decoration;
  final List<ImageModel> images;

  const MultipleImageCard({
    super.key,
    required this.images,
    this.decoration = TextDirection.ltr,
  });

  @override
  State<MultipleImageCard> createState() => _MultipleImageCardState();
}

class _MultipleImageCardState extends State<MultipleImageCard> {
  Widget _image(ImageModel image) {
    return Container(
      width: 146.w,
      height: 183.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Color(0xff242424).withValues(alpha: 0.65),
            blurRadius: 6,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: CachedNetworkImage(
          imageUrl: image.url,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return Container(
              color: AppColors.secondary,
              width: double.infinity,
              height: double.infinity,
            );
          },
          errorWidget: (context, url, error) => Container(
            color: AppColors.secondary,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(24, 24, 24, 0.8),
                  border: Border.all(color: Colors.white.withValues(alpha: .1)),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(24, 24, 24, .2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Couldn\'t load image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.decoration == TextDirection.rtl)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.images.length > 3)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.w),
                  child: Text(
                    '+${widget.images.length - 3}',
                    style: TextStyle(color: AppColors.text, fontSize: 36.sp),
                  ),
                ),
              downloadBtn,
            ],
          ),
        GestureDetector(
          onTap: () {
            utils.openImageViewer(
              context: context,
              images: widget.images
                  .map((e) => CachedNetworkImageProvider(e.url))
                  .toList(),
              preLoad: 2,
            );
          },
          child: Container(
            margin: EdgeInsets.only(
              left: widget.decoration == TextDirection.rtl ? 24.w : 0,
              right: widget.decoration == TextDirection.ltr ? 24.w : 0,
            ),
            // color: Colors.green,
            padding: EdgeInsets.only(top: 20.w, bottom: 16.w, right: 60.w),
            child: Stack(
              children: [
                if (widget.images.length > 2)
                  Transform(
                    transformHitTests: true,
                    transform: Matrix4.identity()
                      ..rotateZ(3.14 / 7.5)
                      ..translate(-8.w, -8.w),
                    alignment: Alignment.bottomCenter,
                    child: _image(widget.images[2]),
                  ),
                if (widget.images.length > 1)
                  Transform(
                    transformHitTests: true,
                    transform: Matrix4.identity()
                      ..rotateZ(3.14 / 15)
                      ..translate(-6.w, -6.w),
                    alignment: Alignment.bottomCenter,
                    child: _image(widget.images[1]),
                  ),
                _image(widget.images[0]),
              ],
            ),
          ),
        ),
        if (widget.decoration == TextDirection.ltr)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.images.length > 3)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.w),
                  child: Text(
                    '+${widget.images.length - 3}',
                    style: TextStyle(color: AppColors.text, fontSize: 36.sp),
                  ),
                ),
              downloadBtn,
            ],
          ),
      ],
    );
  }
}
