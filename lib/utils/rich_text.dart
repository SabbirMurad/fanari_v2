part of '../utils.dart';

bool _is_url(String input) =>
    input.startsWith('https://') ||
    input.startsWith('http://') ||
    input.startsWith('www.');

/// Builds a [RichText] widget where URL tokens inside [text] are rendered as
/// tappable links and everything else is rendered as plain text.
Widget build_rich_text_with_links(BuildContext context, String text) {
  final tokens = text.split(' ');
  final spans = <TextSpan>[];
  final buffer = StringBuffer();

  void flush_buffer() {
    if (buffer.isNotEmpty) {
      spans.add(TextSpan(
        text: buffer.toString(),
        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
      ));
      buffer.clear();
    }
  }

  for (int i = 0; i < tokens.length; i++) {
    final token = tokens[i];
    if (_is_url(token)) {
      flush_buffer();
      spans.add(TextSpan(
        text: token,
        recognizer: TapGestureRecognizer()
          ..onTap = () => launchUrl(
                Uri.parse(token),
                mode: LaunchMode.externalApplication,
              ),
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ));
      if (i < tokens.length - 1) buffer.write(' ');
    } else {
      buffer.write(i == 0 ? token : ' $token');
    }
  }

  flush_buffer();

  return RichText(text: TextSpan(children: spans));
}
