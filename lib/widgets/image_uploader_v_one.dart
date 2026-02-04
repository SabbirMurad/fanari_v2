import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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

  static String editIcon = '''
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M8.17157 19.8284L19.8285 8.17157C20.3737 7.62632 20.6463 7.3537 20.7921 7.0596C21.0694 6.50005 21.0694 5.8431 20.7921 5.28354C20.6463 4.98945 20.3737 4.71682 19.8285 4.17157C19.2832 3.62632 19.0106 3.3537 18.7165 3.20796C18.1569 2.93068 17.5 2.93068 16.9404 3.20796C16.6463 3.3537 16.3737 3.62632 15.8285 4.17157L4.17157 15.8284C3.59351 16.4064 3.30448 16.6955 3.15224 17.063C3 17.4305 3 17.8393 3 18.6568V20.9999H5.34314C6.16065 20.9999 6.5694 20.9999 6.93694 20.8477C7.30448 20.6955 7.59351 20.4064 8.17157 19.8284Z" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 21H18" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M14.5 5.5L18.5 9.5" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
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
          if (widget.enable)
            Align(
              alignment: const Alignment(0.95, 0.9),
              child: GestureDetector(
                onTap: () {
                  if (!widget.loading) {
                    utils.showImagePickerOptions(context, selectImage);
                  }
                },
                child: Container(
                  width: widget.height * .24,
                  height: widget.height * .24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.height * .08),
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.string(
                      editIcon,
                      color: AppColors.text,
                      width: widget.height * .18,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
