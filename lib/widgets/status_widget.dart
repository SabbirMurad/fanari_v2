import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class StatusWidget extends StatefulWidget {
  final String text;
  final double width;
  final double? truncatedLines;
  final Color? textColor;
  final Color? moreButtonColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final bool selectable;
  final List<MentionModel> mentions;

  const StatusWidget({
    super.key,
    required this.text,
    required this.width,
    required this.mentions,
    this.selectable = true,
    this.fontWeight = FontWeight.w400,
    this.truncatedLines,
    this.textColor,
    this.moreButtonColor,
    this.fontSize,
  });

  @override
  State<StatusWidget> createState() => _StatusWidgetState();
}

class _StatusWidgetState extends State<StatusWidget> {
  late String _fullText;
  String? _truncatedText;
  bool _needTruncate = false;
  bool _showingMore = false;
  late double _truncatedLines;

  @override
  void initState() {
    super.initState();
    if (widget.truncatedLines == null) {
      _truncatedLines = 3;
    } else {
      _truncatedLines = widget.truncatedLines!;
    }

    _fullText = widget.text;
    _truncateText();
  }

  void _truncateText() {
    final textPainter = TextPainter(
      text: TextSpan(text: _fullText),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    var truncatedWordCount = 0;
    var currentWidth = 0.0;
    for (var word in _fullText.split(' ')) {
      final wordPainter = TextPainter(
        text: TextSpan(text: word),
        textDirection: TextDirection.ltr,
      );
      wordPainter.layout();

      final wordWidth = wordPainter.width;
      if (currentWidth + wordWidth > widget.width * _truncatedLines * 1.8) {
        break;
      }

      currentWidth +=
          wordWidth + textPainter.width / _fullText.split(' ').length;
      truncatedWordCount++;
    }

    if (truncatedWordCount < _fullText.split(' ').length) {
      _truncatedText = _fullText
          .split(' ')
          .sublist(0, truncatedWordCount)
          .join(' ');
      _truncatedText = _truncatedText! + '...';

      setState(() {
        _truncatedText;
        _needTruncate = true;
      });
    }
  }

  _showUnsecureLinkGuide(Uri url) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_open, size: 72, color: Colors.red[400]),
              const SizedBox(height: 12),
              Text(
                'Unsecure Link',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Links starting with \'http://\' instate of \'https://\' are not secure. Opening these link might result in a security vulnerability or malware attack.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  _confirmUnsecureLinkOpen(Uri url) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Launch Unsecure Link?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'This link is not secure. Opening this link might result in a security vulnerability. Are you sure you want to open it?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                launchUrl(url, mode: LaunchMode.externalApplication);
              },
              child: const Text(
                'Open anyway',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<StatusTextMap> _splitTextWithMentionsAndUrls(
    String input,
    List<MentionModel> mentions,
  ) {
    // Matches http://, https://, www.
    final urlRegex = RegExp(
      r'((https?:\/\/[^\s]+)|(www\.[^\s]+))',
      caseSensitive: false,
    );

    // Collect all URL and text ranges
    final List<Map<String, dynamic>> tokens = [];

    int lastIndex = 0;
    for (final match in urlRegex.allMatches(input)) {
      if (match.start > lastIndex) {
        tokens.add({
          'type': StatusTextType.normalText,
          'start': lastIndex,
          'end': match.start,
        });
      }

      final urlText = input.substring(match.start, match.end);
      StatusTextType urlType = StatusTextType.secureUrl;
      if (urlText.startsWith('http://')) {
        urlType = StatusTextType.unsecureUrl;
      }

      tokens.add({'type': urlType, 'start': match.start, 'end': match.end});

      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      tokens.add({
        'type': StatusTextType.normalText,
        'start': lastIndex,
        'end': input.length,
      });
    }

    // Sort mentions by index
    mentions.sort((a, b) => a.start_index.compareTo(b.start_index));

    final List<StatusTextMap> finalTokens = [];
    for (var token in tokens) {
      int start = token['start'];
      int end = token['end'];
      StatusTextType type = token['type'];

      // Only split mentions if this is text (not url)
      if (type != StatusTextType.normalText) {
        finalTokens.add(
          StatusTextMap(type: type, text: input.substring(start, end)),
        );
        continue;
      }

      int cursor = start;
      for (var mention in mentions) {
        if (mention.start_index >= end || mention.end_index <= start) {
          continue; // mention outside this token
        }

        if (cursor < mention.start_index) {
          finalTokens.add(
            StatusTextMap(
              type: StatusTextType.normalText,
              text: input.substring(cursor, mention.start_index),
            ),
          );
        }

        finalTokens.add(
          StatusTextMap(
            type: StatusTextType.mention,
            text: input.substring(mention.start_index, mention.end_index),
            username: mention.username,
          ),
        );

        cursor = mention.end_index;
      }

      if (cursor < end) {
        finalTokens.add(
          StatusTextMap(
            type: StatusTextType.normalText,
            text: input.substring(cursor, end),
          ),
        );
      }
    }

    return finalTokens.where((t) => t.text.isNotEmpty).toList();
  }

  Widget buildRichStatusText(
    BuildContext context,
    String text,
    bool? truncated,
  ) {
    final textStyle = TextStyle(
      color: widget.textColor ?? AppColors.text,
      fontSize: widget.fontSize ?? 13.sp,
      fontWeight: widget.fontWeight,
      height: 1.6,
      letterSpacing: .3,
    );

    List<StatusTextMap> textMap = _splitTextWithMentionsAndUrls(
      text,
      widget.mentions,
    );


    final textSpan = TextSpan(
      children: [
        ...textMap.map((item) {
          if (item.type == StatusTextType.normalText) {
            return TextSpan(text: item.text, style: textStyle);
          }

          if (item.type == StatusTextType.mention) {
            return TextSpan(
              text: item.text,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  AppRoutes.push('/profile/${item.username}');
                },
              style: textStyle.copyWith(color: AppColors.primary),
            );
          }

          late Uri url;

          if (item.text.startsWith('www.')) {
            url = Uri.parse('https://' + item.text);
          } else {
            url = Uri.parse(item.text);
          }

          final textSpan = TextSpan(
            text: item.text,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (item.type == StatusTextType.unsecureUrl) {
                  _confirmUnsecureLinkOpen(url);
                } else {
                  launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            style: textStyle.copyWith(
              color: item.type == StatusTextType.unsecureUrl
                  ? Colors.red[400]
                  : AppColors.primary,
            ),
          );

          if (item.type == StatusTextType.secureUrl) {
            return textSpan;
          }

          return TextSpan(
            children: [
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {
                    _showUnsecureLinkGuide(url);
                  },
                  child: Icon(
                    Icons.lock_open,
                    size: 15,
                    color: Colors.red[400],
                  ),
                ),
              ),
              textSpan,
            ],
          );
        }).toList(),
        if (truncated != null)
          truncated
              ? TextSpan(
                  text: ' Show More',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _showingMore = true;
                      });
                    },
                  style: textStyle.copyWith(
                    color:
                        widget.moreButtonColor ??
                        Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : TextSpan(
                  text: ' Show Less',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _showingMore = false;
                      });
                    },
                  style: textStyle.copyWith(
                    color:
                        widget.moreButtonColor ??
                        Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ],
    );

    return widget.selectable
        ? SelectableText.rich(textSpan)
        : RichText(text: textSpan);
  }

  @override
  Widget build(BuildContext context) {
    return !_needTruncate
        ? buildRichStatusText(context, _fullText, null)
        : _showingMore
        ? buildRichStatusText(context, _fullText, false)
        : buildRichStatusText(context, _truncatedText!, true);
  }
}

enum StatusTextType { normalText, secureUrl, mention, unsecureUrl }

class StatusTextMap {
  final StatusTextType type;
  final String text;
  final String? username;

  const StatusTextMap({required this.text, required this.type, this.username});
}
