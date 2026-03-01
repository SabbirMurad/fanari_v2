part of '../utils.dart';

/// Opens the asset picker restricted to audio files.
/// Returns up to [limit] (default 1) files, or null if the user cancelled.
Future<List<File>?> pick_audio_from_gallery({
  required BuildContext context,
  int? limit,
}) async {
  final results = await AssetPicker.pickAssets(
    context,
    pickerConfig: AssetPickerConfig(
      themeColor: Theme.of(context).colorScheme.primary,
      requestType: RequestType.audio,
      maxAssets: limit ?? 1,
    ),
  );

  if (results == null) return null;

  final files = <File>[];
  for (final asset in results) {
    final file = await asset.file;
    if (file != null) files.add(file);
  }
  return files;
}
