// import 'dart:async';
// import 'dart:io';

// import 'package:fanari_v2/widgets/bouncing_three_dot.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';
// import 'package:path_provider/path_provider.dart';

// class SocialVoiceRecorder extends StatefulWidget {
//   final void Function()? onRecordStart;
//   final void Function(File audioFile, String path)? onRecordEnd;

//   final Duration? startAnimationDuration;
//   final Widget? startButton;
//   final Widget? stopButton;
//   final Widget? recordingIcon;
//   final double? fullWidth;
//   final double? height;
//   final Color? backgroundColor;
//   final double? borderRadius;
//   final Text? recordingText;
//   final bool boxShadow;
//   final TextDirection direction;

//   const SocialVoiceRecorder({
//     super.key,
//     this.onRecordStart,
//     this.onRecordEnd,
//     this.startButton,
//     this.stopButton,
//     this.fullWidth,
//     this.height,
//     this.backgroundColor,
//     this.borderRadius,
//     this.recordingText,
//     this.recordingIcon,
//     this.startAnimationDuration,
//     this.boxShadow = true,
//     this.direction = TextDirection.rtl,
//   });

//   @override
//   State<SocialVoiceRecorder> createState() => _SocialVoiceRecorderState();
// }

// class _SocialVoiceRecorderState extends State<SocialVoiceRecorder> {
//   bool _isAcceptedPermission = false;
//   AudioRecorder recordMp3 = AudioRecorder();
//   String? _filePath;
//   int _secondCounter = 0;
//   int _minuteCounter = 0;
//   Timer? _timer;
//   bool _recording = false;
//   bool _showInfo = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermission();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     recordMp3.stop();
//     super.dispose();
//   }

//   _checkPermission() async {
//     final status = await Permission.microphone.status;
//     if (status.isGranted) {
//       final result = await Permission.storage.request();
//       if (result.isGranted) {
//         _isAcceptedPermission = true;
//       }
//     }
//   }

