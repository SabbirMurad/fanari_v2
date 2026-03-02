part of '../utils.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Formats a Unix-ms [timestamp] as `"12 Jan 25, 02:45 PM"`.
String pretty_date(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

  int hour = date.hour % 12;
  if (hour == 0) hour = 12;

  final minute = date.minute.toString().padLeft(2, '0');
  final hour_str = hour.toString().padLeft(2, '0');
  final period = date.hour < 12 ? 'AM' : 'PM';
  final year = (date.year - 2000).toString().padLeft(2, '0');

  return '${date.day} ${_months[date.month - 1]} $year, $hour_str:$minute $period';
}

/// Returns a human-friendly relative time string (e.g. "just now", "3 min ago",
/// "yesterday, 08:30 AM") given a [timestamp] DateTime.
String time_ago(DateTime timestamp, {bool show_time = false}) {
  final now = DateTime.now();
  final diff = now.difference(timestamp);

  String clock_time(DateTime dt) {
    int h = dt.hour % 12;
    if (h == 0) h = 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';

  if (diff.inHours < 24) {
    if (diff.inHours < 4) {
      final label = diff.inHours == 1 ? 'hour' : 'hours';
      return '${diff.inHours} $label ago';
    }
    return now.day == timestamp.day
        ? clock_time(timestamp)
        : 'yesterday, ${clock_time(timestamp)}';
  }

  if (diff.inDays < 2) return 'yesterday';

  final year = (timestamp.year - 2000).toString().padLeft(2, '0');
  final base = '${timestamp.day} ${_months[timestamp.month - 1]} $year';
  return show_time ? '$base, ${clock_time(timestamp)}' : base;
}
