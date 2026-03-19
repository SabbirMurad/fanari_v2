import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/emoji.dart';
import 'package:fanari_v2/model/prepared_image.dart';
import 'package:fanari_v2/provider/emoji.dart';
import 'package:fanari_v2/view/home/widgets/comment_input_models.dart';
import 'package:fanari_v2/view/home/widgets/special_text_builders.dart';
import 'package:fanari_v2/widgets/bouncing_three_dot.dart';
import 'package:fanari_v2/widgets/cross_fade_box.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/social_voice_recorder.dart';
import 'package:fanari_v2/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils/media.dart' as media_utils;
import 'package:fanari_v2/utils.dart' as utils;
import 'package:extended_text_field/extended_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

export 'package:fanari_v2/view/home/widgets/comment_input_models.dart';

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
  // ── Text input ──────────────────────────────────────────────────────────

  final _textController = TextEditingController();
  final LayerLink _mentionLayerLink = LayerLink();
  OverlayEntry? _mentionOverlayEntry;
  bool _hasInputText = false;
  bool _typingSent = false;

  // ── Images ──────────────────────────────────────────────────────────────

  List<PreparedImage> _selectedImages = [];

  // ── Video ───────────────────────────────────────────────────────────────

  VideoPlayerController? _videoController;
  String? _selectedVideoPath;
  File? _videoThumbnail;
  bool _loadingVideo = false;
  bool _videoError = false;
  double _videoCompressProgress = 0.0;
  Subscription? _videoCompressSubscription;

  // ── Emojis ──────────────────────────────────────────────────────────────

  bool _showEmojis = false;
  final double _emojiCountPerRow = 7;
  final double _spaceBetweenEmoji = 8.w;
  late final double _emojiWidth =
      (1.sw - 40.w - 24.w - (_spaceBetweenEmoji * (_emojiCountPerRow - 1))) /
      _emojiCountPerRow;

  // ── Attachment overlay ──────────────────────────────────────────────────

  bool _attachmentsOptionsVisible = false;
  final LayerLink _attachmentLayerLink = LayerLink();
  OverlayEntry? _attachmentOverlayEntry;

  // ═══════════════════════════════════════════════════════════════════════
  // Lifecycle
  // ═══════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();

    _videoCompressSubscription = VideoCompress.compressProgress$.subscribe((
      progress,
    ) {
      setState(() => _videoCompressProgress = progress);
    });

    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _removeAttachmentOverlay();
    _removeMentionOverlay();
    _textController.dispose();
    _videoController?.dispose();
    _videoCompressSubscription?.unsubscribe();
    VideoCompress.deleteAllCache();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Text input handling
  // ═══════════════════════════════════════════════════════════════════════

  void _onTextChanged() {
    final isEmpty = _textController.text.isEmpty;
    if (_hasInputText && isEmpty) {
      setState(() => _hasInputText = false);
    } else if (!_hasInputText && !isEmpty) {
      setState(() => _hasInputText = true);
    }

    if (!isEmpty) {
      _emitTyping();
    }
    _handleMentionDetection();
  }

  void _emitTyping() {
    if (_typingSent) return;
    _typingSent = true;
    widget.onTyping?.call();
    Future.delayed(const Duration(seconds: 3), () => _typingSent = false);
  }

  void _handleMentionDetection() {
    final text = _textController.text;
    final cursor = _textController.selection.baseOffset;
    if (cursor <= 0) return;

    final lastAt = text.lastIndexOf('@', cursor - 1);
    if (lastAt != -1) {
      final query = text.substring(lastAt + 1, cursor);
      if (!query.contains(' ') && query.isNotEmpty) {
        _showMentionOverlay(query);
        return;
      }
    }

    _removeMentionOverlay();
  }

  void _onSendTap() {
    for (final image in _selectedImages) {
      if (!image.prepared) return;
    }

    widget.onSend?.call(
      CommentInputSubmitValue(
        text: _textController.text,
        images: _selectedImages,
        videoPath: _selectedVideoPath,
        videoThumbnail: _videoThumbnail,
      ),
    );

    _textController.text = '';

    if (_selectedVideoPath != null) {
      _videoController?.pause();
      _videoController?.dispose();
      setState(() {
        _selectedVideoPath = null;
        _videoController = null;
        _videoThumbnail = null;
      });
    }

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() => _selectedImages.clear());
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Mention overlay
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<Mention>> _searchUsers(String query) async {
    final all = [
      Mention("1", "Sabbir"),
      Mention("2", "Sabina"),
      Mention("3", "Sabit"),
    ];
    return all
        .where((u) => u.display.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void _insertMention(Mention user) {
    final text = _textController.text;
    final cursor = _textController.selection.baseOffset;
    final lastAt = text.lastIndexOf('@', cursor - 1);

    final beforeRaw = text.substring(0, lastAt);
    final after = text.substring(cursor);
    final needsSpaceBefore = beforeRaw.isNotEmpty && !beforeRaw.endsWith(' ');
    final before = needsSpaceBefore ? '$beforeRaw ' : beforeRaw;
    final mentionText = '@${user.display} ';
    final newText = '$before$mentionText$after';

    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(
      offset: (before + mentionText).length,
    );
  }

  void _showMentionOverlay(String query) async {
    final users = await _searchUsers(query);
    _removeMentionOverlay();
    if (users.isEmpty) return;

    final negativeOffset = -18.w - (users.length * 40.w).toDouble();

    _mentionOverlayEntry = OverlayEntry(
      builder: (context) {
        return Align(
          alignment: Alignment.topLeft,
          child: CompositedTransformFollower(
            link: _mentionLayerLink,
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
                    final isLast = entry.key == users.length - 1;

                    return GestureDetector(
                      onTap: () {
                        _insertMention(user);
                        _removeMentionOverlay();
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        height: 40.h,
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          border: isLast
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

    Overlay.of(context, rootOverlay: true).insert(_mentionOverlayEntry!);
  }

  void _removeMentionOverlay() {
    _mentionOverlayEntry?.remove();
    _mentionOverlayEntry = null;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Emoji handling
  // ═══════════════════════════════════════════════════════════════════════

  void _insertEmoji(String key) {
    final cursor = _textController.selection.baseOffset;
    final text = _textController.text;

    _textController.text = text.replaceRange(cursor, cursor, ':$key:');
    _textController.selection = TextSelection.collapsed(
      offset: cursor + key.length + 2,
    );

    setState(() => _showEmojis = false);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Image handling
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _handleGalleryTap() async {
    final images = await media_utils.pick_images_from_gallery(context: context);
    if (images == null) return;

    final prepared = PreparedImage.fromFiles(images);
    setState(() => _selectedImages.addAll(prepared));

    for (int i = 0; i < _selectedImages.length; i++) {
      if (_selectedImages[i].prepared) continue;
      final meta = await _selectedImages[i].get_prepare_meta();
      setState(() {
        _selectedImages[i].meta = meta;
        _selectedImages[i].prepared = true;
      });
    }
  }

  Future<void> _handleCameraTap() async {
    final image = await media_utils.pick_single_image(
      context: context,
      source: ImageSource.camera,
    );
    if (image == null) return;

    final prepared = PreparedImage.fromFile(image);
    setState(() => _selectedImages.add(prepared));

    for (int i = 0; i < _selectedImages.length; i++) {
      if (_selectedImages[i].prepared) continue;
      final meta = await _selectedImages[i].get_prepare_meta();
      setState(() {
        _selectedImages[i].meta = meta;
        _selectedImages[i].prepared = true;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Video handling
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _handleVideoTap() async {
    setState(() {
      _videoController = null;
      _selectedVideoPath = null;
      _videoThumbnail = null;
      _loadingVideo = true;
    });

    final videos = await media_utils.pick_videos_from_gallery(
      context: context,
      limit: 1,
    );

    if (videos == null) {
      setState(() => _loadingVideo = false);
      return;
    }

    final file = videos[0];

    final thumbnail = await VideoCompress.getFileThumbnail(
      file.path,
      quality: 80,
    );
    setState(() => _videoThumbnail = thumbnail);

    final compressedVideo = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.DefaultQuality,
      frameRate: 29,
      includeAudio: true,
    );

    if (compressedVideo == null) {
      utils.show_custom_toast(
        text: 'Something went wrong, compressing the video',
      );
      setState(() => _loadingVideo = false);
      return;
    }

    _videoController =
        VideoPlayerController.file(
            compressedVideo.file!,
            closedCaptionFile: null,
          )
          ..initialize().then((_) {
            setState(() {
              _loadingVideo = false;
              _videoCompressProgress = 0.0;
              _selectedVideoPath = compressedVideo.file!.path;
            });
          });
  }

  void _removeSelectedVideo() {
    _videoController?.pause();
    _videoController?.dispose();
    setState(() {
      _selectedVideoPath = null;
      _videoController = null;
      _videoThumbnail = null;
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Attachment overlay
  // ═══════════════════════════════════════════════════════════════════════

  void _handlePollTap() {}

  void _toggleAttachmentOptions() {
    if (_attachmentsOptionsVisible) {
      _removeAttachmentOverlay();
    } else {
      _showAttachmentOverlay();
    }
  }

  void _showAttachmentOverlay() {
    _removeAttachmentOverlay();

    final options = [
      {'icon': 'poll', 'onTap': _handlePollTap},
      {'icon': 'video', 'onTap': _handleVideoTap},
      {'icon': 'camera', 'onTap': _handleCameraTap},
      {'icon': 'gallery', 'onTap': _handleGalleryTap},
    ];

    final itemHeight = 40.w;
    final itemSpacing = 12.h;
    final totalHeight =
        options.length * itemHeight + (options.length - 1) * itemSpacing;

    _attachmentOverlayEntry = OverlayEntry(
      builder: (context) {
        return CompositedTransformFollower(
          link: _attachmentLayerLink,
          offset: Offset(0, -(totalHeight + itemSpacing)),
          showWhenUnlinked: false,
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options.map((opt) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: itemSpacing),
                    child: _buildAttachmentOptionButton(
                      icon: opt['icon'] as String,
                      onTap: opt['onTap'] as VoidCallback,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_attachmentOverlayEntry!);
    setState(() => _attachmentsOptionsVisible = true);
  }

  void _removeAttachmentOverlay() {
    _attachmentOverlayEntry?.remove();
    _attachmentOverlayEntry = null;
    if (_attachmentsOptionsVisible) {
      setState(() => _attachmentsOptionsVisible = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Widget builders
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildInputContainer(List<EmojiModel> emojis) {
    return Container(
      width: double.infinity,
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
              onTap: () => setState(() => _showEmojis = !_showEmojis),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CompositedTransformTarget(
              link: _mentionLayerLink,
              child: ExtendedTextField(
                autocorrect: false,
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
                controller: _textController,
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

  Widget _buildAttachmentToggleButton() {
    return CompositedTransformTarget(
      link: _attachmentLayerLink,
      child: GestureDetector(
        onTap: _toggleAttachmentOptions,
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
    );
  }

  Widget _buildAttachmentOptionButton({
    required String icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _removeAttachmentOverlay();
        onTap?.call();
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
            'assets/icons/post/$icon.svg',
            width: 20.w,
            height: 20.w,
            color: widget.colorTheme.textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _onSendTap,
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
    );
  }

  Widget _buildEmojiContainer(List<EmojiModel> emojis) {
    return AnimatedContainer(
      width: 1.sw - 40.w,
      height: _showEmojis ? ((1.sw - 40.w) * 9) / 16 : 0,
      margin: EdgeInsets.only(
        bottom: _showEmojis ? 12.h : 0,
        left: 20.w,
        right: 20.w,
      ),
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
              onTap: () => _insertEmoji(emoji.name),
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

  Widget _buildImageContainer() {
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
              final index = entry.key;
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
                    child: Image(
                      image: FileImage(image.file),
                      height: 112.h + 12,
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: Container(
                    padding: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image(image: FileImage(image.file), height: 112.h),
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
                      padding: EdgeInsets.only(right: 8.w),
                      child: IntrinsicWidth(
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6.r),
                              child: Image(
                                image: FileImage(image.file),
                                height: 112.h,
                              ),
                            ),
                            if (!image.prepared)
                              Container(
                                height: 112.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.r),
                                  color: Colors.black.withValues(alpha: .4),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: AppColors.primary,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            if (image.prepared)
                              GestureDetector(
                                onTap: () {
                                  setState(
                                    () => _selectedImages.removeAt(index),
                                  );
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  margin: EdgeInsets.only(top: 6, right: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Color(
                                      0xFF181818,
                                    ).withValues(alpha: .45),
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
                      ),
                    );
                  },
                ),
              );
            }),
            SizedBox(width: 20.w),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            VideoPlayerWidget(
              width: 0.7.sw - 24.w,
              height: (0.7.sw - 24.w) * 9 / 16,
              controller: _videoController!,
              aspectRatio: _videoController!.value.aspectRatio,
            ),
            GestureDetector(
              onTap: _removeSelectedVideo,
              child: Container(
                width: 28,
                height: 28,
                margin: EdgeInsets.only(top: 6, right: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Color(0xFF181818).withValues(alpha: .45),
                ),
                child: Center(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateZ(pi / 4),
                    child: Icon(Icons.add, size: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoProcessing() {
    final videoWidth = 0.7.sw - 24.w;
    final videoHeight = videoWidth * 9 / 16;

    final progressText = _videoCompressProgress.toStringAsFixed(1);

    return Container(
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image(
              height: videoHeight,
              width: videoWidth,
              fit: BoxFit.cover,
              image: FileImage(_videoThumbnail!),
            ),
          ),
          Container(
            width: videoWidth,
            height: videoHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Color(0xFF181818).withValues(alpha: .35),
            ),
            child: Center(
              child: _videoError
                  ? Text(
                      'Failed to compress video',
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(
                      width: 100,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(0xffffffff).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '$progressText%',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
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
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Build
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final emojis = ref
        .watch(emojiNotifierProvider)
        .when(
          data: (data) => data,
          error: (error, stackTrace) => <EmojiModel>[],
          loading: () => <EmojiModel>[],
        );

    final showVoiceRecorder =
        !_hasInputText && _selectedImages.isEmpty && _selectedVideoPath == null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: widget.colorTheme.bgGradient),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTyping) _buildTypingIndicator(),
              _buildImageContainer(),
              if (_loadingVideo && _videoThumbnail != null)
                _buildVideoProcessing(),
              if (_selectedVideoPath != null) _buildVideoPreview(),
              _buildEmojiContainer(emojis),
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          color: Colors.transparent,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(child: _buildInputContainer(emojis)),
                        SizedBox(width: 12.w),
                        _buildSendButton(),
                      ],
                    ),
                    if (showVoiceRecorder)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: SocialVoiceRecorder(
                          barWidth: 1.sw - 40.w - 40.w - 12.w,
                          barHeight: 40.w,
                          buttonSize: 40.w,
                          onRecordEnd: (audioFile, path) {},
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: _buildAttachmentToggleButton(),
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
