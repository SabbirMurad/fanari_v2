import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/video.dart';
import 'package:fanari_v2/model/youtube.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

enum MessageType { Text, Emoji, Image, Audio, Video, Attachment }

class TextModel {
  final String uuid;
  final String owner;
  final String conversation_id;
  final String? text;
  final List<ImageModel> images;
  final List<VideoModel> videos;
  final String? audio;
  final MessageType type;
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
    this.audio,
    this.youtube_attachment,
    this.link_preview,
  });

  factory TextModel.fromJson(Map<String, dynamic> json, String myId) {
    List<String> seen_by = [];
    for (var i = 0; i < json['seen_by'].length; i++) {
      seen_by.add(json['seen_by'][i]);
    }

    String? audio = json['audio'];

    late MessageType type;
    if (json['type'] == 'Text') {
      type = MessageType.Text;
    } else if (json['type'] == 'Emoji') {
      type = MessageType.Emoji;
    } else if (json['type'] == 'Image') {
      type = MessageType.Image;
    } else if (json['type'] == 'Audio') {
      type = MessageType.Audio;
    } else if (json['type'] == 'Video') {
      type = MessageType.Video;
    } else {
      type = MessageType.Attachment;
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
      audio: audio,
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
          this.link_preview = await getPreviewData(arr[i]);
          return;
        }
      }
    }
  }
}
