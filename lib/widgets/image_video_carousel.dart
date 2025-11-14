import 'dart:ui';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/video.dart';
import 'package:fanari_v2/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

enum CarouselItemType { image, video }

class CarouselItem {
  final CarouselItemType type;
  final ImageModel? image;
  final VideoModel? video;

  const CarouselItem({required this.type, this.image, this.video});
}

class ImageVideoCarousel extends StatefulWidget {
  final List<ImageModel> images;
  final double height;
  final double width;
  final List<VideoModel> videos;
  final BorderRadius? borderRadius;
  final bool showIndicators;
  const ImageVideoCarousel({
    super.key,
    required this.images,
    this.videos = const [],
    required this.height,
    required this.width,
    this.borderRadius,
    this.showIndicators = true,
  });

  @override
  State<ImageVideoCarousel> createState() => _ImageVideoCarouselState();
}

class _ImageVideoCarouselState extends State<ImageVideoCarousel> {
  int _selectedItemIndex = 0;

  final PageController _pageController = PageController();

  List<CarouselItem> _carouselItems = [];

  @override
  void initState() {
    super.initState();

    for (var video in widget.videos) {
      _carouselItems.add(
        CarouselItem(type: CarouselItemType.video, video: video),
      );
    }

    for (var image in widget.images) {
      _carouselItems.add(
        CarouselItem(type: CarouselItemType.image, image: image),
      );
    }

    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget buildCarousel() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color.fromRGBO(24, 24, 24, .3),
                    BlendMode.darken,
                  ),
                  child: CachedNetworkImage(
                    imageUrl:
                        _carouselItems[_selectedItemIndex].type ==
                            CarouselItemType.image
                        ? _carouselItems[_selectedItemIndex].image!.webp_url
                        : _carouselItems[_selectedItemIndex]
                              .video!
                              .thumbnailUrl,
                    height: widget.height,
                    width: widget.width,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      return Container(
                        color: AppColors.secondary,
                        width: widget.width,
                        height: widget.height,
                      );
                    },
                    errorWidget: (context, url, error) => SizedBox(),
                  ),
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
            child: PageView(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() {
                  _selectedItemIndex = value;
                });
              },
              children: _carouselItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return SizedBox(
                  height: widget.height,
                  width: widget.width,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        if (item.type == CarouselItemType.image) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) {
                                return FullScreenCarousel(
                                  backgroundColor: Colors.black,
                                  items: _carouselItems,
                                  selectedIndex: index,
                                );
                              },
                            ),
                          );
                        }
                      },
                      child: item.type == CarouselItemType.image
                          ? singleImageItem(item)
                          : CarouselSingleVideoItem(
                              height: widget.height,
                              item: item,
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 16.w),
              margin: EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.surface.withValues(alpha: .6),
              ),
              child: Text(
                '${_selectedItemIndex + 1} / ${_carouselItems.length}',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (widget.showIndicators)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                child: AnimatedSmoothIndicator(
                  count: _carouselItems.length,
                  activeIndex: _selectedItemIndex,
                  duration: const Duration(milliseconds: 372),
                  curve: Curves.easeInOut,
                  onDotClicked: (index) => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 372),
                    curve: Curves.easeInOut,
                  ),
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.primary,
                    dotColor: AppColors.surface.withValues(alpha: .4),
                    dotWidth: 8,
                    dotHeight: 8,
                    spacing: 8,
                    expansionFactor: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget singleImageItem(CarouselItem item) {
    return CachedNetworkImage(
      imageUrl: item.image!.webp_url,
      height: widget.height,
      fit: BoxFit.contain,
      placeholder: (context, url) {
        return Container(
          color: AppColors.secondary,
          width: widget.width,
          height: widget.height,
        );
      },
      errorWidget: (context, url, error) => Container(
        color: AppColors.secondary,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            decoration: BoxDecoration(
              color: Color.fromRGBO(24, 24, 24, 0.8),
              border: Border.all(color: Colors.white.withValues(alpha: .1)),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(24, 24, 24, .2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Couldn\'t load image',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSingleItemCarousel() {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
      child: GestureDetector(
        onTap: () {
          if (_carouselItems[0].type == CarouselItemType.image) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) {
                  return FullScreenCarousel(
                    backgroundColor: Colors.black,
                    items: _carouselItems,
                    selectedIndex: 0,
                  );
                },
              ),
            );
          }
        },
        child: _carouselItems[0].type == CarouselItemType.image
            ? singleImageItem(_carouselItems[0])
            : CarouselSingleVideoItem(
                height: widget.height,
                item: _carouselItems[0],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _carouselItems.length > 1
        ? buildCarousel()
        : buildSingleItemCarousel();
  }
}

class CarouselSingleVideoItem extends StatefulWidget {
  final double height;
  final CarouselItem item;
  final bool autoPlay;

  const CarouselSingleVideoItem({
    super.key,
    required this.height,
    required this.item,
    this.autoPlay = false,
  });

  @override
  State<CarouselSingleVideoItem> createState() =>
      CarouselSingleVideoItemState();
}

class CarouselSingleVideoItemState extends State<CarouselSingleVideoItem> {
  bool _playClicked = false;
  bool _videoLoaded = false;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();

    if (widget.autoPlay) {
      loadVideo();
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void loadVideo() async {
    setState(() {
      _playClicked = true;
    });

    final url = Uri.parse(widget.item.video!.videoUrl);

    _videoPlayerController =
        VideoPlayerController.networkUrl(
            url,
            videoPlayerOptions: VideoPlayerOptions(
              allowBackgroundPlayback: true,
              mixWithOthers: true,
            ),
            formatHint: VideoFormat.hls,
          )
          ..initialize()
              .then((_) {
                _videoLoaded = true;
                setState(() {});
              })
              .catchError((error) {
                print('');
                print('Error in video player');
                print(error);
                print('');
              });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (!_videoLoaded)
          CachedNetworkImage(
            imageUrl: widget.item.video!.thumbnailUrl,
            width: double.infinity,
            fit: BoxFit.contain,
            placeholder: (context, url) {
              return Container(
                color: AppColors.secondary,
                width: double.infinity,
                height: widget.height,
              );
            },
            errorWidget: (context, url, error) => Container(
              color: AppColors.secondary,
              height: widget.height,
              width: double.infinity,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(24, 24, 24, 0.8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .2),
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: .15),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Couldn\'t load thumbnail',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (!_playClicked)
          GestureDetector(
            onTap: () {
              loadVideo();
            },
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: .2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.25,
                      ), // Shadow color
                      blurRadius: 10, // Spread of the shadow
                      offset: Offset(0, 0), // Position of the shadow
                    ),
                  ],
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.text,
                  size: 32,
                ),
              ),
            ),
          ),
        if (_playClicked && !_videoLoaded)
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.grey[200],
                strokeWidth: 1.5,
              ),
            ),
          ),
        if (_videoLoaded && _videoPlayerController != null)
          VideoPlayerWidget(
            autoPlay: true,
            transparentBackground: true,
            controller: _videoPlayerController!,
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            width: 1.sw,
          ),
      ],
    );
  }
}

