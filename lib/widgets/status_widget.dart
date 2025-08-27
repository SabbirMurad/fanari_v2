// import 'package:fanari_v2/models/base/base.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// enum UrlType { Http, Https, Www, None }

// class StatusWidget extends StatefulWidget {
//   final String text;
//   final double width;
//   final double? truncatedLines;
//   final Color? textColor;
//   final Color? moreButtonColor;
//   final double? fontSize;
//   final FontWeight fontWeight;
//   final bool selectable;
//   final List<Mention> mentions;

//   const StatusWidget({
//     super.key,
//     required this.text,
//     required this.width,
//     required this.mentions,
//     this.selectable = true,
//     this.fontWeight = FontWeight.w400,
//     this.truncatedLines,
//     this.textColor,
//     this.moreButtonColor,
//     this.fontSize,
//   });

//   @override
//   State<StatusWidget> createState() => _StatusWidgetState();
// }

// class _StatusWidgetState extends State<StatusWidget> {
//   late String _fullText;
//   String? _truncatedText;
//   bool _needTruncate = false;
//   bool _showingMore = false;
//   late double _truncatedLines;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.truncatedLines == null) {
//       _truncatedLines = 1.7;
//     } else {
//       _truncatedLines = widget.truncatedLines!;
//     }

//     _fullText = widget.text;
//     _truncateText();
//   }

//   void _truncateText() {
//     final textPainter = TextPainter(
//       text: TextSpan(text: _fullText),
//       textDirection: TextDirection.ltr,
//     );
//     textPainter.layout();

//     var truncatedWordCount = 0;
//     var currentWidth = 0.0;
//     for (var word in _fullText.split(' ')) {
//       final wordPainter = TextPainter(
//         text: TextSpan(text: word),
//         textDirection: TextDirection.ltr,
//       );
//       wordPainter.layout();

//       final wordWidth = wordPainter.width;
//       if (currentWidth + wordWidth > widget.width * _truncatedLines * 1.8) {
//         break;
//       }

//       currentWidth +=
//           wordWidth + textPainter.width / _fullText.split(' ').length;
//       truncatedWordCount++;
//     }

//     if (truncatedWordCount < _fullText.split(' ').length) {
//       _truncatedText =
//           _fullText.split(' ').sublist(0, truncatedWordCount).join(' ');
//       _truncatedText = _truncatedText! + '...';

//       setState(() {
//         _truncatedText;
//         _needTruncate = true;
//       });
//     }
//   }

//   UrlType _urlType(String input) {
//     if (input.startsWith('https://') && input != 'https://') {
//       return UrlType.Https;
//     } else if (input.startsWith('http://') && input != 'http://') {
//       return UrlType.Http;
//     } else if (input.startsWith('www.') && input != 'www.') {
//       return UrlType.Www;
//     } else {
//       return UrlType.None;
//     }
//   }

//   _showUnsecureLinkGuide(Uri url) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.lock_open,
//                 size: 72,
//                 color: Colors.red[400],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Unsecure Link',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.tertiary,
//                   fontSize: 19,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Links starting with \'http://\' instate of \'https://\' are not secure. Opening these link might result in a security vulnerability or malware attack.',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.tertiary,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w400,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   _confirmUnsecureLinkOpen(Uri url) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             'Launch Unsecure Link?',
//             style: TextStyle(
//               color: Theme.of(context).colorScheme.tertiary,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Text(
//             'This link is not secure. Opening this link might result in a security vulnerability. Are you sure you want to open it?',
//             style: TextStyle(
//               color: Theme.of(context).colorScheme.tertiary,
//               fontSize: 13,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.tertiary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 launchUrl(
//                   url,
//                   mode: LaunchMode.externalApplication,
//                 );
//               },
//               child: const Text(
//                 'Open anyway',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             )
//           ],
//         );
//       },
//     );
//   }

//   Widget buildRichStatusText(
//     BuildContext context,
//     String status,
//     bool? truncated,
//   ) {
//     final textStyle = TextStyle(
//       color: widget.textColor ?? Theme.of(context).colorScheme.tertiary,
//       fontSize: widget.fontSize ?? 14,
//       fontWeight: widget.fontWeight,
//       height: 1.5,
//       letterSpacing: .3,
//     );

//     List<Map<String, dynamic>> result = [];

//     List<String> lines = status.split("\n");

//     for (String line in lines) {
//       List<String> words = line.split(" ");
//       String previousText = '';
//       bool urlFound = false;
//       for (String item in words) {
//         final urlType = _urlType(item);

