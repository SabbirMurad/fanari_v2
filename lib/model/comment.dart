import 'package:fanari_v2/constants/credential.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/user.dart';
import 'package:fanari_v2/model/youtube.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';

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
      images: (json['images'] as List).map((i) => ImageModel.fromJson(i)).toList(),
      mentions: (json['mentions'] as List).map((m) => MentionModel.fromJson(m)).toList(),
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

  Future<void> load_third_party_infos() async {
    if (caption == null) return;
    if (images.isNotEmpty || audio != null) return;

    if (youtube_attachment == null) {
      final id = YoutubeModel.searchId(caption!);
      if (id != null) {
        youtube_attachment = await YoutubeModel.load(id);
      }
    }

    if (link_preview == null && youtube_attachment == null) {
      for (final word in caption!.split(' ')) {
        if (word.startsWith('https://') ||
            word.startsWith('http://') ||
            word.startsWith('www.') ||
            word.endsWith('.com')) {
          final preview = await getPreviewData(word);
          if (preview.title != null) {
            link_preview = preview;
            return;
          }
        }
      }
    }
  }
}
