part of '../utils.dart';

enum AssetUsedAt { ProfilePic, CoverPic, Post, Comment, Chat, VideoThumbnail }

/// Uploads [images] to the server and returns their assigned IDs.
///
/// Throws if any image in the list is still being prepared.
Future<List<String>?> upload_images({
  required List<PreparedImage> images,
  required AssetUsedAt used_at,
  bool temporary = true,
}) async {
  for (final image in images) {
    if (image.preparing) throw StateError('Image is still being prepared.');
  }

  final uri = Uri.parse('${AppCredentials.domain}/image');
  final request = http.MultipartRequest('POST', uri);

  for (int i = 0; i < images.length; i++) {
    final prepared = images[i];
    final meta = prepared.meta!;

    request.files.add(
      http.MultipartFile.fromBytes(
        'image_$i',
        meta.compressed_bytes,
        filename: 'image_$i.jpg',
      ),
    );

    if (prepared.uuid != null) request.fields['uuid_$i'] = prepared.uuid!;

    request.fields['width_$i'] = '${meta.width}';
    request.fields['height_$i'] = '${meta.height}';
    request.fields['blur_hash_$i'] = meta.blur_hash;
    request.fields['used_at_$i'] = used_at.toString();
    request.fields['temporary_$i'] = temporary.toString();
  }

  printLine('Uploading ${images.length} image(s): ${request.fields}');

  final response = await request.send();

  if (response.statusCode != 200) {
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body) as List<dynamic>;
    return json.cast<String>();
  }

  printLine(
    'Image upload failed (${response.statusCode}): '
    '${await response.stream.bytesToString()}',
  );
  return null;
}
