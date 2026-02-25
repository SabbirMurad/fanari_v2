import 'dart:io';
import 'dart:typed_data';
import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class PreparedImage {
  String? uuid;
  final File file;
  bool preparing;
  PreparedImageMeta? meta;

  PreparedImage({
    required this.file,
    this.preparing = true,
    this.meta,
    this.uuid,
  });

  Future<PreparedImageMeta> get_prepare_meta() async {
    final bytes = file.readAsBytesSync();

    final Uint8List compressed_bytes = await utils.compressImage(bytes, 400);

    final dir = await getTemporaryDirectory();
    final newPath =
        '${dir.path}/${DateTime.now().microsecondsSinceEpoch}.${file.path.split('.').last}';

    final compressed_file = await File(newPath).create();

    await compressed_file.writeAsBytes(compressed_bytes);

    final decoded = img.decodeImage(compressed_bytes)!;

    final blur_hash = await BlurhashFFI.encode(
      MemoryImage(compressed_bytes),
      componentX: 6,
      componentY: 5,
    );

    return PreparedImageMeta(
      width: decoded.width,
      height: decoded.height,
      blur_hash: blur_hash,
      bytes: bytes,
      compressed_bytes: compressed_bytes,
    );
  }

  static PreparedImage fromFile(File file) {
    return PreparedImage(file: file);
  }

  static PreparedImage fromFileWithId(File file, String uuid) {
    return PreparedImage(file: file, uuid: uuid);
  }

  static List<PreparedImage> fromFiles(List<File> files) {
    return files.map((file) => PreparedImage(file: file)).toList();
  }
}

class PreparedImageMeta {
  final int width;
  final int height;
  final String blur_hash;
  final Uint8List bytes;
  final Uint8List compressed_bytes;

  PreparedImageMeta({
    required this.width,
    required this.height,
    required this.blur_hash,
    required this.bytes,
    required this.compressed_bytes,
  });
}
