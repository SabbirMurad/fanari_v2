import 'dart:convert';

import 'package:fanari_v2/model/attachment.dart';
import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/model/video.dart';

class SocketOutgoingText {
  final String conversation_id;
  final TextType type;
  final String? text;
  final List<MentionModel>? mentions;
  final List<String>? images;
  final VideoModel? video;
  final String? audio;
  final AttachmentModel? attachment;
  final String? reply_to;

  const SocketOutgoingText({
    required this.conversation_id,
    required this.type,
    this.text,
    this.images,
    this.video,
    this.mentions,
    this.audio,
    this.attachment,
    this.reply_to,
  });

  Map<String, dynamic> to_json() {
    return {
      'conversation_id': conversation_id,
      'text': text,
      'mentions': mentions,
      'images': images,
      'audio': audio,
      'videos': video,
      'type': type.name,
      'attachment': attachment,
      'reply_to': reply_to,
    };
  }

  String stringify() => jsonEncode(to_json());
}
