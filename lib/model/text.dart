import 'package:fanari_v2/model/attachment.dart';
import 'package:fanari_v2/model/audio.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/video.dart';
import 'package:fanari_v2/model/youtube.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';

enum TextType { Text, Emoji, Image, Audio, Video, Attachment }

class TextModel {
  final String uuid;
  final String owner;
  final String conversation_id;
  final String? text;
  final List<ImageModel>? images;
  final VideoModel? video;
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
    this.images,
    required this.seen_by,
    required this.created_at,
    this.video,
    required this.type,
    this.attachment,
    this.audio,
    this.youtube_attachment,
    this.link_preview,
  });

  /// Pure synchronous factory. Image metadata must be fetched by the caller
  /// (e.g. the socket handler) and passed in as [images].
  factory TextModel.from_payload(
    Map<String, dynamic> json, {
    required String my_id,
    List<ImageModel>? images,
    VideoModel? video,
  }) {
    final type = switch (json['type'] as String) {
      'Text' => TextType.Text,
      'Emoji' => TextType.Emoji,
      'Image' => TextType.Image,
      'Audio' => TextType.Audio,
      'Video' => TextType.Video,
      _ => TextType.Attachment,
    };

    return TextModel(
      uuid: json['uuid'] as String,
      owner: json['owner'] as String,
      conversation_id: json['conversation_id'] as String,
      text: json['text'] as String?,
      type: type,
      images: images,
      my_text: json['owner'] == my_id,
      seen_by: List<String>.from(json['seen_by'] as List),
      created_at: json['created_at'] as int,
      video: video,
      attachment: json['attachment'] != null
          ? AttachmentModel.fromJson(json['attachment'])
          : null,
      audio: json['audio'] != null ? AudioModel.fromJson(json['audio']) : null,
    );
  }

  Future<TextModel?> load_third_party_infos() async {
    if (youtube_attachment == null &&
        images == null &&
        video == null &&
        audio == null &&
        text != null) {
      final id = YoutubeModel.searchId(text!);
      if (id != null) {
        youtube_attachment = await YoutubeModel.load(id);
        return this;
      }
    }

    if (link_preview == null &&
        images == null &&
        video == null &&
        audio == null &&
        youtube_attachment == null &&
        text != null) {
      for (final word in text!.split(' ')) {
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