//   void _startTimer() {
//     setState(() {
//       _secondCounter = 0;
//       _minuteCounter = 0;
//     });

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_secondCounter == 59) {
//           _secondCounter = 0;
//           _minuteCounter++;
//         } else {
//           _secondCounter++;
//         }
//       });
//     });
//   }

//   void _stopTimer() {
//     setState(() {
//       _secondCounter = 0;
//       _minuteCounter = 0;
//     });

//     _timer?.cancel();
//   }

//   Future<String> _getFilePath() async {
//     String _sdPath = "";
//     Directory tempDir = await getTemporaryDirectory();
//     _sdPath = tempDir.path;
//     var d = Directory(_sdPath);
//     if (!d.existsSync()) {
//       d.createSync(recursive: true);
//     }
//     DateTime now = DateTime.now();
//     String convertedDateTime =
//         "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
//     convertedDateTime = convertedDateTime.replaceAll(":", ".");
//     String storagePath = _sdPath + "/" + convertedDateTime + '.m4a';
//     _filePath = storagePath;
//     return storagePath;
//   }

//   _startRecording() async {
//     if (!_isAcceptedPermission) {
//       await Permission.microphone.request();
//       await Permission.manageExternalStorage.request();
//       await Permission.storage.request();
//       _isAcceptedPermission = true;
//     } else {
//       String recordFilePath = await _getFilePath();
//       setState(() {
//         _recording = true;
//       });

//       Future.delayed(
//         (widget.startAnimationDuration ?? const Duration(milliseconds: 372)) -
//             const Duration(milliseconds: 72),
//         () {
//           setState(() {
//             _showInfo = true;
//           });
//           _startTimer();
//           recordMp3.start(
//             const RecordConfig(
//               encoder: AudioEncoder.aacLc,
//               bitRate: 128000, // Increase for better quality
//               sampleRate: 44100,
//               noiseSuppress: true,
//               androidConfig: AndroidRecordConfig(muteAudio: true),
//             ),
//             path: recordFilePath,
//           );

//           widget.onRecordStart?.call();
//         },
//       );
//     }
//   }

//   _stopRecoding() {
//     recordMp3.stop();
//     _stopTimer();

//     setState(() {
//       _recording = false;
//     });
//     widget.onRecordEnd?.call(File.fromUri(Uri(path: _filePath!)), _filePath!);

//     Future.delayed(const Duration(milliseconds: 72), () {
//       if (mounted) {
//         setState(() {
//           _showInfo = false;
//         });
//       }
//     });
//   }

//   Widget _startButton() {
//     double iconHeight = widget.height != null ? widget.height! * 1.15 : 48;
//     return widget.startButton ??
//         Container(
//           width: iconHeight,
//           height: iconHeight,
//           decoration: BoxDecoration(
//             color: Colors.blue[300],
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//             child: Icon(
//               Icons.mic_none_rounded,
//               size: iconHeight * .7,
//               color: Colors.white,
//             ),
//           ),
//         );
//   }

//   Widget _stopButton() {
//     return widget.stopButton ??
//         Container(
//           width: widget.height != null ? widget.height! * 1.15 : 48,
//           height: widget.height != null ? widget.height! * 1.15 : 48,
//           decoration: BoxDecoration(
//             color: Colors.red[300],
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//             child: Icon(
//               Icons.stop_rounded,
//               size: widget.height != null ? widget.height! * .7 : 48,
//               color: Colors.white,
//             ),
//           ),
//         );
//   }

//   Widget _recordingIcon() {
//     return widget.recordingIcon ??
//         Icon(
//           Icons.mic_none_rounded,
//           size: widget.height != null ? widget.height! * .6 : 48,
//           color: Colors.red[300],
//         );
//   }

//   _showSnackBar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Long press to start recording ...')),
//     );
//   }

//   Text _recordingText() {
//     return widget.recordingText ??
//         Text(
//           'Recording',
//           style: TextStyle(
//             color: Theme.of(context).colorScheme.tertiary,
//             fontSize: 14,
//             fontWeight: FontWeight.w400,
//           ),
//         );
//   }

//   List<Widget> _directionalUi() {
//     return widget.direction == TextDirection.ltr
//         ? [
//           _recordingText(),
//           SizedBox(width: 4),
//           Padding(
//             padding: const EdgeInsets.only(top: 12),
//             child: BouncingDots(
//               color: Theme.of(context).colorScheme.tertiary,
//               dotSize: 2,
//               gap: 3,
//             ),
//           ),
//           SizedBox(width: 24),
//           Text(
//             '${_minuteCounter < 10 ? '0$_minuteCounter' : _minuteCounter}:${_secondCounter < 10 ? '0$_secondCounter' : _secondCounter}',
//             style: TextStyle(
//               fontSize: 14,
//               color: Theme.of(context).colorScheme.tertiary,
//             ),
//           ),
//           SizedBox(width: 8),
//           _recordingIcon(),
//         ]
//         : [
//           _recordingIcon(),
//           SizedBox(width: 8),
//           Text(
//             '${_minuteCounter < 10 ? '0$_minuteCounter' : _minuteCounter}:${_secondCounter < 10 ? '0$_secondCounter' : _secondCounter}',
//             style: TextStyle(
//               fontSize: 14,
//               color: Theme.of(context).colorScheme.tertiary,
//             ),
//           ),
//           SizedBox(width: 24),
//           _recordingText(),
//           SizedBox(width: 4),
//           Padding(
//             padding: const EdgeInsets.only(top: 12),
//             child: BouncingDots(
//               color: Theme.of(context).colorScheme.tertiary,
//               dotSize: 2,
//               gap: 3,
//             ),
//           ),
//         ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     double padding = widget.borderRadius ?? (widget.height ?? 48) / 2.6;
//     return Container(
//       width: widget.fullWidth ?? double.infinity,
//       child: Stack(
//         alignment:
//             widget.direction == TextDirection.ltr
//                 ? Alignment.centerLeft
//                 : Alignment.centerRight,
//         children: [
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: AnimatedContainer(
//               duration:
//                   widget.startAnimationDuration ?? Duration(milliseconds: 372),
//               width: _recording ? (widget.fullWidth ?? double.infinity) : 0,
//               height: widget.height ?? 48,
//               decoration: BoxDecoration(
//                 color: widget.backgroundColor ?? Colors.white,
//                 borderRadius: BorderRadius.circular(
//                   widget.borderRadius ?? (widget.height ?? 48) / 2,
//                 ),
//                 boxShadow: [
//                   if (widget.boxShadow)
//                     BoxShadow(
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.tertiary.withValues(alpha: .15),
//                       blurRadius: 10,
//                       offset: Offset(0, 2),
//                     ),
//                 ],
//               ),
//               padding: EdgeInsets.symmetric(horizontal: padding),
//               child:
//                   _showInfo
//                       ? Row(
//                         mainAxisAlignment:
//                             widget.direction == TextDirection.ltr
//                                 ? MainAxisAlignment.end
//                                 : MainAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.max,
//                         children: _directionalUi(),
//                       )
//                       : SizedBox(),
//             ),
//           ),
//           _recording
//               ? GestureDetector(onTap: _stopRecoding, child: _stopButton())
//               : GestureDetector(
//                 onTap: _showSnackBar,
//                 onLongPress: _startRecording,
//                 child: _startButton(),
//               ),
//         ],
//       ),
//     );
//   }
// }
