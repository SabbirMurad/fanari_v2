import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SimpleAudioPlayer extends StatefulWidget {
  final double width;
  final Source audioSource;
  final Color? primaryColor;

  const SimpleAudioPlayer({
    super.key,
    required this.width,
    required this.audioSource,
    this.primaryColor,
  });

  @override
  State<SimpleAudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<SimpleAudioPlayer> {
  final player = AudioPlayer();
  bool _playerReady = false;
  bool _playing = false;
  double _currentPosition = 0;
  double _totalDuration = 0;
  bool _completed = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();

    player.setSource(widget.audioSource).then((_) {
      player.getDuration().then((value) {
        setState(() {
          _totalDuration = value!.inSeconds.toDouble();
          _playerReady = true;
        });
      });
    });

    player.onPositionChanged.listen((value) {
      setState(() {
        _currentPosition = value.inSeconds.toDouble();
        _completed = true;
      });
    });

    player.onPlayerComplete.listen((_) {
      setState(() {
        _playing = false;
      });
    });
  }

  @override
  void dispose() {
    player.release();
    player.dispose();
    super.dispose();
  }

  String _secondsToTime(double seconds) {
    return '${(seconds ~/ 60) < 10 ? '0' : ''}${seconds ~/ 60}:${int.parse((seconds % 60).toStringAsFixed(0)) < 10 ? '0' : ''}${(seconds % 60).toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              if (!_playerReady) return;

              if (_playing) {
                player.pause();
              } else {
                player.resume();
              }

              setState(() {
                _playing = !_playing;
              });

              if (!_started) {
                setState(() {
                  _started = true;
                });
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    widget.primaryColor ??
                    Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    !_playerReady
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white,
                          ),
                        )
                        : AnimatedCrossFade(
                          firstChild: Icon(
                            Icons.play_arrow_rounded,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 28,
                          ),
                          secondChild: Icon(
                            Icons.pause,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 28,
                          ),
                          crossFadeState:
                              _playing
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 0,
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
                    value: _currentPosition,
                    min: 0,
                    max: _totalDuration,
                    activeColor:
                        widget.primaryColor ??
                        Theme.of(context).colorScheme.primary,
                    thumbColor:
                        widget.primaryColor ??
                        Theme.of(context).colorScheme.primary,
                    inactiveColor: Colors.white.withValues(alpha: .8),
                    onChanged: (value) {
                      player.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 2, right: 2),
                  child: Text(
                    _started
                        ? "${_secondsToTime(_currentPosition)}"
                        : "${_secondsToTime(_totalDuration)}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
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
}
