import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/constants/credential.dart';

class VideoModel {
  final String uuid;
  final String videoUrl;
  final ImageModel thumbnail;

  const VideoModel({
    required this.uuid,
    required this.videoUrl,
    required this.thumbnail,
  });

  factory VideoModel.fromJson(json) {
    // TODO: need actual impliment later

    final String videoId = json['uuid'];

    return VideoModel(
      uuid: videoId,
      videoUrl:
          '${AppCredentials.domain}/api/video/segment/$videoId/index.m3u8',
      thumbnail: ImageModel.fromJson(json),
    );
  }
}
