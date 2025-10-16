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
  // bool crop = true,
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

  // Uint8List? image;
  // if (crop) {
  //   final Uint8List? croppedImage = await cropImage(filePath);

  //   if (croppedImage == null) {
  //     return null;
  //   }
  //   image = croppedImage;
  // } else {
  //   image = await File(filePath).readAsBytes();
  // }
  final image = await File(filePath).readAsBytes();
  if (compress) {
    final Uint8List compressedImage = await compressImage(image, 400);
    return compressedImage;
  }

  return image;
}

Future<List<File>?> pickImageFromGallery({
  required BuildContext context,
  int? limit,
  bool compress = true,
}) async {
  List<File> images = [];

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

    images.add(file);
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
  final String cameraIcon =
      '<?xml version="1.0" ?><!DOCTYPE svg><svg enable-background="new 0 0 48 48" height="48px" id="Layer_1" version="1.1" viewBox="0 0 48 48" width="48px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><path clip-rule="evenodd" d="M43,41H5c-2.209,0-4-1.791-4-4V15c0-2.209,1.791-4,4-4h1l0,0c0-1.104,0.896-2,2-2  h2c1.104,0,2,0.896,2,2h2c0,0,1.125-0.125,2-1l2-2c0,0,0.781-1,2-1h8c1.312,0,2,1,2,1l2,2c0.875,0.875,2,1,2,1h9  c2.209,0,4,1.791,4,4v22C47,39.209,45.209,41,43,41z M45,15c0-1.104-0.896-2-2-2l-9.221-0.013c-0.305-0.033-1.889-0.269-3.193-1.573  l-2.13-2.13l-0.104-0.151C28.351,9.132,28.196,9,28,9h-8c-0.153,0-0.375,0.178-0.424,0.231l-0.075,0.096l-2.087,2.086  c-1.305,1.305-2.889,1.54-3.193,1.573l-4.151,0.006C10.046,12.994,10.023,13,10,13H8c-0.014,0-0.026-0.004-0.04-0.004L5,13  c-1.104,0-2,0.896-2,2v22c0,1.104,0.896,2,2,2h38c1.104,0,2-0.896,2-2V15z M24,37c-6.075,0-11-4.925-11-11s4.925-11,11-11  s11,4.925,11,11S30.075,37,24,37z M24,17c-4.971,0-9,4.029-9,9s4.029,9,9,9s9-4.029,9-9S28.971,17,24,17z M24,31  c-2.762,0-5-2.238-5-5s2.238-5,5-5s5,2.238,5,5S26.762,31,24,31z M24,23c-1.656,0-3,1.344-3,3c0,1.657,1.344,3,3,3  c1.657,0,3-1.343,3-3C27,24.344,25.657,23,24,23z M10,19H6c-0.553,0-1-0.447-1-1v-2c0-0.552,0.447-1,1-1h4c0.553,0,1,0.448,1,1v2  C11,18.553,10.553,19,10,19z" fill-rule="evenodd"/></svg>';

  final String galleryIcon =
      '<?xml version="1.0" ?><!DOCTYPE svg ><svg enable-background="new 0 0 48 48" height="48px" id="Layer_1" version="1.1" viewBox="0 0 48 48" width="48px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><path clip-rule="evenodd" d="M43,41H5c-2.209,0-4-1.791-4-4V11c0-2.209,1.791-4,4-4h38c2.209,0,4,1.791,4,4v26  C47,39.209,45.209,41,43,41z M45,11c0-1.104-0.896-2-2-2H5c-1.104,0-2,0.896-2,2v26c0,1.104,0.896,2,2,2h38c1.104,0,2-0.896,2-2V11z   M41.334,34.715L35,28.381L31.381,32l3.334,3.334c0.381,0.381,0.381,0.999,0,1.381c-0.382,0.381-1,0.381-1.381,0L19,22.381  L6.666,34.715c-0.381,0.381-0.999,0.381-1.381,0c-0.381-0.382-0.381-1,0-1.381L18.19,20.429c0.032-0.048,0.053-0.101,0.095-0.144  c0.197-0.197,0.457-0.287,0.715-0.281c0.258-0.006,0.518,0.084,0.715,0.281c0.042,0.043,0.062,0.096,0.095,0.144L30,30.619  l4.19-4.19c0.033-0.047,0.053-0.101,0.095-0.144c0.197-0.196,0.457-0.287,0.715-0.281c0.258-0.006,0.518,0.085,0.715,0.281  c0.042,0.043,0.062,0.097,0.095,0.144l6.905,6.905c0.381,0.381,0.381,0.999,0,1.381C42.333,35.096,41.715,35.096,41.334,34.715z   M29,19c-2.209,0-4-1.791-4-4s1.791-4,4-4s4,1.791,4,4S31.209,19,29,19z M29,13c-1.104,0-2,0.896-2,2s0.896,2,2,2s2-0.896,2-2  S30.104,13,29,13z" fill-rule="evenodd"/></svg>';

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        color: AppColors.secondary,
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
                  child: SvgPicture.string(
                    cameraIcon,
                    color: AppColors.text,
                    width: 72.w,
                    fit: BoxFit.fitWidth,
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
                  child: SvgPicture.string(
                    galleryIcon,
                    color: AppColors.text,
                    width: 72.w,
                    fit: BoxFit.fitWidth,
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
