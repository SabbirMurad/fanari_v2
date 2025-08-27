part of '../utils.dart';

class ImageInfo {
  final String name;
  final String type;
  final Uint8List data;

  const ImageInfo(this.name, this.type, this.data);

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(json['name'], json['type'], json['data']);
  }
}

Future<Uint8List> compressImage(
  Uint8List uint8List,
  int targetFileSizeKB,
) async {
  int minQuality = 0;
  int currentQuality = 90; // Starting quality

  Uint8List compressedData = uint8List;
  int currentFileSizeKB = compressedData.lengthInBytes ~/ 1024;

  while (currentFileSizeKB > targetFileSizeKB && currentQuality > minQuality) {
    currentQuality -= 5; // Adjust the step size as needed

    List<int> compressedDataList = await FlutterImageCompress.compressWithList(
      uint8List,
      quality: currentQuality,
    );

    compressedData = Uint8List.fromList(compressedDataList);
    currentFileSizeKB = compressedData.lengthInBytes ~/ 1024;
  }

  return compressedData;
}

Future<Uint8List?> pickSingleImage({
  required BuildContext context,
  required ImageSource source,
  bool compress = true,
  bool crop = true,
}) async {
  String filePath = '';

  if (source == ImageSource.camera) {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);

    if (file == null) {
      return null;
    }

    filePath = file.path;
  } else {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        themeColor: Theme.of(context).colorScheme.primary,
        requestType: RequestType.image,
        maxAssets: 1,
      ),
    );

    if (result == null || result.isEmpty) return null;

    final asset = result.first;
    final file = await asset.file;

    if (file == null) return null;

    filePath = file.path;
  }

  Uint8List? image;
  if (crop) {
    final Uint8List? croppedImage = await cropImage(filePath);

    if (croppedImage == null) {
      return null;
    }
    image = croppedImage;
  } else {
    image = await File(filePath).readAsBytes();
  }

  if (compress) {
    final Uint8List compressedImage = await compressImage(image, 400);
    return compressedImage;
  }

  return image;
}

Future<List<Uint8List>?> pickImageFromGallery({
  required BuildContext context,
  int? limit,
  bool compress = true,
}) async {
  List<Uint8List> images = [];

  final List<AssetEntity>? result = await AssetPicker.pickAssets(
    context,
    pickerConfig: AssetPickerConfig(
      themeColor: Theme.of(context).colorScheme.primary,
      requestType: RequestType.image,
      maxAssets: limit ?? 9,
    ),
  );

  if (result == null) return null;

  for (final asset in result) {
    final file = await asset.file;
    if (file == null) continue;

    final Uint8List actualImage = await file.readAsBytes();
    if (compress) {
      final Uint8List compressedImage = await compressImage(
        await actualImage,
        400,
      );
      images.add(compressedImage);
    } else {
      images.add(actualImage);
    }
  }
  return images;
}

Future<Uint8List?> cropImage(String path) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: path,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: '',
        toolbarColor: const Color.fromRGBO(24, 24, 24, 1),
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: const Color.fromRGBO(154, 121, 245, 1),
        backgroundColor: const Color.fromRGBO(24, 24, 24, 1),
        lockAspectRatio: false,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
        ],
      ),
    ],
  );

  if (croppedFile != null) {
    return await croppedFile.readAsBytes();
  } else {
    return null;
  }
}

void showImagePickerOptions(
  BuildContext context,
  void Function(ImageSource) selectImage,
) async {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        width: 1.sw,
        height: 0.2.sh,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                selectImage(ImageSource.camera);
              },
              child: SizedBox(
                width: 72.w,
                height: 72.w,
                child: Center(
                  child: CustomSvg(
                    'assets/icons/camera.svg',
                    width: 72.w,
                    fit: BoxFit.fitWidth,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                selectImage(ImageSource.gallery);
              },
              child: SizedBox(
                width: 72.w,
                height: 72.w,
                child: Center(
                  child: CustomSvg(
                    'assets/icons/basic/gallery.svg',
                    width: 72.w,
                    fit: BoxFit.fitWidth,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
