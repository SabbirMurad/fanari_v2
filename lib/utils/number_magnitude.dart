part of '../utils.dart';

String formatNumberMagnitude(double value) {
  List<String> suffixes = ["", "K", "M", "B", "T"];
  int magnitude = 0;

  while (value >= 1000) {
    value = value / 1000;
    magnitude++;
  }

  String formattedValue =
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
  return '$formattedValue${suffixes[magnitude]}';
}