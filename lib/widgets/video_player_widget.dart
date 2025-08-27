import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoPlayerController controller;
  final double aspectRatio;
  final bool fullScreen;
  final double width;
  final double? height;
  final bool rotated;
  final bool autoPlay;
  final bool transparentBackground;

  const VideoPlayerWidget({
    super.key,
    this.autoPlay = false,
    this.transparentBackground = false,
    required this.controller,
    required this.aspectRatio,
    required this.width,
    this.fullScreen = false,
    this.height,
    this.rotated = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool isPlaying = false;
  double _videoPosition = 0;
  double _videoDuration = 0;

  bool showPlayControllers = true;
  late bool _rotated;
  bool _isBuffering = false;
  bool _soundOn = true;
  bool _ended = false;

  @override
  void initState() {
    super.initState();

    _rotated = widget.rotated;

    if (widget.autoPlay) {
      widget.controller.play();
      _timer?.cancel();
      setState(() {
        isPlaying = true;
      });
      _timer = Timer(Duration(seconds: 2), () {
        setState(() {
          showPlayControllers = false;
        });
      });
    }

    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          isPlaying = widget.controller.value.isPlaying;
          _videoPosition =
              widget.controller.value.position.inSeconds.toDouble();
          _videoDuration =
              widget.controller.value.duration.inSeconds.toDouble();

          _isBuffering = widget.controller.value.isBuffering;

          if (_videoDuration == _videoPosition) {
            _ended = true;
          }
        });
      }
    });
  }

  Timer? _timer;

  String _secondsToTime(double seconds) {
    return '${seconds ~/ 60}:${(seconds % 60).toStringAsFixed(0)}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!showPlayControllers) {
          setState(() {
            showPlayControllers = true;
          });

          _timer?.cancel();

          _timer = Timer(Duration(seconds: 5), () {
            setState(() {
              showPlayControllers = false;
            });
          });
        }
      },
      child: Container(
        width: widget.fullScreen ? double.infinity : widget.width,
        height:
            widget.fullScreen
                ? double.infinity
                : widget.height ?? widget.width / widget.aspectRatio,
        color: widget.transparentBackground ? Colors.transparent : Colors.black,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 372),
                opacity: showPlayControllers ? 1 : 0,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // color: Colors.pink,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color.fromRGBO(0, 0, 0, 0),
                        const Color.fromRGBO(0, 0, 0, .6),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 2,
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 8,
                          ),
                          thumbShape: const RoundSliderThumbShape(
                            disabledThumbRadius: 3,
                            enabledThumbRadius: 3,
                            elevation: 0,
                            pressedElevation: 2,
                          ),
                          trackShape: const RectangularSliderTrackShape(),
                        ),
                        child: Slider(
                          value: _videoPosition,
                          min: 0,
                          max: _videoDuration,
                          activeColor: Theme.of(context).colorScheme.primary,
                          thumbColor: Theme.of(context).colorScheme.primary,
                          inactiveColor: Colors.white.withValues(alpha: .8),
                          onChanged: (value) {
                            widget.controller.seekTo(
                              Duration(seconds: value.toInt()),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: _rotated ? 24 : 12,
                          right: _rotated ? 24 : 12,
                          bottom: _rotated ? 12 : 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                widget.controller.setVolume(_soundOn ? 0 : 1);

                                setState(() {
                                  _soundOn = !_soundOn;
                                });
                              },
                              child: AnimatedCrossFade(
                                firstChild: const Icon(
                                  Icons.volume_up,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                secondChild: const Icon(
                                  Icons.volume_off,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                crossFadeState:
                                    _soundOn
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                duration: const Duration(milliseconds: 300),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "${_secondsToTime(_videoPosition)} / ${_secondsToTime(_videoDuration)}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.end,
                            ),
                            Spacer(),
                            if (widget.fullScreen)
                              GestureDetector(
                                onTap: () {
                                  if (_rotated) {
                                    SystemChrome.setPreferredOrientations([
                                      DeviceOrientation.portraitUp,
                                      DeviceOrientation.portraitDown,
                                    ]);
                                  } else {
                                    SystemChrome.setPreferredOrientations([
                                      DeviceOrientation.landscapeLeft,
                                      DeviceOrientation.landscapeRight,
                                    ]);
                                  }

                                  setState(() {
                                    _rotated = !_rotated;
                                  });
                                },
                                child: Icon(
                                  Icons.screen_rotation_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (widget.fullScreen) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return FullScreenVidePlayer(
                                          controller: widget.controller,
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                              child: Icon(
                                widget.fullScreen
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!_isBuffering)
              Align(
                alignment: Alignment(0, -0.05),
                child:
                    _ended
                        ? GestureDetector(
                          onTap: () {
                            widget.controller.play().then((value) {
                              setState(() {
                                _ended = false;
                              });
                            });
                            _timer?.cancel();
                            setState(() {
                              isPlaying = true;
                            });
                            _timer = Timer(Duration(seconds: 2), () {
                              setState(() {
                                showPlayControllers = false;
                              });
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.25,
                                  ), // Shadow color
                                  blurRadius: 10, // Spread of the shadow
                                  offset: Offset(
                                    0,
                                    0,
                                  ), // Position of the shadow
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.replay_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        )
                        : AnimatedOpacity(
                          duration: const Duration(milliseconds: 372),
                          opacity: showPlayControllers ? 1 : 0,
                          child: GestureDetector(
                            onTap: () {
                              if (isPlaying) {
                                widget.controller.pause();
                                _timer?.cancel();
                                setState(() {
                                  showPlayControllers = true;
                                  isPlaying = false;
                                });
                              } else {
                                widget.controller.play();
                                _timer?.cancel();
                                setState(() {
                                  isPlaying = true;
                                  _ended = false;
                                });
                                _timer = Timer(Duration(seconds: 2), () {
                                  setState(() {
                                    showPlayControllers = false;
                                  });
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.25,
                                    ), // Shadow color
                                    blurRadius: 10, // Spread of the shadow
                                    offset: Offset(
                                      0,
                                      0,
                                    ), // Position of the shadow
                                  ),
                                ],
                              ),
                              child: AnimatedCrossFade(
                                firstChild: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  size: 32,
                                ),
                                secondChild: Icon(
                                  Icons.pause,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  size: 32,
                                ),
                                crossFadeState:
                                    isPlaying
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 300),
                              ),
                            ),
                          ),
                        ),
              ),
            if (_isBuffering)
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
          ],
        ),
      ),
    );
  }
}

class FullScreenVidePlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenVidePlayer({super.key, required this.controller});

  @override
  State<FullScreenVidePlayer> createState() => _FullScreenVidePlayerState();
}

class _FullScreenVidePlayerState extends State<FullScreenVidePlayer> {
  late bool rotated;

  @override
  void initState() {
    super.initState();

    if (widget.controller.value.aspectRatio > 1) {
      setState(() {
        rotated = true;
      });

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      setState(() {
        rotated = false;
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoPlayerWidget(
        width: 1.sw,
        controller: widget.controller,
        aspectRatio: widget.controller.value.aspectRatio,
        fullScreen: true,
        rotated: rotated,
      ),
    );
  }
}
