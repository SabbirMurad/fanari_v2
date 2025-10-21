import 'package:fanari_v2/model/audio.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/video.dart';
import 'package:fanari_v2/model/youtube.dart';
import 'package:fanari_v2/model/attachment.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

enum TextType { Text, Emoji, Image, Audio, Video, Attachment }

class TextModel {
  final String uuid;
  final String owner;
  final String conversation_id;
  final String? text;
  final List<ImageModel> images;
  final List<VideoModel> videos;
  final AttachmentModel? attachment;
  final AudioModel? audio;
  final TextType type;
  final List<String> seen_by;
  final int created_at;
  final bool my_text;
  YoutubeModel? youtube_attachment;
  PreviewData? link_preview;

  TextModel({
    required this.uuid,
    required this.owner,
    required this.conversation_id,
    this.text,
    required this.my_text,
    required this.images,
    required this.seen_by,
    required this.created_at,
    required this.videos,
    required this.type,
    this.attachment,
    this.audio,
    this.youtube_attachment,
    this.link_preview,
  });

  factory TextModel.fromJson(Map<String, dynamic> json, String myId) {
    List<String> seen_by = [];
    for (var i = 0; i < json['seen_by'].length; i++) {
      seen_by.add(json['seen_by'][i]);
    }

    late TextType type;
    if (json['type'] == 'Text') {
      type = TextType.Text;
    } else if (json['type'] == 'Emoji') {
      type = TextType.Emoji;
    } else if (json['type'] == 'Image') {
      type = TextType.Image;
    } else if (json['type'] == 'Audio') {
      type = TextType.Audio;
    } else if (json['type'] == 'Video') {
      type = TextType.Video;
    } else {
      type = TextType.Attachment;
    }

    return TextModel(
      uuid: json['uuid'],
      owner: json['owner'],
      text: json['text'],
      type: type,
      conversation_id: json['conversation_id'],
      images: json['images'].map((item) => ImageModel.fromJson(item)).toList(),
      my_text: json['owner'] == myId,
      seen_by: seen_by,
      created_at: json['created_at'],
      videos: [],
      attachment: json['attachment'] == null
          ? null
          : AttachmentModel.fromJson(json['attachment']),
      audio: json['audio'] == null ? null : AudioModel.fromJson(json['audio']),
    );
  }

  load3rdPartyInfos() async {
    if (this.youtube_attachment == null &&
        this.images.isEmpty &&
        this.videos.isEmpty &&
        audio == null &&
        this.text != null) {
      final id = YoutubeModel.searchId(this.text!);
      if (id != null) {
        this.youtube_attachment = await YoutubeModel.load(id);
      }
    }

    if (this.link_preview == null &&
        this.images.isEmpty &&
        this.videos.isEmpty &&
        this.audio == null &&
        this.youtube_attachment == null &&
        this.text != null) {
      final arr = this.text!.split(' ');
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
