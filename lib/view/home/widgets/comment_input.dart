import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/emoji.dart';
import 'package:fanari_v2/providers/emoji.dart';
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:fanari_v2/widgets/bouncing_three_dot.dart';
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
        const Color.fromRGBO(24, 24, 24, 0.1),
        const Color.fromRGBO(24, 24, 24, 0.95),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  });
}

class CommentInputSubmitValue {
  final String? text;
  final String? audioPath;
  final List<File>? images;

  const CommentInputSubmitValue({this.text, this.audioPath, this.images});
}

class CommentInputWidget extends ConsumerStatefulWidget {
  final void Function(CommentInputSubmitValue)? onSend;
  final void Function()? onTyping;
  final CommentInputColorTheme colorTheme;
  final bool showTyping;

  const CommentInputWidget({
    super.key,
    this.colorTheme = const CommentInputColorTheme(),
    this.onSend,
    this.onTyping,
    this.showTyping = false,
  });

  @override
  ConsumerState<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends ConsumerState<CommentInputWidget> {
  final _spacialTextController = TextEditingController();

  bool _typingSent = false;

  @override
  void initState() {
    super.initState();

    _spacialTextController.addListener(() {
      printLine("called");
      if (_hasInputText) {
        if (_spacialTextController.text.isEmpty) {
          setState(() {
            _hasInputText = false;
          });
        }
        // return;
      } else {
        if (_spacialTextController.text.isNotEmpty) {
          setState(() {
            _hasInputText = true;
          });
        }
      }

      printLine(_typingSent);

      if (!_typingSent) {
        _typingSent = true;
        widget.onTyping?.call();

        Future.delayed(const Duration(seconds: 3), () {
          _typingSent = false;
        });
      }

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
    _spacialTextController.dispose();

    super.dispose();
  }

  void insertMention(Mention user) {
    final text = _spacialTextController.text;
    final cursor = _spacialTextController.selection.baseOffset;

    final lastAt = text.lastIndexOf('@', cursor - 1);

    final beforeRaw = text.substring(0, lastAt);
    final after = text.substring(cursor);

    // ensure space before @
    final needsSpaceBefore = beforeRaw.isNotEmpty && !beforeRaw.endsWith(' ');

    final before = needsSpaceBefore ? '$beforeRaw ' : beforeRaw;

    final mentionText = '@${user.display} ';

    final newText = '$before$mentionText$after';

    _spacialTextController.text = newText;
    _spacialTextController.selection = TextSelection.collapsed(
      offset: (before + mentionText).length,
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
                  color: widget.colorTheme.secondaryColor,
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
                                    color: widget.colorTheme.borderColor
                                        .withValues(alpha: 0.2),
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
                                color: widget.colorTheme.textColor,
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
        color: widget.colorTheme.secondaryColor,
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
                    color: widget.colorTheme.hintTextColor,
                    fontSize: 14.sp,
                  ),
                  isDense: true,
                ),
                style: TextStyle(
                  color: widget.colorTheme.textColor,
                  fontSize: 14.sp,
                ),
                controller: _spacialTextController,
                specialTextSpanBuilder: MySpecialTextSpanBuilder(
                  emojis: emojis,
                  mentionColor: widget.colorTheme.primaryColor,
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

  bool _attachmentsOptionsVisible = false;

  Widget _attachmentOptionsWidget() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 272),
      height: _attachmentsOptionsVisible
          ? 40.w + 12.h + 40.w + 12.h + 40.h
          : 40.w,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 272),
            bottom: _attachmentsOptionsVisible ? 40.w + 12.h + 40.w + 12.h : 0,
            child: GestureDetector(
              onTap: () async {
                // final images = await utils.pickSingleImage(
                //   context: context,
                //   source: ImageSource.camera,
                // );
                // if (images == null) return;

                // setState(() {
                //   _selectedImages.add(images);
                // });
              },
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: widget.colorTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomSvg(
                    'assets/icons/camera.svg',
                    width: 20.w,
                    height: 20.w,
                    color: widget.colorTheme.textColor,
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 272),
            bottom: _attachmentsOptionsVisible ? 40.w + 12.h : 0,
            child: GestureDetector(
              onTap: () async {
                final images = await utils.pickImageFromGallery(
                  context: context,
                  compress: true,
                );
                if (images == null) return;

                setState(() {
                  _selectedImages.addAll(images);
                });

                setState(() {
                  _attachmentsOptionsVisible = false;
                });
              },
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: widget.colorTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomSvg(
                    'assets/icons/gallery.svg',
                    width: 20.w,
                    height: 20.w,
                    color: widget.colorTheme.textColor,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _attachmentsOptionsVisible = !_attachmentsOptionsVisible;
              });
            },
            child: AnimatedContainer(
              width: 40.w,
              height: 40.w,
              duration: Duration(milliseconds: 272),
              decoration: BoxDecoration(
                color: _attachmentsOptionsVisible
                    ? widget.colorTheme.secondaryColor
                    : widget.colorTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _attachmentsOptionsVisible
                    ? Icon(
                        Icons.close_rounded,
                        size: 24.w,
                        color: widget.colorTheme.textColor,
                      )
                    : CustomSvg(
                        'assets/icons/attachment.svg',
                        width: 18.w,
                        height: 18.w,
                        color: widget.colorTheme.textColor,
                      ),
              ),
            ),
          ),
        ],
      ),
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
        color: widget.colorTheme.secondaryColor,
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
                  color: widget.colorTheme.emojiBackgroundColor,
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
                    border: Border.all(color: widget.colorTheme.textColor),
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
      decoration: BoxDecoration(gradient: widget.colorTheme.bgGradient),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showTyping)
                Padding(
                  padding: EdgeInsets.only(left: 20.w, bottom: 12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Typing',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      BouncingDots(dotSize: 3, gap: 4),
                    ],
                  ),
                ),
              _imageContainer(),
              _emojiContainer(emojis),
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _attachmentOptionsWidget(),
                        SizedBox(width: 12.w),
                        Expanded(child: _inputContainer(emojis)),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () {
                            widget.onSend?.call(
                              CommentInputSubmitValue(
                                text: _spacialTextController.text,
                                images: _selectedImages,
                              ),
                            );

                            _spacialTextController.text = '';
                            _selectedImages.clear();
                          },
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: widget.colorTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CustomSvg(
                                'assets/icons/send.svg',
                                width: 18.w,
                                height: 18.w,
                                color: widget.colorTheme.textColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
  final Color mentionColor;

  AtText(
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap, {
    required this.start,
    required this.mentionColor,
  }) : super(flag, ' ', textStyle, onTap: onTap);

  final int start;

  @override
  InlineSpan finishText() {
    final mentionText = getContent();

    return SpecialTextSpan(
      text: '@$mentionText',
      actualText: '@$mentionText',
      start: start,
      style: TextStyle(
        color: mentionColor, // your app primary color
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
