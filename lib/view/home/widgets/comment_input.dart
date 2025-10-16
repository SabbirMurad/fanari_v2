import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/social_voice_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart' as utils;

class CommentInputWidget extends StatefulWidget {
  const CommentInputWidget({super.key});

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  TextEditingController _inputController = TextEditingController();

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
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  bool _hasInputText = false;

  Widget _inputContainer() {
    return Container(
      width: double.infinity,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showEmojis = !_showEmojis;
              });
            },
            child: CustomSvg(
              'assets/icons/emoji.svg',
              width: 20.w,
              height: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _inputController,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionsAndInput() {
    return Row(
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
        Expanded(child: _inputContainer()),
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

  Widget _emojiContainer() {
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
          children: List.generate(50, (index) {
            return Container(
              width: _emojiWidth,
              height: 40.w,
              color: Colors.green,
            );
          }),
        ),
      ),
    );
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
              _emojiContainer(),
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    _actionsAndInput(),
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
