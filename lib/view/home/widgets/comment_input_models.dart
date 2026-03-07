import 'dart:io';

import 'package:fanari_v2/model/prepared_image.dart';
import 'package:flutter/material.dart';

class Mention {
  final String id;
  final String display;

  Mention(this.id, this.display);
}

class CommentInputColorTheme {
  final Color primaryColor;
  final Color textColor;
  final Color secondaryColor;
  final Color borderColor;
  final Color hintTextColor;
  final Color emojiBackgroundColor;
  final Gradient bgGradient;

  const CommentInputColorTheme({
    this.primaryColor = const Color(0xff7D9FFE),
    this.secondaryColor = const Color(0xff3A3A3A),
    this.textColor = const Color(0xffF9F9F9),
    this.borderColor = const Color(0xffF4F7E4),
    this.hintTextColor = const Color(0xFFa3a3a3),
    this.emojiBackgroundColor = const Color.fromRGBO(24, 24, 24, 0.2),
    this.bgGradient = const LinearGradient(
      colors: [
        Color.fromRGBO(24, 24, 24, 0.1),
        Color.fromRGBO(24, 24, 24, 0.95),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  });
}

class CommentInputSubmitValue {
  final String? text;
  final String? audioPath;
  final List<PreparedImage>? images;
  final String? videoPath;
  final File? videoThumbnail;

  const CommentInputSubmitValue({
    this.text,
    this.audioPath,
    this.images,
    this.videoPath,
    this.videoThumbnail,
  });
}
