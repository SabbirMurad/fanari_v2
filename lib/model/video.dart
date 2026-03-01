import 'package:fanari_v2/constants/credential.dart';
import 'package:fanari_v2/model/image.dart';

class VideoModel {
  final String uuid;
  final String video_url;
  final ImageModel thumbnail;

  const VideoModel({
    required this.uuid,
    required this.video_url,
    required this.thumbnail,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final String video_id = json['uuid'];

    return VideoModel(
      uuid: video_id,
      video_url: '${AppCredentials.domain}/api/video/segment/$video_id/index.m3u8',
      thumbnail: ImageModel.fromJson(json),
    );
  }
}
