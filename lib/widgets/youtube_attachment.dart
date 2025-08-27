// import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:fanari_v2/models/view/youtube_attachment.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
// import 'package:fanari_v2/constants/credential.dart';
// import 'package:fanari_v2/utils.dart' as utils;
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

// class Youtube {
//   Youtube._constructor();

//   static Future<YoutubeAttachment?> metadata(attachment_id) async {
//     try {
//       final url = AppCredentials.getYoutubeBasicDataUrl(attachment_id);

//       final uri = Uri.parse(url);
//       Map<String, String> headers = {'Content-Type': 'application/json'};
//       var response = await http.get(uri, headers: headers);

//       if (response.statusCode == 200) {
//         return YoutubeAttachment.fromJson(
//           jsonDecode(response.body)['items'][0],
//         );
//       } else {
//         print('');
//         print('Error getting youtube attachment data');
//         print(response.statusCode);
//         print('');
//         return null;
//       }
//     } catch (e) {
//       print('');
//       print('Error getting youtube attachment data');
//       print(e);
//       print('');
//       return null;
//     }
//   }
// }

// class YoutubeAttachmentWidget extends StatefulWidget {
//   final double width;
//   final YoutubeAttachment model;
//   final Color? textColor;
//   final Color? sidebarColor;
//   final BorderRadius? sidebarBorderRadius;
//   final double sidebarWidth;
//   final Color? backgroundColor;

//   const YoutubeAttachmentWidget({
//     super.key,
//     required this.width,
//     required this.model,
//     this.textColor,
//     this.sidebarColor,
//     this.sidebarBorderRadius,
//     this.backgroundColor,
//     this.sidebarWidth = 8,
//   });

//   @override
//   State<YoutubeAttachmentWidget> createState() =>
//       _YoutubeAttachmentWidgetState();
// }

// class _YoutubeAttachmentWidgetState extends State<YoutubeAttachmentWidget> {
//   late double thumbnailWidth = widget.width - widget.sidebarWidth - 8;
//   late double thumbnailHeight =
//       widget.model.snippet.thumbnails.standard.height >
//               widget.model.snippet.thumbnails.standard.width
//           ? thumbnailWidth * (16 / 9)
//           : thumbnailWidth * (9 / 16);

//   late String _embedHtml = '''
//     <iframe width="${thumbnailWidth * MediaQuery.of(context).devicePixelRatio}" height="${thumbnailHeight * MediaQuery.of(context).devicePixelRatio}" src="https://www.youtube.com/embed/${widget.model.id}?autoplay=1&mute=1&rel=0&showinfo=0&modestbranding=0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
//                       ''';

//   @override
//   void initState() {
//     super.initState();
//   }

//   bool _isPlaying = false;
//   bool _loading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: widget.width,
//       color:
//           widget.backgroundColor ??
//           Theme.of(context).colorScheme.secondary.withValues(alpha: .2),
//       child: IntrinsicHeight(
//         child: Row(
//           children: [
//             Container(
//               width: widget.sidebarWidth,
//               decoration: BoxDecoration(
//                 color:
//                     widget.sidebarColor ??
//                     Theme.of(context).colorScheme.secondary,
//                 borderRadius:
//                     widget.sidebarBorderRadius ??
//                     BorderRadius.only(
//                       topLeft: Radius.circular(4),
//                       bottomLeft: Radius.circular(4),
//                     ),
//               ),
//             ),
//             SizedBox(width: 8),
//             Container(
//               width: thumbnailWidth,
//               padding: EdgeInsets.symmetric(vertical: 8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Image(
//                         image: AssetImage('assets/icons/youtube.png'),
//                         color: Colors.red,
//                         height: 28,
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         "YouTube",
//                         style: TextStyle(
//                           color:
//                               widget.textColor ??
//                               Theme.of(context).colorScheme.tertiary,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 4),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         launchUrl(
//                           Uri.parse(widget.model.url),
//                           mode: LaunchMode.externalApplication,
//                         );
//                       },
//                       child: Text(
//                         widget.model.snippet.title,
//                         style: TextStyle(
//                           color:
//                               widget.textColor ??
//                               Theme.of(context).colorScheme.tertiary,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 16,
//                           wordSpacing: 2,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       if (_isPlaying)
//                         Container(
//                           width: thumbnailWidth,
//                           height: thumbnailHeight,
//                           child: HtmlWidget(_embedHtml),
//                         ),
//                       if (!_isPlaying || _loading)
//                         CachedNetworkImage(
//                           imageUrl:
//                               widget.model.snippet.thumbnails.standard.url,
//                           width: thumbnailWidth,
//                           fit: BoxFit.cover,
//                           height: thumbnailHeight,
//                           placeholder: (context, url) {
//                             return Container(
//                               color: Theme.of(context).colorScheme.secondary,
//                               width: thumbnailWidth,
//                               height: thumbnailHeight,
//                             );
//                           },
//                           errorWidget:
//                               (context, url, error) => Icon(
//                                 Icons.error,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                         ),
//                       if (!_isPlaying && !_loading)
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             vertical: 8,
//                             horizontal: 18,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withValues(alpha: 0.5),
//                             borderRadius: BorderRadius.circular(24),
//                             border: Border.all(
//                               color: Colors.white.withValues(alpha: .3),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     _isPlaying = true;
//                                     _loading = true;
//                                   });

//                                   Future.delayed(
//                                     const Duration(milliseconds: 2500),
//                                     () {
//                                       setState(() {
//                                         _loading = false;
//                                       });
//                                     },
//                                   );
//                                 },
//                                 child: Icon(
//                                   Icons.play_arrow,
//                                   color: Colors.white,
//                                   size: 28,
//                                 ),
//                               ),
//                               SizedBox(width: 24),
//                               GestureDetector(
//                                 onTap: () {
//                                   launchUrl(
//                                     Uri.parse(widget.model.url),
//                                     mode: LaunchMode.externalApplication,
//                                   );
//                                 },
//                                 child: Icon(
//                                   Icons.open_in_browser_rounded,
//                                   color: Colors.white,
//                                   size: 28,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       if (_loading)
//                         Container(
//                           width: 52,
//                           height: 52,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 3.5,
//                           ),
//                         ),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         widget.model.snippet.channelTitle,
//                         style: TextStyle(
//                           color:
//                               widget.textColor ??
//                               Theme.of(context).colorScheme.tertiary,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 16,
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       Icon(
//                         Icons.verified,
//                         color: Theme.of(context).colorScheme.tertiary,
//                         size: 16,
//                       ),
//                       Spacer(),
//                       Icon(
//                         Icons.watch_later_outlined,
//                         size: 12,
//                         color:
//                             widget.textColor ??
//                             Theme.of(context).colorScheme.tertiary,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         widget.model.contentDetails.duration,
//                         style: TextStyle(
//                           color:
//                               widget.textColor ??
//                               Theme.of(context).colorScheme.tertiary,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       if (widget.model.statistics.viewCount != null)
//                         Text(
//                           '${utils.formatNumberMagnitude(widget.model.statistics.viewCount!.toDouble()).toString()} Views',
//                           style: TextStyle(
//                             color:
//                                 widget.textColor ??
//                                 Theme.of(context).colorScheme.tertiary,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 16,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
