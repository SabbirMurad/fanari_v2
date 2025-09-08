import 'dart:convert';
import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/nhentai.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/user.dart';
import 'package:fanari_v2/model/youtube.dart';
import 'package:fanari_v2/constants/credential.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

class CommentModel {
  String uuid;
  String? caption;
  List<MentionModel> mentions;
  List<ImageModel> images;
  String? audio;
  int created_at;

  UserModel owner;

  bool liked;
  int like_count;
  int reply_count;

  YoutubeModel? youtube_attachment;
  PreviewData? link_preview;

  CommentModel({
    required this.uuid,
    this.caption,
    required this.mentions,
    required this.images,
    this.audio,
    required this.created_at,
    required this.owner,
    required this.liked,
    required this.like_count,
    required this.reply_count,
    this.youtube_attachment,
    this.link_preview,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      uuid: json['uuid'],
      caption: json['caption'],
      images: json['images'].map((item) => ImageModel.fromJson(item)).toList(),
      mentions: json['mentions']
          .map((item) => MentionModel.fromJson(item))
          .toList(),
      audio: json['audio'] != null
          ? '${AppCredentials.domain}/upload/audio/${json['audio']}'
          : null,
      created_at: json['created_at'],
      owner: UserModel.fromJson(json['owner']),
      liked: json['liked'],
      like_count: json['like_count'],
      reply_count: json['reply_count'],
    );
  }

  static List<CommentModel> fromJsonList(List<dynamic> json) {
    return json.map((item) => CommentModel.fromJson(item)).toList();
  }

  load3rdPartyInfos() async {
    // Must have a caption to work with
    if (caption == null) return;

    // If contains these datas then not showing the 3rd party infos
    if (this.images.isNotEmpty || this.audio != null) return;

    if (this.youtube_attachment == null) {
      final id = YoutubeModel.searchId(this.caption!);

      if (id != null) {
        this.youtube_attachment = await YoutubeModel.load(id);
      }
    }

    if (this.link_preview == null && this.youtube_attachment == null) {
      final arr = this.caption!.split(' ');
      for (var i = 0; i < arr.length; i++) {
        if (arr[i].startsWith('https://') ||
            arr[i].startsWith('http://') ||
            arr[i].startsWith('www.') ||
            arr[i].endsWith('.com')) {
          this.link_preview = await getPreviewData(arr[i]);
          return;
        }
      }
    }
  }
}
