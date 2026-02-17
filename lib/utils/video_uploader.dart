part of '../utils.dart';

Future<String?> uploadVideo({required String path}) async {
  File file = File(path);
  final String filename = path.split('/').last;

  Uint8List videoData = await file.readAsBytes();

  final url = Uri.parse('${AppCredentials.domain}/api/video/upload');
  final request = http.MultipartRequest('POST', url);

  request.files.add(
    http.MultipartFile.fromBytes(
      'video',
      videoData,
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

  if (response.statusCode == 200) {
    var responseBody = await response.stream.transform(utf8.decoder).join();
    final video_id = responseBody.replaceAll('"', '');

    printLine(video_id);

    final thumbnail = await VideoCompress.getFileThumbnail(path, quality: 80);

    PreparedImage prepared_image = PreparedImage.fromFileWithId(
      thumbnail,
      video_id,
    );
    
    final image_meta = await prepared_image.get_prepare_meta();
    prepared_image.meta = image_meta;

    final images = await uploadImages(
      images: [prepared_image],
      used_at: AssetUsedAt.VideoThumbnail,
      temporary: false,
    );

    if (images == null) {
      throw Exception('Failed to upload video thumbnail');
    }

    return video_id;
  } else {
    return null;
  }
}
