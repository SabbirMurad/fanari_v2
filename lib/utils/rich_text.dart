part of '../utils.dart';

bool isUrl(String input) {
  return input.startsWith('https://');
}

Widget buildRichTextWithLinks(BuildContext context, String status) {
  List<Map<String, String>> result = [];

  List<String> split = status.split(" ");
  String normalText = '';
  bool urlFound = false;
  for (String item in split) {
    if (isUrl(item)) {
      urlFound = true;
      if (normalText.isNotEmpty) {
        result.add({'type': 'text', 'data': normalText});
        normalText = '';
      }
      result.add({"type": "link", "data": item});
    } else {
      if (urlFound) {
        normalText += ' $item ';
      } else {
        normalText += '$item ';
      }
      urlFound = false;
    }
  }
  if (normalText.isNotEmpty) {
    result.add({'type': 'text', 'data': normalText});
  }

  return RichText(
    text: TextSpan(
      children: result.map((item) {
        if (item['type'] == 'link') {
          return TextSpan(
            text: item['data'],
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(
                  Uri.parse(item['data']!),
                  mode: LaunchMode.externalApplication,
                );
              },
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          return TextSpan(
            text: item['data'],
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
      }).toList(),
    ),
  );
}
