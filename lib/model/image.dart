import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fanari_v2/constants/credential.dart';

class ImageModel {
  final String uuid;
  final String webp_url;
  final String original_url;
  final String blur_hash;
  final double width;
  final double height;
  final ImageProvider provider;
  final bool local;
  final Uint8List? local_bytes;

  const ImageModel({
    required this.uuid,
    required this.webp_url,
    required this.original_url,
    required this.blur_hash,
    required this.width,
    required this.height,
    required this.provider,
    this.local = false,
    this.local_bytes,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      uuid: json['uuid'],
      blur_hash: json['blur_hash'],
      webp_url: '${AppCredentials.domain}/image/webp/${json['uuid']}',
      original_url: '${AppCredentials.domain}/image/original/${json['uuid']}',
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      provider: CachedNetworkImageProvider(
        '${AppCredentials.domain}/image/webp/${json['uuid']}',
      ),
    );
  }

  static List<ImageModel> fromJsonList(List<dynamic> json) {
    List<ImageModel> images = [];

    for (var i = 0; i < json.length; i++) {
      images.add(ImageModel.fromJson(json[i]));
    }

    return images;
  }
}
