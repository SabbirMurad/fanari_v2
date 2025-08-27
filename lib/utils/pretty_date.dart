part of '../utils.dart';

final months = [
  'Jan',
  'Fev',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String prettyDate(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

  int hour = date.hour;
  if (hour > 12) {
    hour -= 12;
  }

  if (hour == 0) {
    hour = 12;
  }

  return '${hour < 10 ? '0${hour}' : hour} : ${date.minute < 10 ? '0${date.minute}' : date.minute} ${date.hour < 12 ? 'AM' : 'PM'}, ${date.day} ${months[date.month - 1]} ${date.year - 2000}';
}

String timeAgo(DateTime timestamp, {bool showMinuteAndHour = false}) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);
  final String minuteAndHour =
      '${timestamp.hour < 12 ? timestamp.hour + 1 : timestamp.hour - 11}:${timestamp.minute} ${timestamp.hour < 12 ? 'AM' : 'PM'}';
  if (difference.inSeconds < 60) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  } else if (difference.inHours < 24) {
    if (difference.inHours < 4) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      if (now.day == timestamp.day) {
        return '$minuteAndHour';
      } else {
        return 'yesterday, ${minuteAndHour}';
      }
    }
  } else if (difference.inDays < 1) {
    return 'yesterday';
  } else {
    return '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year - 2000}${showMinuteAndHour ? ', $minuteAndHour' : ''}';
  }
}
