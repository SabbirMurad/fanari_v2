part of '../utils.dart';

enum AssetUsedAt { ProfilePic, CoverPic, Post, Comment, Chat, VideoThumbnail }

Future<List<String>?> uploadImages({
  required List<PreparedImage> images,
  required AssetUsedAt used_at,
  bool temporary = true,
}) async {
  var uri = Uri.parse('${AppCredentials.domain}/image');
  var request = http.MultipartRequest('POST', uri);


  for (int i = 0; i < images.length; i++) {
    final p = images[i];

    final meta = p.meta!;

    request.files.add(
      http.MultipartFile.fromBytes(
        'image_$i',
        meta.compressed_bytes,
        filename: 'image_$i.jpg',
      ),
    );

    request.fields['width_$i'] = '${meta.width}';
    request.fields['height_$i'] = '${meta.height}';
    request.fields['blur_hash_$i'] = meta.blur_hash;
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
