part of '../../utils.dart';

extension StringCasingExtension on String {
  String capitalize() {
    return this.split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
  }
}