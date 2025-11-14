import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fanari_v2/constants/credential.dart';

class ImageModel {
  final String uuid;
  final String webp_url;
  final String original_url;
  final double width;
  final double height;
  final ImageProvider provider;

  const ImageModel({
    required this.uuid,
    required this.webp_url,
    required this.original_url,
    required this.width,
    required this.height,
    required this.provider,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      uuid: json['uuid'],
      webp_url: '${AppCredentials.domain}/image/webp/${json['uuid']}',
      original_url: '${AppCredentials.domain}/image/original/${json['uuid']}',
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      provider: CachedNetworkImageProvider(
        '${AppCredentials.domain}/image/webp/${json['uuid']}',
      ),
    );
  }
}
