import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class HeartBeatAnimation extends StatefulWidget {
  final Widget selectedChild;
  final Widget unselectedChild;
  final bool selected;
  final Duration duration;
  final double scale;
  final Function()? onChange;

  const HeartBeatAnimation({
    super.key,
    required this.selected,
    required this.selectedChild,
    required this.unselectedChild,
    required this.duration,
    required this.scale,
    this.onChange,
  });

  @override
  State<HeartBeatAnimation> createState() => _HeartBeatAnimationState();
}

class _HeartBeatAnimationState extends State<HeartBeatAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  final _audioPlayer = AudioPlayer();

  late bool selected;

  @override
  void initState() {
    super.initState();

    setState(() {
      selected = widget.selected;
    });

    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    animation = Tween<double>(begin: 1, end: widget.scale).animate(controller);
  }

  Future doAnimation() async {
    await controller.forward();
    setState(() {
      selected = !selected;
    });
    await Future.delayed(const Duration(microseconds: 400));
    await controller.reverse();
  }

  @override
  void dispose() {
    controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _audioPlayer.stop();
        _audioPlayer.play(AssetSource('audios/ui-click.mp3'));
        widget.onChange?.call();
        doAnimation();
      },
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(animation.value),
            child: selected ? widget.selectedChild : widget.unselectedChild,
          );
        },
      ),
    );
  }
}