//         switch (urlType) {
//           case UrlType.Http:
//             urlFound = true;
//             if (previousText.isNotEmpty) {
//               result.add({
//                 'isUrl': false,
//                 'data': previousText,
//               });
//               previousText = '';
//             }
//             result.add({
//               "isUrl": true,
//               "data": item,
//               'urlType': urlType,
//             });
//             break;
//           case UrlType.Https:
//             urlFound = true;
//             if (previousText.isNotEmpty) {
//               result.add({
//                 'isUrl': false,
//                 'data': previousText,
//               });
//               previousText = '';
//             }
//             result.add({
//               "isUrl": true,
//               "data": item,
//               'urlType': urlType,
//             });
//             break;
//           case UrlType.Www:
//             urlFound = true;
//             if (previousText.isNotEmpty) {
//               result.add({
//                 'isUrl': false,
//                 'data': previousText,
//               });
//               previousText = '';
//             }
//             result.add({
//               "isUrl": true,
//               "data": item,
//               'urlType': urlType,
//             });
//             break;
//           case UrlType.None:
//             if (urlFound) {
//               previousText += ' $item ';
//             } else {
//               previousText += '$item ';
//             }
//             urlFound = false;
//             break;
//         }
//       }
//       if (previousText.isNotEmpty) {
//         result.add({'isUrl': false, 'data': previousText});
//       }

//       result.add({'isUrl': false, 'data': '\n'});
//     }

//     result.removeLast();

//     final textSpan = TextSpan(
//       children: [
//         ...result.map((item) {
//           if (item['isUrl']) {
//             late Uri url;

//             if (item['urlType'] == UrlType.Http) {
//               url = Uri.parse(item['data']!);
//             } else if (item['urlType'] == UrlType.Https) {
//               url = Uri.parse(item['data']!);
//             } else if (item['urlType'] == UrlType.Www) {
//               url = Uri.parse('https://' + item['data']!);
//             }

//             final textSpan = TextSpan(
//               text: item['data'],
//               recognizer: TapGestureRecognizer()
//                 ..onTap = () {
//                   if (item['urlType'] == UrlType.Http) {
//                     _confirmUnsecureLinkOpen(url);
//                   } else {
//                     launchUrl(
//                       url,
//                       mode: LaunchMode.externalApplication,
//                     );
//                   }
//                 },
//               style: textStyle.copyWith(
//                 color: item['urlType'] == UrlType.Http
//                     ? Colors.red[400]
//                     : Color.fromARGB(255, 21, 75, 252),
//               ),
//             );

//             if (item['urlType'] == UrlType.Http) {
//               return TextSpan(
//                 children: [
//                   WidgetSpan(
//                     child: GestureDetector(
//                       onTap: () {
//                         _showUnsecureLinkGuide(url);
//                       },
//                       child: Icon(
//                         Icons.lock_open,
//                         size: 15,
//                         color: Colors.red[400],
//                       ),
//                     ),
//                   ),
//                   textSpan,
//                 ],
//               );
//             } else {
//               return textSpan;
//             }
//           } else {
//             return TextSpan(
//               text: item['data'],
//               style: textStyle,
//             );
//           }
//         }).toList(),
//         if (truncated != null)
//           truncated
//               ? TextSpan(
//                   text: 'Show More',
//                   recognizer: TapGestureRecognizer()
//                     ..onTap = () {
//                       setState(() {
//                         _showingMore = true;
//                       });
//                     },
//                   style: textStyle.copyWith(
//                     color: widget.moreButtonColor ??
//                         Theme.of(context).colorScheme.primary,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 )
//               : TextSpan(
//                   text: 'Show Less',
//                   recognizer: TapGestureRecognizer()
//                     ..onTap = () {
//                       setState(() {
//                         _showingMore = false;
//                       });
//                     },
//                   style: textStyle.copyWith(
//                     color: widget.moreButtonColor ??
//                         Theme.of(context).colorScheme.primary,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//       ],
//     );

//     return widget.selectable
//         ? SelectableText.rich(textSpan)
//         : RichText(text: textSpan);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return !_needTruncate
//         ? buildRichStatusText(
//             context,
//             _fullText,
//             null,
//           )
//         : _showingMore
//             ? buildRichStatusText(
//                 context,
//                 _fullText,
//                 false,
//               )
//             : buildRichStatusText(
//                 context,
//                 _truncatedText!,
//                 true,
//               );
//   }
// }
