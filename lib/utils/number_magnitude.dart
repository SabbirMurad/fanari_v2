part of '../utils.dart';

/// Converts a large number to a compact string with a magnitude suffix.
///
/// Examples: 1500 → "1.5K", 2000000 → "2M"
String format_number_magnitude(double value) {
  const suffixes = ['', 'K', 'M', 'B', 'T'];
  int magnitude = 0;

  while (value >= 1000 && magnitude < suffixes.length - 1) {
    value /= 1000;
    magnitude++;
  }

  final formatted = value % 1 == 0
      ? value.toInt().toString()
      : value.toStringAsFixed(1);

  return '$formatted${suffixes[magnitude]}';
}
