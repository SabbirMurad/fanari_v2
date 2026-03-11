import 'dart:typed_data';

import 'package:fanari_v2/constants/credential.dart';
import 'package:fanari_v2/model/image.dart';

class VideoModel {
  final String uuid;
  final String video_url;
  final ImageModel thumbnail;
  final bool local;
  final Uint8List? local_thumbnail_bytes;

  const VideoModel({
    required this.uuid,
    required this.video_url,
    required this.thumbnail,
    this.local = false,
    this.local_thumbnail_bytes,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final String video_id = json['uuid'];

    return VideoModel(
      uuid: video_id,
      video_url:
          '${AppCredentials.domain}/api/video/segment/$video_id/index.m3u8',
      thumbnail: ImageModel.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': this.uuid,
      'blur_hash': this.thumbnail.blur_hash,
      'width': this.thumbnail.width,
      'height': this.thumbnail.height,
    };
  }
}
