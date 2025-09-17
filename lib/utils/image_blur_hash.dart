part of '../utils.dart';

Future<String> generateBlurHash(Uint8List bytes) async {
  // Decode image using package:image
  final decodedImage = img.decodeImage(bytes)!;

  // Encode to blurhash (more components = more detail, but larger string)
  final blurHash = BlurHash.encode(decodedImage, numCompX: 4, numCompY: 3);

  return blurHash.hash; // Store this string in your DB
}