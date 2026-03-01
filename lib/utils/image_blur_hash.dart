part of '../utils.dart';

/// Generates a BlurHash string for [image_provider] in a background isolate.
Future<String> generate_blur_hash(ImageProvider image_provider) {
  return Isolate.run(() async {
    return BlurhashFFI.encode(
      image_provider,
      componentX: 4,
      componentY: 3,
    );
  });
}
