import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanari_v2/model/emoji.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AtText extends SpecialText {
  static const String flag = "@";
  final Color mentionColor;
  final int start;

  AtText(
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap, {
    required this.start,
    required this.mentionColor,
  }) : super(flag, ' ', textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    final mentionText = getContent();

    return SpecialTextSpan(
      text: '@$mentionText',
      actualText: '@$mentionText',
      start: start,
      style: TextStyle(
        color: mentionColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class EmojiText extends SpecialText {
  static const String beginFlag = " :";
  static const String finishFlag = ":";

  final int start;
  final List<EmojiModel> emojis;

  EmojiText(
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap, {
    required this.start,
    required this.emojis,
  }) : super(beginFlag, finishFlag, textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    final key = getContent();

    EmojiModel? emojiModel;
    for (final emoji in emojis) {
      if (emoji.name == key) {
        emojiModel = emoji;
        break;
      }
    }

    if (emojiModel == null) {
      return TextSpan(text: ':$key:', style: super.textStyle);
    }

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: CachedNetworkImage(
        imageUrl: emojiModel.webp_url,
        width: 20.w,
        height: 20.w,
      ),
    );
  }
}

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  final List<EmojiModel> emojis;
  final Color mentionColor;

  MySpecialTextSpanBuilder({required this.emojis, required this.mentionColor});

  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    required int index,
  }) {
    if (flag == "@") {
      return AtText(textStyle, onTap, start: index, mentionColor: mentionColor);
    }

    if (flag == ":") {
      return EmojiText(textStyle, onTap, start: index, emojis: emojis);
    }

    return null;
  }
}
