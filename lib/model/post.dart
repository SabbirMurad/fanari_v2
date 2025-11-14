import 'dart:convert';
import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/nhentai.dart';
import 'package:fanari_v2/model/poll.dart';
import 'package:fanari_v2/model/video.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/user.dart';
import 'package:fanari_v2/model/youtube.dart';
import 'package:fanari_v2/constants/credential.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

class PostModel {
  String uuid;
  String? caption;
  List<MentionModel> mentions;
  List<ImageModel> images;
  List<VideoModel> videos;
  String? audio;
  int created_at;
  bool bookmarked;

  UserModel owner;

  bool liked;
  int like_count;
  int comment_count;

  PollModel? poll;

  NhentaiBookModel? nhentai_book;
  YoutubeModel? youtube_attachment;
  PreviewData? link_preview;

  PostModel({
    required this.uuid,
    required this.bookmarked,
    this.caption,
    required this.mentions,
    required this.images,
    required this.videos,
    this.audio,
    this.poll,
    required this.created_at,
    required this.owner,
    required this.liked,
    required this.like_count,
    required this.comment_count,
    this.nhentai_book,
    this.youtube_attachment,
    this.link_preview,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final core = json['core'];
    final stat = json['stat'];

    return PostModel(
      uuid: core['uuid'],
      caption: core['caption'],
      images: core['images'].map((item) => ImageModel.fromJson(item)),
      videos: core['videos'].map((item) => ImageModel.fromJson(item)),
      bookmarked: json['bookmarked'],
      mentions: core['mentions'].map((item) => MentionModel.fromJson(item)),
      audio: core['audio'] != null
          ? '${AppCredentials.domain}/upload/audio/${core['audio']}'
          : null,
      poll: core['poll'] != null ? PollModel.fromJson(core['poll']) : null,
      created_at: core['created_at'],
      owner: UserModel.fromJson(json['owner']),
      liked: json['liked'],
      like_count: stat['like_count'],
      comment_count: stat['comment_count'],
      nhentai_book: json['nhentai_book'] != null
          ? NhentaiBookModel.fromJson(jsonDecode(json['nhentai_book']))
          : null,
    );
  }

  static List<PostModel> fromJsonList(List<dynamic> json) {
    return json.map((item) => PostModel.fromJson(item)).toList();
  }

  Future<void> load3rdPartyInfos() async {
    // Must have a caption to work with
    if (this.caption == null) return;

    // If contains these datas then not showing the 3rd party infos
    if (this.images.isNotEmpty || this.videos.isNotEmpty || this.audio != null)
      return;

    if (this.youtube_attachment == null) {
      final id = YoutubeModel.searchId(this.caption!);

      if (id != null) {
        this.youtube_attachment = await YoutubeModel.load(id);
      }
    }

    if (this.link_preview == null &&
        this.nhentai_book == null &&
        this.youtube_attachment == null) {
      final arr = this.caption!.split(' ');
      for (var i = 0; i < arr.length; i++) {
        if (arr[i].startsWith('https://') ||
            arr[i].startsWith('http://') ||
            arr[i].startsWith('www.') ||
            arr[i].endsWith('.com')) {
          final preview = await getPreviewData(arr[i]);
          if (preview.title != null) {
            this.link_preview = preview;
            return;
          }
        }
      }
    }
  }
}
