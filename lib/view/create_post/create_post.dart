import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/constants/credential.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/widgets/bouncing_three_dot.dart';
import 'package:fanari_v2/widgets/custom_dropdown.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/widgets/input_field_v_one.dart';
import 'package:fanari_v2/widgets/named_avatar.dart';
import 'package:fanari_v2/widgets/primary_button.dart';
import 'package:fanari_v2/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  bool _hasText = false;
  List<File> _selectedImages = [];
  String _selectedPrivacy = 'Public';
  int _optionsCount = 2;

  final TextEditingController _textController = TextEditingController();

  final TextEditingController _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionsController = List.generate(
    5,
    (index) => TextEditingController(),
  );

  VideoPlayerController? _videoController;

  String? _selectedVideoPath;
  String _loadingVideoText = 'Loading video';
  Subscription? _subscription;
  double _videoCompressProgress = 0.00;
  int _videoSize = 0;
  bool _loadingVideo = false;
  bool _videoError = false;
  Uint8List? _videoThumbnail;

  @override
  void initState() {
    super.initState();

    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      print('');
      print('Video compress progress: $progress');
      print('');
      setState(() {
        _videoCompressProgress = progress;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();

    _pollQuestionController.dispose();
    _pollOptionsController.forEach((element) => element.dispose());

    _videoController?.dispose();
    _subscription?.unsubscribe();
    VideoCompress.deleteAllCache();

    super.dispose();
  }

  Future<<String>> uploadImages(List<File> images) async {
    var uri = Uri.parse('${AppCredentials.domain}/image');
    var request = http.MultipartRequest('POST', uri);

    for (int i = 0; i < images.length; i++) {
      var image = images[i];

      final bytes = await image.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        debugPrint('');
        debugPrint('Error decoding image');
        debugPrint('');
        return;
      }

      final blur_hash = await BlurhashFFI.encode(
        MemoryImage(bytes),
        componentX: 4,
        componentY: 3,
      );

      // Attach image
      request.files.add(
        await http.MultipartFile.fromPath(
          'images', // <-- same key for all images
          image.path,
          filename: image.uri.pathSegments.last,
        ),
      );

      // Attach metadata for that image (by index)
      request.fields['width_$i'] = '${decodedImage.width}';
      request.fields['height_$i'] = '${decodedImage.height}';
      request.fields['blur_hash_$i'] = blur_hash;
      request.fields['used_at_$i'] = 'Post';
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Upload successful');
      print('Upload success: ${response.stream.toString()}');
    } else {
      print('Upload failed: ${response.statusCode}');
      print('Upload failed: ${response.stream.toString()}');
    }
  }

  Widget _selectedImagesWidget() {
    return Container(
      margin: EdgeInsets.only(
        bottom: _selectedImages.isEmpty ? 0 : 10.h,
        left: 6.w,
        right: 6.w,
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 272),
            height: _selectedImages.isEmpty ? 0 : 148.h,
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 20.w),
                  ..._selectedImages.asMap().entries.map((entry) {
                    int index = entry.key;
                    final image = entry.value;

                    final imageWidget = ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image(image: FileImage(image), height: 148.h),
                    );

                    return LongPressDraggable<int>(
                      data: index,
                      delay: Duration(milliseconds: 272),
                      feedback: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.white),
                        ),
                        child: imageWidget,
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: Container(
                          padding: const EdgeInsets.only(right: 12),
                          child: imageWidget,
                        ),
                      ),
                      child: DragTarget<int>(
                        onAcceptWithDetails: (details) {
                          setState(() {
                            final item = _selectedImages.removeAt(details.data);
                            _selectedImages.insert(index, item);
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                imageWidget,
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    width: 18.w,
                                    height: 18.w,
                                    margin: EdgeInsets.only(
                                      top: 4.w,
                                      right: 4.w,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
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
                                          size: 16,
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
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 272),
                height: _selectedImages.isEmpty ? 0 : 148.h,
                width: 40.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surface,
                      AppColors.surface.withValues(alpha: 0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 272),
                height: _selectedImages.isEmpty ? 0 : 148.h,
                width: 40.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surface,
                      AppColors.surface.withValues(alpha: 0),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textBox() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        hintText: 'What on your mind?',
        hintStyle: TextStyle(color: AppColors.hintText, fontSize: 24.sp),
        enabledBorder: InputBorder.none,
        border: InputBorder.none,
      ),
      cursorColor: AppColors.text,
      onChanged: (value) {
        if (_hasText != value.isNotEmpty) {
          setState(() {
            _hasText = value.isNotEmpty;
          });
        }
      },
      style: TextStyle(color: AppColors.text, fontSize: 18),
      maxLines: null,
      minLines: 5,
    );
  }

  Widget _profileWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          NamedAvatar(loading: false, name: 'Sabbir', size: 64.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Abdul Karim',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 72.w,
                  child: CustomDropDown(
                    selectedOption: _selectedPrivacy,
                    padding: EdgeInsets.all(6.w),
                    borderColor: AppColors.containerBg,
                    fillColor: AppColors.containerBg,
                    height: 26.h,
                    options: ['Public', 'Only Me', 'Followers'],
                    onChanged: (value) {
                      setState(() {
                        _selectedPrivacy = value;
                      });
                    },
                    optionTextStyle: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.text,
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18.w,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pollWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(width: 1, color: AppColors.hintText),
      ),
      child: Column(
        children: [
          InputFieldVOne(
            hintText: 'What\'s your go-to after-work drink?',
            controller: _pollQuestionController,
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.hintText),
            ),
          ),
          ...List.generate(_optionsCount, (index) {
            return Stack(
              alignment: Alignment.centerRight,
              children: [
                InputFieldVOne(
                  hintText: 'Option ${index + 1}',
                  controller: _pollOptionsController[index],
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.hintText),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _removeAnswer(index);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.h, right: 8.w),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.hintText,
                      size: 20.w,
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: CustomDropDown(
                  options: ['Single', 'Multiple'],
                  selectedOption: _selectedPollType,
                  borderColor: AppColors.hintText,
                  onChanged: (value) {
                    setState(() {
                      _selectedPollType = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 12.w),
              PrimaryButton(
                text: 'Add Option',
                onTap: () {
                  if (_optionsCount < _pollOptionsController.length) {
                    setState(() {
                      _optionsCount++;
                    });
                  }
                },
                width: (1.sw - 80.w - 12.w) / 2,
                height: 46.h,
                borderRadius: BorderRadius.circular(8.r),
                backgroundColor: AppColors.containerBg,
                textStyle: TextStyle(
                  fontSize: 14.sp,
                  color: _optionsCount < _pollOptionsController.length
                      ? AppColors.white
                      : AppColors.hintText,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _removeAnswer(int index) {
    for (int i = index; i < _optionsCount - 1; i++) {
      _pollOptionsController[i].text = _pollOptionsController[i + 1].text;
    }

    _pollOptionsController[_optionsCount - 1].clear();

    setState(() {
      _optionsCount--;
    });
  }

  String _selectedPollType = 'Single';

  bool _hasPoll = false;

  Widget _videoWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                VideoPlayerWidget(
                  width: 1.sw - 24,
                  height: (1.sw - 24) * 9 / 16,
                  controller: _videoController!,
                  aspectRatio: _videoController!.value.aspectRatio,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _videoController?.pause();
                      _videoController?.dispose();
                      _selectedVideoPath = null;
                      _videoController = null;
                    });
                  },
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
          // if (_videoSize != 0)
          //   Padding(
          //     padding: const EdgeInsets.only(top: 12, left: 6),
          //     child: Text(
          //       '${_videoSize / 1024 > 1024 ? '${(_videoSize / 1024 / 1024).toStringAsFixed(2)} MB' : '${(_videoSize / 1024).toStringAsFixed(2)} KB'} / 50MB',
          //       style: TextStyle(color: AppColors.text, fontSize: 14),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _videoProcessingWidget() {
    return Container(
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12),
      child: Stack(
        children: [
          if (_videoThumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image(
                height: (1.sw - 24) * 9 / 16,
                width: 1.sw - 24,
                fit: BoxFit.cover,
                image: MemoryImage(_videoThumbnail!),
              ),
            ),
          Container(
            width: 1.sw - 24,
            height: (1.sw - 24) * 9 / 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: .5),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_videoError)
                    Container(
                      width: 100,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          _videoCompressProgress.toString().length < 5
                              ? _videoCompressProgress.toString() + '%'
                              : _videoCompressProgress.toString().substring(
                                      0,
                                      5,
                                    ) +
                                    '%',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _loadingVideoText,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 6),
                      BouncingDots(color: AppColors.text, dotSize: 3),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return SafeArea(
      bottom: false,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                AppRoutes.pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                width: 36.w,
                height: 36.w,
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20.sp,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () async {
                print('');
                print('Uploading');
                print('');
                await uploadImages(_selectedImages);
                print('');
                print('Done');
                print('');
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Post',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _selectVideo() async {
    setState(() {
      _videoController = null;
      _selectedVideoPath = null;
    });

    final videos = await utils.pickVideoFromGallery(context: context, limit: 1);

    if (videos == null) {
      return;
    }
    setState(() {
      _loadingVideo = true;
    });

    final file = videos[0];

    // final thumbnail = await getThumbnail(file.path);
    // if (thumbnail == null) {
    //   utils.showCustomToast(
    //     text: 'Something went wrong, getting the thumbnail',
    //   );
    //   setState(() {
    //     _loadingVideo = false;
    //   });
    //   return;
    // }

    // setState(() {
    //   _videoThumbnail = thumbnail;
    // });

    // final compressedVideo = await VideoCompress.compressVideo(
    //   file.path,
    //   quality: VideoQuality.DefaultQuality,
    //   frameRate: 29,
    //   includeAudio: true,
    // );

    // if (compressedVideo == null) {
    //   utils.showCustomToast(
    //     text: 'Something went wrong, compressing the video',
    //   );
    //   setState(() {
    //     _loadingVideo = false;
    //   });
    //   return;
    // }

    // setState(() {
    //   _videoSize = compressedVideo.filesize!;
    // });

    _videoController = VideoPlayerController.file(file, closedCaptionFile: null)
      ..initialize().then((_) {
        setState(() {
          _videoController;
          _loadingVideo = false;
          _videoCompressProgress = 0.0;
          _selectedVideoPath = file.path;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(),
              SizedBox(height: 24.h),
              _profileWidget(),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
                child: _textBox(),
              ),
              _selectedImagesWidget(),
              SizedBox(height: 12.h),
              if (_loadingVideo) _videoProcessingWidget(),
              if (_selectedVideoPath != null) _videoWidget(),
              if (_hasPoll) _pollWidget(),
              SizedBox(height: 72.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  spacing: 18.w,
                  children: ['camera', 'video', 'poll'].map((item) {
                    return CustomSvg(
                      'assets/icons/post/$item.svg',
                      width: 20.w,
                      height: 20.w,
                      fit: BoxFit.contain,
                      onTap: () async {
                        if (item == 'camera') {
                          utils.showImagePickerOptions(context, (source) async {
                            final images = await utils.pickImageFromGallery(
                              context: context,
                            );

                            if (images == null) return;

                            setState(() {
                              _selectedImages.addAll(images);
                            });
                          });
                        } else if (item == 'poll') {
                          setState(() {
                            _hasPoll = !_hasPoll;
                          });
                        } else if (item == 'video') {
                          _selectVideo();
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 72.h),
            ],
          ),
        ),
      ),
    );
  }
}
