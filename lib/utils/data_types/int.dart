part of '../../utils.dart';

extension IntExtension on int {
  /// Returns the square of this integer.
  int get squared => this * this;

  /// Returns true if this integer falls within [min] and [max] (inclusive).
  bool is_between(int min, int max) => this >= min && this <= max;
}
