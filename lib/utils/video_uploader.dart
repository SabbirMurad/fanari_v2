part of '../utils.dart';

/// Uploads the video at [path], generates a thumbnail, uploads it, then
/// returns the video's server-assigned ID.
///
/// Returns null on failure.
Future<String?> upload_video({required String path}) async {
  final file = File(path);
  final filename = path.split('/').last;
  final video_bytes = await file.readAsBytes();

  final url = Uri.parse('${AppCredentials.domain}/api/video/upload');
  final request = http.MultipartRequest('POST', url);

  request.files.add(
    http.MultipartFile.fromBytes(
      'video',
      video_bytes,
      filename: filename,
      contentType: MediaType('video', path.split('.').last),
    ),
  );

  final access_token = await LocalStorage.access_token.get();
  request.headers.addAll({
    'Authorization': 'Bearer $access_token',
    'Content-Type': 'multipart/form-data',
  });

  final response = await request.send();

  if (response.statusCode != 200) return null;

  final response_body = await response.stream.transform(utf8.decoder).join();
  final video_id = response_body.replaceAll('"', '');

  printLine('Uploaded video ID: $video_id');

  final thumbnail = await VideoCompress.getFileThumbnail(path, quality: 80);
  final prepared = PreparedImage.fromFileWithId(thumbnail, video_id);
  prepared.meta = await prepared.get_prepare_meta();

  final image_ids = await upload_images(
    images: [prepared],
    used_at: AssetUsedAt.VideoThumbnail,
    temporary: false,
  );

  if (image_ids == null) {
    throw Exception('Failed to upload video thumbnail for video $video_id');
  }

  return video_id;
}