class FullScreenCarousel extends StatefulWidget {
  final Color backgroundColor;
  final List<CarouselItem> items;
  final int selectedIndex;

  const FullScreenCarousel({
    super.key,
    this.backgroundColor = Colors.black,
    required this.items,
    required this.selectedIndex,
  });

  @override
  State<FullScreenCarousel> createState() => _FullScreenCarouselState();
}

class _FullScreenCarouselState extends State<FullScreenCarousel> {
  late PageController _pageController;

  late List<TransformationController> _transformationControllers =
      List.generate(widget.items.length, (_) => TransformationController());
  bool _isOriginalState = true;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: widget.selectedIndex);

    _transformationControllers.forEach((controller) {
      controller.addListener(() {
        final isOriginal = _isMatrixIdentity(controller.value);
        if (_isOriginalState != isOriginal) {
          setState(() {
            _isOriginalState = isOriginal;
          });
        }
      });
    });
  }

  bool _isMatrixIdentity(Matrix4 matrix, {double tolerance = 0.01}) {
    // Compare each element of the matrix with the identity matrix within a tolerance
    final identity = Matrix4.identity();
    for (int i = 0; i < 16; i++) {
      if ((matrix.storage[i] - identity.storage[i]).abs() > tolerance) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: widget.backgroundColor,
        child: PageView(
          physics: _isOriginalState
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: widget.items.asMap().entries.map((entry) {
            final item = entry.value;

            if (item.type == CarouselItemType.image) {
              return InteractiveViewer(
                maxScale: 4.0,
                minScale: 0.4,
                transformationController: _transformationControllers[entry.key],
                child: CachedNetworkImage(
                  imageUrl: item.image!.webp_url,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (context, url) {
                    return Container(
                      color: AppColors.secondary,
                      width: double.infinity,
                      height: (1.sw / 4) * 5,
                    );
                  },
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white,
                    size: 1.sw * 0.05,
                  ),
                ),
              );
            } else {
              return CarouselSingleVideoItem(
                height: (1.sw / 4) * 5,
                item: item,
              );
            }
          }).toList(),
        ),
      ),
    );
  }
}
