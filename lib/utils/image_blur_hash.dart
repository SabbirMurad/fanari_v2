part of '../utils.dart';

Future<String> generateBlurHash(ImageProvider imageProvider) async {
  return await Isolate.run(() async {
    // Encode to blurhash (more components = more detail, but larger string)
    return await BlurhashFFI.encode(
      imageProvider,
      componentX: 4,
      componentY: 3,
    );
  });
}
