import 'package:fanari_v2/constants/credential.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/nhentai.dart';
import 'package:fanari_v2/model/poll.dart';
import 'package:fanari_v2/model/user.dart';
import 'package:fanari_v2/model/video.dart';
import 'package:fanari_v2/model/youtube.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';

// ── Sub-models (public — accessed from providers and views) ───────────────────

class PostCore {
  String uuid;
  String? caption;
  List<MentionModel> mentions;
  List<ImageModel> images;
  List<VideoModel> videos;
  PollModel? poll;
  String? audio;
  int created_at;
  String owner_id;

  NhentaiBookModel? nhentai_book;
  YoutubeModel? youtube_attachment;
  PreviewData? link_preview;

  PostCore({
    required this.uuid,
    this.caption,
    required this.mentions,
    required this.images,
    required this.videos,
    this.audio,
    this.poll,
    required this.created_at,
    required this.owner_id,
    this.nhentai_book,
    this.youtube_attachment,
    this.link_preview,
  });

  factory PostCore.fromJson(Map<String, dynamic> json) {
    return PostCore(
      uuid: json['uuid'],
      owner_id: json['owner_id'],
      caption: json['caption'],
      audio: json['audio'] != null
          ? '${AppCredentials.domain}/upload/audio/${json['audio']}'
          : null,
      poll: json['poll'] != null ? PollModel.fromJson(json['poll']) : null,
      created_at: json['created_at'],
      images: (json['images'] as List).map((i) => ImageModel.fromJson(i)).toList(),
      videos: (json['videos'] as List).map((v) => VideoModel.fromJson(v)).toList(),
      mentions: (json['mentions'] as List).map((m) => MentionModel.fromJson(m)).toList(),
    );
  }

  Future<PostCore?> load_third_party_infos() async {
    if (youtube_attachment == null &&
        images.isEmpty &&
        videos.isEmpty &&
        audio == null &&
        caption != null) {
      final id = YoutubeModel.searchId(caption!);
      if (id != null) {
        youtube_attachment = await YoutubeModel.load(id);
        return this;
      }
    }

    if (link_preview == null &&
        images.isEmpty &&
        videos.isEmpty &&
        audio == null &&
        youtube_attachment == null &&
        caption != null) {
      for (final word in caption!.split(' ')) {
        if (word.startsWith('https://') ||
            word.startsWith('http://') ||
            word.startsWith('www.') ||
            word.endsWith('.com')) {
          final preview = await getPreviewData(word);
          if (preview.title != null) {
            link_preview = preview;
            return this;
          }
        }
      }
    }

    return null;
  }
}

class PostStat {
  int like_count;
  int comment_count;
  int share_count;
  int view_count;

  PostStat({
    required this.like_count,
    required this.comment_count,
    required this.share_count,
    required this.view_count,
  });

  factory PostStat.fromJson(Map<String, dynamic> json) {
    return PostStat(
      like_count: json['like_count'],
      comment_count: json['comment_count'],
      share_count: json['share_count'],
      view_count: json['view_count'],
    );
  }
}

class PostMeta {
  bool liked;
  bool bookmarked;

  PostMeta({required this.liked, required this.bookmarked});

  factory PostMeta.fromJson(Map<String, dynamic> json) {
    return PostMeta(liked: json['liked'], bookmarked: json['bookmarked']);
  }
}

// ── Public model ──────────────────────────────────────────────────────────────

class PostModel {
  PostCore core;
  PostStat stat;
  PostMeta meta;
  UserModel? owner;

  PostModel({
    required this.core,
    required this.stat,
    required this.meta,
    this.owner,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      core: PostCore.fromJson(json['core']),
      stat: PostStat.fromJson(json['stat']),
      meta: PostMeta.fromJson(json['meta']),
    );
  }

  static List<PostModel> fromJsonList(List<dynamic> json) {
    return json.map((item) => PostModel.fromJson(item)).toList();
  }
}
