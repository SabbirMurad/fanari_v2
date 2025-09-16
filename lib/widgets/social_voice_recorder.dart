import 'dart:async';
import 'dart:io';

import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/bouncing_three_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class SocialVoiceRecorder extends StatefulWidget {
  final void Function()? onRecordStart;
  final void Function(File audioFile, String path)? onRecordEnd;

  final Duration? startAnimationDuration;
  final Widget? startButton;
  final Widget? stopButton;
  final Widget? recordingIcon;
  final double barWidth;
  final double barHeight;
  final double buttonSize;
  final Color? backgroundColor;
  final double? borderRadius;
  final Text? recordingText;
  final TextDirection direction;

  const SocialVoiceRecorder({
    super.key,
    this.onRecordStart,
    this.onRecordEnd,
    this.startButton,
    this.stopButton,
    required this.barWidth,
    required this.barHeight,
    required this.buttonSize,
    this.backgroundColor,
    this.borderRadius,
    this.recordingText,
    this.recordingIcon,
    this.startAnimationDuration,
    this.direction = TextDirection.rtl,
  });

  @override
  State<SocialVoiceRecorder> createState() => _SocialVoiceRecorderState();
}

class _SocialVoiceRecorderState extends State<SocialVoiceRecorder> {
  bool _isAcceptedPermission = false;
  AudioRecorder recordMp3 = AudioRecorder();
  String? _filePath;
  int _secondCounter = 0;
  int _minuteCounter = 0;
  Timer? _timer;
  bool _recording = false;
  bool _showInfo = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    recordMp3.stop();
    super.dispose();
  }

  _checkPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        _isAcceptedPermission = true;
      }
    }
  }

  void _startTimer() {
    setState(() {
      _secondCounter = 0;
      _minuteCounter = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondCounter == 59) {
          _secondCounter = 0;
          _minuteCounter++;
        } else {
          _secondCounter++;
        }
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _secondCounter = 0;
      _minuteCounter = 0;
    });

    _timer?.cancel();
  }

  Future<String> _getFilePath() async {
    String _sdPath = "";
    Directory tempDir = await getTemporaryDirectory();
    _sdPath = tempDir.path;
    var d = Directory(_sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    DateTime now = DateTime.now();
    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    convertedDateTime = convertedDateTime.replaceAll(":", ".");
    String storagePath = _sdPath + "/" + convertedDateTime + '.m4a';
    _filePath = storagePath;
    return storagePath;
  }

  _startRecording() async {
    if (!_isAcceptedPermission) {
      await Permission.microphone.request();
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
      _isAcceptedPermission = true;
    } else {
      String recordFilePath = await _getFilePath();
      setState(() {
        _recording = true;
      });

      Future.delayed(
        (widget.startAnimationDuration ?? const Duration(milliseconds: 372)) -
            const Duration(milliseconds: 72),
        () {
          setState(() {
            _showInfo = true;
          });
          _startTimer();
          recordMp3.start(
            const RecordConfig(
              encoder: AudioEncoder.aacLc,
              bitRate: 128000, // Increase for better quality
              sampleRate: 44100,
              noiseSuppress: true,
              androidConfig: AndroidRecordConfig(muteAudio: true),
            ),
            path: recordFilePath,
          );

          widget.onRecordStart?.call();
        },
      );
    }
  }

  _stopRecoding() {
    recordMp3.stop();
    _stopTimer();

    setState(() {
      _recording = false;
    });
    widget.onRecordEnd?.call(File.fromUri(Uri(path: _filePath!)), _filePath!);

    Future.delayed(const Duration(milliseconds: 72), () {
      if (mounted) {
        setState(() {
          _showInfo = false;
        });
      }
    });
  }

  Widget _startButton() {
    return widget.startButton ??
        Container(
          width: widget.buttonSize,
          height: widget.buttonSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.string(
              micIcon,
              height: widget.buttonSize * .6,
              color: Colors.white,
            ),
          ),
        );
  }

  String micIcon =
      '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="46" viewBox="0 0 28 46"><g transform="translate(-10 -1)"><path d="M24,33a8,8,0,0,0,8-8V9A8,8,0,0,0,16,9V25A8,8,0,0,0,24,33ZM20,9a4,4,0,0,1,8,0V25a4,4,0,0,1-8,0Z"/><path d="M38,25a2,2,0,0,0-4,0,10,10,0,0,1-20,0,2,2,0,0,0-4,0A14,14,0,0,0,22,38.84V43H21a2,2,0,0,0,0,4h6a2,2,0,0,0,0-4H26V38.84A14,14,0,0,0,38,25Z"/></g></svg>';

  Widget _stopButton() {
    return widget.stopButton ??
        Container(
          width: widget.buttonSize,
          height: widget.buttonSize,
          decoration: BoxDecoration(
            color: Colors.red[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.stop_rounded,
              size: widget.buttonSize * .7,
              color: Colors.white,
            ),
          ),
        );
  }

  Widget _recordingIcon() {
    return widget.recordingIcon ??
        SvgPicture.string(
          micIcon,
          height: widget.buttonSize * .5,
          color: Colors.red[300],
        );
  }

  _showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Long press to start recording ...')),
    );
  }

  Text _recordingText() {
    return widget.recordingText ??
        Text(
          'Recording',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        );
  }

  List<Widget> _directionalUi() {
    return widget.direction == TextDirection.ltr
        ? [
            _recordingText(),
            SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: BouncingDots(color: AppColors.text, dotSize: 2, gap: 3),
            ),
            SizedBox(width: 24),
            Text(
              '${_minuteCounter < 10 ? '0$_minuteCounter' : _minuteCounter}:${_secondCounter < 10 ? '0$_secondCounter' : _secondCounter}',
              style: TextStyle(fontSize: 14, color: AppColors.text),
            ),
            SizedBox(width: 8),
            _recordingIcon(),
          ]
        : [
            _recordingIcon(),
            SizedBox(width: 8),
            Text(
              '${_minuteCounter < 10 ? '0$_minuteCounter' : _minuteCounter}:${_secondCounter < 10 ? '0$_secondCounter' : _secondCounter}',
              style: TextStyle(fontSize: 14, color: AppColors.text),
            ),
            SizedBox(width: 24),
            _recordingText(),
            SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: BouncingDots(color: AppColors.text, dotSize: 2, gap: 3),
            ),
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.barWidth,
      child: Stack(
        alignment: widget.direction == TextDirection.ltr
            ? Alignment.centerLeft
            : Alignment.centerRight,
        children: [
          AnimatedContainer(
            duration:
                widget.startAnimationDuration ?? Duration(milliseconds: 372),
            width: _recording ? widget.barWidth : 0,
            height: widget.barHeight,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.secondary,
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? widget.barHeight / 2,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: _showInfo
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: widget.direction == TextDirection.ltr
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: _directionalUi(),
                    ),
                  )
                : SizedBox(),
          ),
          _recording
              ? GestureDetector(onTap: _stopRecoding, child: _stopButton())
              : GestureDetector(
                  onTap: _showSnackBar,
                  onLongPress: _startRecording,
                  child: _startButton(),
                ),
        ],
      ),
    );
  }
}
