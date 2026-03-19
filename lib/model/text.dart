import 'package:fanari_v2/model/media/attachment.dart';
import 'package:fanari_v2/model/media/audio.dart';
import 'package:fanari_v2/model/media/image.dart';
import 'package:fanari_v2/model/media/video.dart';
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

  /// For parsing texts from API responses (e.g. /conversation/texts)
  /// where image/video data is already resolved inline.
  factory TextModel.fromJson(
    Map<String, dynamic> json, {
    required String my_id,
  }) {
    final type = switch (json['type'] as String) {
      'Text' => TextType.Text,
      'Emoji' => TextType.Emoji,
      'Image' => TextType.Image,
      'Audio' => TextType.Audio,
      'Video' => TextType.Video,
      _ => TextType.Attachment,
    };

    List<ImageModel>? images;
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      images = (json['images'] as List)
          .map((img) => ImageModel.fromJson(img as Map<String, dynamic>))
          .toList();
    }

    VideoModel? video;
    if (json['video'] != null) {
      video = VideoModel.fromJson(json['video'] as Map<String, dynamic>);
    }

    return TextModel(
      uuid: json['uuid'] as String,
      owner: json['owner'] as String,
      conversation_id: json['conversation_id'] as String,
      text: json['text'] as String?,
      type: type,
      images: images,
      video: video,
      my_text: json['owner'] == my_id,
      seen_by: List<String>.from(json['seen_by'] as List? ?? []),
      created_at: json['created_at'] as int,
      attachment: json['attachment'] != null
          ? AttachmentModel.fromJson(json['attachment'])
          : null,
      audio: json['audio'] != null ? AudioModel.fromJson(json['audio']) : null,
    );
  }

  static List<TextModel> fromJsonList(
    List<dynamic> json, {
    required String my_id,
  }) {
    return json.map((item) {
      return TextModel.fromJson(item as Map<String, dynamic>, my_id: my_id);
    }).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': this.uuid,
      'conversation_id': this.conversation_id,
      'owner': this.owner,
      'type': this.type.name,
      'text': this.text,
      'images': this.images?.map((img) => img.toJson()).toList(),
      'video': this.video != null ? this.video!.toJson() : null,
      'audio': this.audio != null ? this.audio!.toJson() : null,
      'attachment': this.attachment != null ? this.attachment!.toJson() : null,
      'seen_by': this.seen_by,
      'created_at': this.created_at,
    };
  }

  TextModel copyWith({List<String>? seen_by}) {
    return TextModel(
      uuid: uuid,
      owner: owner,
      conversation_id: conversation_id,
      text: text,
      my_text: my_text,
      images: images,
      seen_by: seen_by ?? this.seen_by,
      created_at: created_at,
      video: video,
      type: type,
      attachment: attachment,
      audio: audio,
      youtube_attachment: youtube_attachment,
      link_preview: link_preview,
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
