// import 'dart:convert';
// import 'package:fanari_v2/model/nhentai.dart';
// import 'package:fanari_v2/model/owner.dart';
// import 'package:fanari_v2/model/post_video.dart';
// import 'package:fanari_v2/model/server_image.dart';
// import 'package:fanari_v2/model/youtube_attachment.dart';
// import 'package:fanari_v2/widgets/youtube_attachment.dart';
// import 'package:fanari_v2/utils.dart' as utils;
// import 'package:fanari_v2/constants/credential.dart';
// import 'package:flutter_link_previewer/flutter_link_previewer.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart';

// class PostModel {
//   String uuid;
//   String? caption;
//   List<ServerImageModel> images;
//   List<PostVideoModel> videos;
//   String? audio;
//   String createdAt;

//   OwnerModel owner;

//   bool isLiked;

//   int likeCount;
//   int commentCount;
//   NhentaiBookModel? nhentaiBook;
//   YoutubeAttachment? youtubeAttachment;

//   PreviewData? linkPreview;

//   PostModel({
//     required this.uuid,
//     this.caption,
//     required this.images,
//     required this.videos,
//     this.audio,
//     required this.createdAt,
//     required this.owner,
//     required this.isLiked,
//     required this.likeCount,
//     required this.commentCount,
//     this.nhentaiBook,
//     this.youtubeAttachment,
//     this.linkPreview,
//   });
// }
