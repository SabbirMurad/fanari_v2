// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:video_trimmer/video_trimmer.dart';

// class TrimmerView extends StatefulWidget {
//   final File file;
//   final Duration maxVideoLength;
//   final Function(String)? onTrim;

//   TrimmerView({
//     required this.file,
//     required this.maxVideoLength,
//     this.onTrim,
//   });

//   @override
//   _TrimmerViewState createState() => _TrimmerViewState();
// }

// class _TrimmerViewState extends State<TrimmerView> {
//   final Trimmer _trimmer = Trimmer();
//   bool showPlayControllers = true;

//   double _startValue = 0.0;
//   double _endValue = 0.0;

//   bool _isPlaying = false;
//   bool _progressVisibility = false;

//   Future<String?> _saveVideo() async {
//     setState(() {
//       _progressVisibility = true;
//     });

//     String? _value;

//     await _trimmer.saveTrimmedVideo(
//       startValue: _startValue,
//       endValue: _endValue,
//       onSave: (value) {
//         setState(() {
//           _progressVisibility = false;
//           _value = value;
//         });

//         if (value != null) {
//           widget.onTrim?.call(value);
//           Navigator.of(context).pop();
//         }
//       },
//     );

//     return _value;
//   }

//   void _loadVideo() {
//     _trimmer.loadVideo(videoFile: widget.file);
//   }

//   @override
//   void initState() {
//     super.initState();

//     _loadVideo();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Builder(
//         builder: (context) => Center(
//           child: Container(
//             padding: EdgeInsets.only(bottom: 30.0),
//             color: Colors.black,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.max,
//               children: <Widget>[
//                 Visibility(
//                   visible: _progressVisibility,
//                   child: LinearProgressIndicator(
//                     backgroundColor:
//                         Theme.of(context).colorScheme.primaryContainer,
//                   ),
//                 ),
//                 SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                     ),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           padding: const EdgeInsets.all(0.0),
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                           icon: Image(
//                             image:
//                                 const AssetImage('assets/icons/arrow_back.png'),
//                             width: 24,
//                             color: Colors.white,
//                           ),
//                         ),
//                         Spacer(),
//                         IconButton(
//                           onPressed: _progressVisibility
//                               ? null
//                               : () async {
//                                   _saveVideo();
//                                 },
//                           icon: Icon(
//                             Icons.done_rounded,
//                             size: 24,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Stack(
//                     children: [
//                       VideoViewer(
//                         trimmer: _trimmer,
//                       ),
//                       Align(
//                         alignment: Alignment.center,
//                         child: GestureDetector(
//                           onTap: () async {
//                             bool playbackState =
//                                 await _trimmer.videoPlaybackControl(
//                               startValue: _startValue,
//                               endValue: _endValue,
//                             );
//                             setState(() {
//                               _isPlaying = playbackState;
//                             });
//                           },
//                           child: Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .primary
//                                   .withValues(alpha:0.5),
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: Center(
//                               child: AnimatedCrossFade(
//                                 firstChild: const Icon(
//                                   Icons.play_arrow_rounded,
//                                   color: Colors.white,
//                                   size: 32,
//                                 ),
//                                 secondChild: const Icon(
//                                   Icons.pause,
//                                   color: Colors.white,
//                                   size: 32,
//                                 ),
//                                 crossFadeState: _isPlaying
//                                     ? CrossFadeState.showSecond
//                                     : CrossFadeState.showFirst,
//                                 duration: const Duration(milliseconds: 300),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: TrimViewer(
//                       trimmer: _trimmer,
//                       viewerHeight: 50.0,
//                       viewerWidth: 1.sw,
//                       maxVideoLength: widget.maxVideoLength,
//                       onChangeStart: (value) => _startValue = value,
//                       onChangeEnd: (value) => _endValue = value,
//                       onChangePlaybackState: (value) =>
//                           setState(() => _isPlaying = value),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
