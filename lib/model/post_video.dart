import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fanari_v2/constants/credential.dart';

class PostVideoModel {
  final String uuid;
  final String videoUrl;
  final String thumbnailUrl;
  final String thumbnailType;
  final double width;
  final double height;
  final ImageProvider thumbnailImageProvider;

  const PostVideoModel({
    required this.uuid,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.width,
    required this.height,
    required this.thumbnailType,
    required this.thumbnailImageProvider,
  });

  factory PostVideoModel.fromJson(json) {
    final String videoId = json['uuid'];
    final thumbnailUrl = '${AppCredentials.domain}/image/$videoId';

    return PostVideoModel(
      uuid: videoId,
      videoUrl: '${AppCredentials.domain}/upload/video/$videoId/index.m3u8',
      thumbnailUrl: thumbnailUrl,
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      thumbnailType: json['thumbnail_type'],
      thumbnailImageProvider: CachedNetworkImageProvider(thumbnailUrl),
    );
  }
}
