import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/nhentai.dart';
import 'package:fanari_v2/model/poll.dart';
import 'package:fanari_v2/model/video.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/user.dart';
import 'package:fanari_v2/model/youtube.dart';
import 'package:fanari_v2/constants/credential.dart';
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

class _PostCore {
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

  _PostCore({
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

  factory _PostCore.fromJson(Map<String, dynamic> core) {
    List<ImageModel> images = [];
    for (var i = 0; i < core['images'].length; i++) {
      images.add(ImageModel.fromJson(core['images'][i]));
    }

    List<VideoModel> videos = [];
    for (var i = 0; i < core['videos'].length; i++) {
      videos.add(VideoModel.fromJson(core['videos'][i]));
    }

    List<MentionModel> mentions = [];
    for (var i = 0; i < core['mentions'].length; i++) {
      mentions.add(MentionModel.fromJson(core['mentions'][i]));
    }

    return _PostCore(
      uuid: core['uuid'],
      owner_id: core['owner_id'],
      caption: core['caption'],

      audio: core['audio'] != null
          ? '${AppCredentials.domain}/upload/audio/${core['audio']}'
          : null,
      poll: core['poll'] != null ? PollModel.fromJson(core['poll']) : null,
      created_at: core['created_at'],
      images: images,
      videos: videos,
      mentions: mentions,
      // nhentai_book: json['nhentai_book'] != null
      //     ? NhentaiBookModel.fromJson(jsonDecode(json['nhentai_book']))
      //     : null,
    );
  }

  Future<_PostCore?> load3rdPartyInfos() async {
    if (this.youtube_attachment == null &&
        this.images.isEmpty &&
        this.videos.isEmpty &&
        audio == null &&
        this.caption != null) {
      final id = YoutubeModel.searchId(this.caption!);
      if (id != null) {
        this.youtube_attachment = await YoutubeModel.load(id);
        return this;
      }
    }

    if (this.link_preview == null &&
        this.images.isEmpty &&
        this.videos.isEmpty &&
        this.audio == null &&
        this.youtube_attachment == null &&
        this.caption != null) {
      final arr = this.caption!.split(' ');
      for (var i = 0; i < arr.length; i++) {
        if (arr[i].startsWith('https://') ||
            arr[i].startsWith('http://') ||
            arr[i].startsWith('www.') ||
            arr[i].endsWith('.com')) {
          final preview = await getPreviewData(arr[i]);
          if (preview.title != null) {
            this.link_preview = preview;
            return this;
          }
        }
      }
    }

    return null;
  }
}

class _PostStat {
  int like_count;
  int comment_count;
  int share_count;
  int view_count;

  _PostStat({
    required this.like_count,
    required this.comment_count,
    required this.share_count,
    required this.view_count,
  });

  factory _PostStat.fromJson(Map<String, dynamic> stat) {
    return _PostStat(
      like_count: stat['like_count'],
      comment_count: stat['comment_count'],
      share_count: stat['share_count'],
      view_count: stat['view_count'],
    );
  }
}

class _PostMeta {
  bool liked;
  bool bookmarked;

  _PostMeta({required this.liked, required this.bookmarked});

  factory _PostMeta.fromJson(Map<String, dynamic> meta) {
    return _PostMeta(liked: meta['liked'], bookmarked: meta['bookmarked']);
  }
}

class PostModel {
  _PostCore core;
  _PostStat stat;
  _PostMeta meta;

  UserModel? owner;

  PostModel({
    required this.core,
    required this.stat,
    required this.meta,
    this.owner,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    try {
      _PostCore.fromJson(json['core']);
    } catch (e) {
      printLine(e);
      printLine(json['core']);
    }

    final post = PostModel(
      core: _PostCore.fromJson(json['core']),
      stat: _PostStat.fromJson(json['stat']),
      meta: _PostMeta.fromJson(json['meta']),
    );

    return post;
  }

  static List<PostModel> fromJsonList(List<dynamic> json) {
    return json.map((item) => PostModel.fromJson(item)).toList();
  }
}
