part of '../utils.dart';

enum AssetUsedAt { ProfilePic, CoverPic, Post, Comment, Chat, VideoThumbnail }

class _PreparedImage {
  final Uint8List bytes;
  final int width;
  final int height;
  final String blurHash;
  _PreparedImage(this.bytes, this.width, this.height, this.blurHash);
}

Future<List<String>?> uploadImages({
  required List<File> images,
  required AssetUsedAt used_at,
  bool temporary = true,
}) async {
  var uri = Uri.parse('${AppCredentials.domain}/image');
  var request = http.MultipartRequest('POST', uri);

  final prepared = <_PreparedImage>[];

  print("images length: ${images.length}");

  List<String> _filePaths = [];

  for (final image in images) {
    _filePaths.add(image.path);
  }

  for (int i = 0; i < _filePaths.length; i++) {
    final bytes = await File(_filePaths[i]).readAsBytes();
    final decoded = img.decodeImage(bytes)!;

    final blurHash = await BlurhashFFI.encode(
      MemoryImage(bytes),
      componentX: 4,
      componentY: 3,
    );
    print('blurHash: $blurHash');
    prepared.add(
      _PreparedImage(bytes, decoded.width, decoded.height, blurHash),
    );
  }

  for (int i = 0; i < prepared.length; i++) {
    final p = prepared[i];

    request.files.add(
      http.MultipartFile.fromBytes(
        'image_$i',
        p.bytes,
        filename: 'image_$i.jpg',
      ),
    );

    request.fields['width_$i'] = '${p.width}';
    request.fields['height_$i'] = '${p.height}';
    request.fields['blur_hash_$i'] = p.blurHash;
    request.fields['used_at_$i'] = used_at.toString();
    request.fields['temporary_$i'] = temporary.toString();
  }

  var response = await request.send();

  if (response.statusCode == 200) {
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);
    List<String> imageIds = [];

    for (int i = 0; i < json.length; i++) {
      imageIds.add(json[i]);
    }
    return imageIds;
  } else {
    print('Upload failed: ${response.statusCode}');
    print('Upload failed: ${await response.stream.bytesToString()}');
    return null;
  }
}
