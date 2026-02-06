import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/utils.dart' as utils;

class ImageUploaderVOne extends StatefulWidget {
  final double height;
  final String? defaultImage;
  final ImageProvider? currentImage;
  final bool enable;
  final bool loading;
  final void Function(Uint8List)? onImageSelected;

  const ImageUploaderVOne({
    super.key,
    this.enable = true,
    this.defaultImage,
    this.currentImage,
    this.onImageSelected,
    this.height = 84,
    this.loading = false,
  });

  @override
  State<ImageUploaderVOne> createState() => _ImageUploaderVOneState();
}

class _ImageUploaderVOneState extends State<ImageUploaderVOne> {
  Uint8List? image;

  static String userIcon = '''
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M16 7C16 9.20914 14.2091 11 12 11C9.79086 11 8 9.20914 8 7C8 4.79086 9.79086 3 12 3C14.2091 3 16 4.79086 16 7Z" stroke="white" stroke-width="1.5"/>
  <path d="M14 14H10C7.23858 14 5 16.2386 5 19C5 20.1046 5.89543 21 7 21H17C18.1046 21 19 20.1046 19 19C19 16.2386 16.7614 14 14 14Z" stroke="white" stroke-width="1.5" stroke-linejoin="round"/>
  </svg>
  ''';

  static String cameraIcon = '''
<?xml version="1.0" ?><!DOCTYPE svg><svg enable-background="new 0 0 48 48" height="48px" id="Layer_1" version="1.1" viewBox="0 0 48 48" width="48px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><path clip-rule="evenodd" d="M43,41H5c-2.209,0-4-1.791-4-4V15c0-2.209,1.791-4,4-4h1l0,0c0-1.104,0.896-2,2-2  h2c1.104,0,2,0.896,2,2h2c0,0,1.125-0.125,2-1l2-2c0,0,0.781-1,2-1h8c1.312,0,2,1,2,1l2,2c0.875,0.875,2,1,2,1h9  c2.209,0,4,1.791,4,4v22C47,39.209,45.209,41,43,41z M45,15c0-1.104-0.896-2-2-2l-9.221-0.013c-0.305-0.033-1.889-0.269-3.193-1.573  l-2.13-2.13l-0.104-0.151C28.351,9.132,28.196,9,28,9h-8c-0.153,0-0.375,0.178-0.424,0.231l-0.075,0.096l-2.087,2.086  c-1.305,1.305-2.889,1.54-3.193,1.573l-4.151,0.006C10.046,12.994,10.023,13,10,13H8c-0.014,0-0.026-0.004-0.04-0.004L5,13  c-1.104,0-2,0.896-2,2v22c0,1.104,0.896,2,2,2h38c1.104,0,2-0.896,2-2V15z M24,37c-6.075,0-11-4.925-11-11s4.925-11,11-11  s11,4.925,11,11S30.075,37,24,37z M24,17c-4.971,0-9,4.029-9,9s4.029,9,9,9s9-4.029,9-9S28.971,17,24,17z M24,31  c-2.762,0-5-2.238-5-5s2.238-5,5-5s5,2.238,5,5S26.762,31,24,31z M24,23c-1.656,0-3,1.344-3,3c0,1.657,1.344,3,3,3  c1.657,0,3-1.343,3-3C27,24.344,25.657,23,24,23z M10,19H6c-0.553,0-1-0.447-1-1v-2c0-0.552,0.447-1,1-1h4c0.553,0,1,0.448,1,1v2  C11,18.553,10.553,19,10,19z" fill-rule="evenodd"/></svg>
  ''';

  void selectImage(ImageSource source) async {
    Uint8List? img = await utils.pickSingleImage(
      context: context,
      source: source,
      // crop: false,
    );

    if (img != null) {
      setState(() {
        image = img;
      });

      widget.onImageSelected?.call(img);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.height,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.only(bottom: 4.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (image != null || widget.currentImage != null) {
                      if (image != null) {
                        utils.openImageViewer(
                          context: context,
                          images: [MemoryImage(image!)],
                        );
                      } else {
                        utils.openImageViewer(
                          context: context,
                          images: [widget.currentImage!],
                        );
                      }
                    } else {
                      if (widget.enable) {
                        utils.showImagePickerOptions(context, selectImage);
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.containerBg,
                      borderRadius: BorderRadius.all(
                        Radius.circular(widget.height / 2),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(widget.height / 2),
                      ),
                      child: image == null && widget.currentImage == null
                          ? Center(
                              child: widget.defaultImage != null
                                  ? SvgPicture.asset(
                                      widget.defaultImage!,
                                      width: widget.height * 0.7,
                                      height: widget.height * 0.7,
                                      fit: BoxFit.cover,
                                      color: AppColors.textDeemed,
                                    )
                                  : SvgPicture.string(
                                      userIcon,
                                      width: widget.height * 0.7,
                                      height: widget.height * 0.7,
                                      fit: BoxFit.cover,
                                      color: AppColors.textDeemed,
                                    ),
                            )
                          : Image(
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              image: image != null
                                  ? MemoryImage(image!)
                                  : widget.currentImage!,
                              color: AppColors.secondary,
                            ),
                    ),
                  ),
                ),
                if (widget.loading)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: .3),
                      borderRadius: BorderRadius.all(
                        Radius.circular(widget.height / 2),
                      ),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: widget.height / 3.5,
                        height: widget.height / 3.5,
                        child: CircularProgressIndicator(
                          color: AppColors.surface,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.enable)
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  if (!widget.loading) {
                    utils.showImagePickerOptions(context, selectImage);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50.r)),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xffffffff).withValues(alpha: 0.18),
                        Color(0xffffffff).withValues(alpha: 0.28),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4.w,
                    children: [
                      SvgPicture.string(
                        cameraIcon,
                        color: AppColors.text,
                        width: widget.height * .12,
                      ),
                      Text(
                        'Upload',
                        style: TextStyle(color: AppColors.text, fontSize: 9.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
