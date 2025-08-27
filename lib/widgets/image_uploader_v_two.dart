import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fanari_v2/utils.dart' as utils;

class ImageUploaderVTwo extends StatefulWidget {
  final ImageProvider defaultImage;
  final double height;
  final ImageProvider? currentImage;
  final bool enable;
  final void Function(Uint8List)? onImageSelected;

  const ImageUploaderVTwo({
    super.key,
    this.enable = true,
    required this.defaultImage,
    this.currentImage,
    this.onImageSelected,
    this.height = 200,
  });

  @override
  State<ImageUploaderVTwo> createState() => _ImageUploaderVTwoState();
}

class _ImageUploaderVTwoState extends State<ImageUploaderVTwo> {
  Uint8List? image;

  void selectImage(ImageSource source) async {
    Uint8List? img = await utils.pickSingleImage(
      context: context,
      source: source,
    );

    if (img != null) {
      setState(() {
        image = img;
      });

      widget.onImageSelected?.call(img);
    }
  }

  ImageProvider getImage() {
    if (image != null) {
      return MemoryImage(image!);
    } else {
      if (widget.currentImage != null) {
        return widget.currentImage!;
      } else {
        return widget.defaultImage;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, -1),
          child: GestureDetector(
            onTap: () {
              utils.openImageViewer(context: context, images: [getImage()]);
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              child: Image(
                width: double.infinity,
                height: widget.height,
                fit: BoxFit.cover,
                image: getImage(),
              ),
            ),
          ),
        ),
        if (widget.enable)
          Align(
            alignment: const Alignment(0.95, -0.9),
            child: GestureDetector(
              onTap: () {
                utils.showImagePickerOptions(context, selectImage);
              },
              child: CircleAvatar(
                backgroundColor: const Color.fromRGBO(24, 24, 24, 0.2),
                radius: 20,
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
