import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/emoji.dart';
import 'package:fanari_v2/providers/emoji.dart';
import 'package:fanari_v2/widgets/cross_fade_box.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/social_voice_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:extended_text_field/extended_text_field.dart';

class Mention {
  final String id;
  final String display;

  Mention(this.id, this.display);
}

class CommentInputWidget extends ConsumerStatefulWidget {
  const CommentInputWidget({super.key});

  @override
  ConsumerState<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends ConsumerState<CommentInputWidget> {
  TextEditingController _inputController = TextEditingController();
  final _spacialTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      if (_hasInputText) {
        if (_inputController.text.isEmpty) {
          setState(() {
            _hasInputText = false;
          });
        }
      } else {
        if (_inputController.text.isNotEmpty) {
          setState(() {
            _hasInputText = true;
          });
        }
      }
    });

    _spacialTextController.addListener(() {
      final text = _spacialTextController.text;
      final cursor = _spacialTextController.selection.baseOffset;

      print('');
      print('Text: $text');
      print('');
      if (cursor <= 0) return;

      final lastAt = text.lastIndexOf('@', cursor - 1);

      print('');
      print('Last At: $lastAt');
      print('');
      if (lastAt != -1) {
        final query = text.substring(lastAt + 1, cursor);

        print('');
        print('Query: $query');
        print('');
        if (!query.contains(' ') && query.isNotEmpty) {
          showMentionOverlay(query);
          return;
        }
      }

      removeOverlay();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _spacialTextController.dispose();

    super.dispose();
  }

  void insertMention(Mention user) {
    final text = _spacialTextController.text;
    final cursor = _spacialTextController.selection.baseOffset;

    final lastAt = text.lastIndexOf('@', cursor - 1);

    final before = text.substring(0, lastAt);
    final after = text.substring(cursor);

    final newText = '$before@${user.display} $after';

    _spacialTextController.text = newText;
    _spacialTextController.selection = TextSelection.collapsed(
      offset: (before + ' @${user.display} ').length,
    );
  }

  void showMentionOverlay(String query) async {
    print('');
    print('Overlay called');
    print('');
    // Fake search — replace with API / local search
    final users = await searchUsers(query);

    print('');
    print('User count: ${users.length}');
    print('');

    removeOverlay();
    if (users.isEmpty) return;

    // if (_overlayEntry != null) {
    //   _overlayEntry!.markNeedsBuild();
    //   return;
    // }

    double negativeOffset = -18.w - (users.length * 40.w).toDouble();

    print('');
    print('Called here to');
    print('');

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Align(
          alignment: Alignment.topLeft,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(-32.w, negativeOffset),
            showWhenUnlinked: false,
            child: Material(
              borderRadius: BorderRadius.circular(6.r),
              child: Container(
                width: 1.sw - 40.w - 24.w - 80.w - 24.w,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: users.asMap().entries.map((entry) {
                    final user = entry.value;
                    final index = entry.key;

                    return GestureDetector(
                      onTap: () {
                        insertMention(user);
                        removeOverlay();
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        height: 40.h,
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          border: index == users.length - 1
                              ? null
                              : Border(
                                  bottom: BorderSide(
                                    color: AppColors.border.withValues(
                                      alpha: 0.2,
                                    ),
                                    width: 1,
                                  ),
                                ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              user.display,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.text,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<List<Mention>> searchUsers(String query) async {
    final all = [
      Mention("1", "Sabbir"),
      Mention("2", "Sabina"),
      Mention("3", "Sabit"),
    ];

    return all
        .where((u) => u.display.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  bool _hasInputText = false;

  Widget _inputContainer(List<EmojiModel> emojis) {
    return Container(
      width: double.infinity,
      // height: 40.w,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4.w),
            child: CustomSvg(
              'assets/icons/emoji.svg',
              width: 20.w,
              height: 20.w,
              onTap: () {
                setState(() {
                  _showEmojis = !_showEmojis;
                });
              },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CompositedTransformTarget(
              link: _layerLink,
              child: ExtendedTextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: 'Write here ...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                  isDense: true,
                ),
                style: TextStyle(color: AppColors.text, fontSize: 14.sp),
                controller: _spacialTextController,
                specialTextSpanBuilder: MySpecialTextSpanBuilder(
                  emojis: emojis,
                ),
                maxLines: 5,
                minLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionsAndInput(List<EmojiModel> emojis) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () async {
            final images = await utils.pickImageFromGallery(context: context);
            if (images == null) return;

            setState(() {
              _selectedImages.addAll(images);
            });
          },
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomSvg(
                'assets/icons/attachment.svg',
                width: 18.w,
                height: 18.w,
                color: AppColors.text,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(child: _inputContainer(emojis)),
        SizedBox(width: 12.w),
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomSvg(
              'assets/icons/send.svg',
              width: 18.w,
              height: 18.w,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  bool _showEmojis = false;

  double _emojiCountParRow = 7;
  double _spaceBetweenEmoji = 8.w;
  late double _emojiWidth =
      (1.sw - 40.w - 24.w - (_spaceBetweenEmoji * (_emojiCountParRow - 1))) /
      _emojiCountParRow;

  Widget _emojiContainer(List<EmojiModel> emojis) {
    return AnimatedContainer(
      width: 1.sw - 40.w,
      height: _showEmojis ? ((1.sw - 40.w) * 9) / 16 : 0,
      margin: EdgeInsets.only(bottom: _showEmojis ? 12.h : 0),
      duration: Duration(milliseconds: 272),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: _spaceBetweenEmoji,
          runSpacing: _spaceBetweenEmoji,
          children: emojis.map((emoji) {
            return GestureDetector(
              onTap: () {
                insertEmoji(emoji.name);
              },
              child: Container(
                width: _emojiWidth,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: CachedNetworkImage(
                  imageUrl: emoji.webp_url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) {
                    return ColorFadeBox(width: _emojiWidth, height: 40.w);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void insertEmoji(String key) {
    final cursor = _spacialTextController.selection.baseOffset;

    final text = _spacialTextController.text;
    final newText = text.replaceRange(cursor, cursor, ':$key:');

    _spacialTextController.text = newText;

    _spacialTextController.selection = TextSelection.collapsed(
      offset: cursor + key.length + 2,
    );

    setState(() {
      _showEmojis = false;
    });
  }

  List<File> _selectedImages = [];

  Widget _imageContainer() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 372),
      height: _selectedImages.isEmpty ? 0 : 112.h,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: _selectedImages.isEmpty ? 0 : 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 20.w),
            ..._selectedImages.asMap().entries.map((entry) {
              int index = entry.key;
              final image = entry.value;

              return LongPressDraggable<int>(
                data: index,
                feedback: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.text),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image(image: FileImage(image), height: 112.h + 12),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: Container(
                    padding: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image(image: FileImage(image), height: 112.h),
                    ),
                  ),
                ),
                child: DragTarget<int>(
                  onAcceptWithDetails: (details) {
                    final item = _selectedImages.removeAt(details.data);
                    _selectedImages.insert(index, item);

                    setState(() {});
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image(
                              image: FileImage(image),
                              height: 112.h,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              margin: EdgeInsets.only(top: 6, right: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Color(0xFF181818).withValues(alpha: .45),
                              ),
                              child: Center(
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateZ(pi / 4),
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            SizedBox(width: 20.w),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emojis = ref
        .watch(emojiNotifierProvider)
        .when(
          data: (data) => data,
          error: (error, stackTrace) => <EmojiModel>[],
          loading: () => <EmojiModel>[],
        );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withValues(alpha: 0.85),
            AppColors.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _imageContainer(),
              _emojiContainer(emojis),
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _actionsAndInput(emojis),
                    if (!_hasInputText && _selectedImages.isEmpty)
                      SocialVoiceRecorder(
                        barWidth: 1.sw - 40.w - 40.w - 12.w,
                        barHeight: 40.w,
                        buttonSize: 40.w,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AtText extends SpecialText {
  static const String flag = "@";

  AtText(
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap, {
    required this.start,
  }) : super(flag, ' ', textStyle, onTap: onTap);

  final int start;

  @override
  InlineSpan finishText() {
    final mentionText = getContent();

    return SpecialTextSpan(
      text: '@$mentionText',
      actualText: '@$mentionText',
      start: start,
      style: const TextStyle(
        color: AppColors.primary, // your app primary color
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class EmojiText extends SpecialText {
  static const String flag = ":";

  final int start;
  final List<EmojiModel> emojis;

  EmojiText(
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap, {
    required this.start,
    required this.emojis,
  }) : super(flag, ":", textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    final key = getContent(); // smile

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
        imageUrl: emojis.firstWhere((element) => element.name == key).webp_url,
        width: 20.w,
        height: 20.w,
      ),
    );
  }
}

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  final List<EmojiModel> emojis;

  MySpecialTextSpanBuilder({required this.emojis});

  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    required int index,
  }) {
    if (flag == "@") {
      return AtText(textStyle, onTap, start: index);
    }

    if (flag == ":") {
      return EmojiText(textStyle, onTap, start: index, emojis: emojis);
    }

    return null;
  }
}
