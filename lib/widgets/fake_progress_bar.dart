import 'dart:async';

import 'package:flutter/material.dart';

class FakeProgressBar extends StatefulWidget {
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;

  const FakeProgressBar({
    super.key,
    required this.width,
    this.height = 12,
    this.backgroundColor,
    this.progressColor,
  });

  @override
  State<FakeProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<FakeProgressBar> {
  double completeWidth = 0;

  @override
  void initState() {
    super.initState();
    _startDownloadProgress();
  }

  double _downloadProgress = 0;
  double _progressJump = 1;

  Timer? _timer;

  _startDownloadProgress() async {
    if (_downloadProgress >= 75) {
      return;
    }

    _timer?.cancel();
    _timer = Timer(Duration(seconds: 1), () {
      setState(() {
        _downloadProgress += _progressJump * 5;
        completeWidth = (widget.width / 100) * _downloadProgress;
      });

      _progressJump++;
      _startDownloadProgress();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color:
                widget.backgroundColor ??
                Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 372),
          height: widget.height,
          width: completeWidth,
          decoration: BoxDecoration(
            color:
                widget.progressColor ??
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}
