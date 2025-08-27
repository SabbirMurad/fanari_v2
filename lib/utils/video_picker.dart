part of '../utils.dart';

Future<List<File>?> pickVideoFromGallery({
  required BuildContext context,
  int? limit,
}) async {
  final List<AssetEntity>? result = await AssetPicker.pickAssets(
    context,
    pickerConfig: AssetPickerConfig(
      themeColor: Theme.of(context).colorScheme.primary,
      requestType: RequestType.video,
      maxAssets: limit ?? 1,
    ),
  );

  if (result == null) return null;

  List<File> files = [];
  for (final element in result) {
    final file = await element.file;
    if (file == null) continue;
    files.add(file);
  }

  return files;
}
