import 'package:intl/intl.dart';

///format milliseconds to local string
String getFormattedTime(int milliseconds) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final now = DateTime.now();

  final diff = Duration(
    milliseconds: now.millisecondsSinceEpoch - dateTime.millisecondsSinceEpoch,
  );
  if (diff.inMinutes < 1) {
    return '刚刚';
  }
  if (diff.inMinutes <= 60) {
    return '${diff.inMinutes}分钟前';
  }
  if (diff.inHours <= 24) {
    return '${diff.inHours}小时前';
  }
  if (diff.inDays <= 5) {
    return '${diff.inDays}天前';
  }
  return DateFormat('y年M月d日').format(dateTime);
}

///format milliseconds to time stamp like "06:23", which
///means 6 minute 23 seconds
String getTimeStamp(int milliseconds) {
  final seconds = (milliseconds / 1000).truncate();
  final minutes = (seconds / 60).truncate();

  final minutesStr = (minutes % 60).toString().padLeft(2, '0');
  final secondsStr = (seconds % 60).toString().padLeft(2, '0');

  return '$minutesStr:$secondsStr';
}
