part of '../../utils.dart';

extension StringExtension on String {
  /// Returns the string with every word's first letter capitalised.
  ///
  /// Example: `'hello world'.capitalize()` → `'Hello World'`
  String capitalize() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  /// Returns true if the string looks like a URL.
  bool get is_url =>
      startsWith('https://') ||
      startsWith('http://') ||
      startsWith('www.');
}
