import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/utils.dart' as utils;

class ImageUploaderVOne extends StatefulWidget {
  final double height;
  final String defaultImage;
  final ImageProvider? currentImage;
  final bool enable;
  final bool loading;
  final void Function(Uint8List)? onImageSelected;

  const ImageUploaderVOne({
    super.key,
    this.enable = true,
    this.defaultImage = 'assets/icons/basic/user.svg',
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

  void selectImage(ImageSource source) async {
    Uint8List? img = await utils.pickSingleImage(
      context: context,
      source: source,
      crop: false,
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
                        child: SvgPicture.asset(
                          widget.defaultImage,
                          width: widget.height * 0.8,
                          height: widget.height * 0.8,
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
                        color: image == null && widget.currentImage == null
                            ? Theme.of(context).colorScheme.tertiary
                            : null,
                      ),
              ),
            ),
          ),
          if (widget.loading)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: .3),
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.height / 2),
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: widget.height / 3.5,
                  height: widget.height / 3.5,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.surface,
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
                    child: SvgPicture.asset(
                      'assets/icons/basic/edit.svg',
                      color: AppColors.surface,
                      width: widget.height * .12,
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
