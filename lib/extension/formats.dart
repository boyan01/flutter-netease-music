import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:netease_api/netease_api.dart';

import '../utils/exceptions.dart';
import 'strings.dart';

extension ErrorFormat on BuildContext {
  /// human-readable error message
  String formattedError(dynamic error) {
    if (error is NotLoginException) {
      return strings.errorNotLogin;
    } else if (error is RequestError) {
      return error.message;
    }
    return '$error';
  }
}

extension DurationFormat on Duration {
  String get timeStamp => inMilliseconds.toTimeStampString();
}

extension DateTimeFormat on DateTime {
  ///format milliseconds to local string
  String toFormattedString() {
    final now = DateTime.now();

    final diff = Duration(
      milliseconds: now.millisecondsSinceEpoch - millisecondsSinceEpoch,
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
    return DateFormat('y年M月d日').format(this);
  }
}

extension IntFormat on int {
  String toTimeStampString() {
    final seconds = (this / 1000).truncate();
    final minutes = (seconds / 60).truncate();

    final minutesStr = (minutes % 60).toString().padLeft(2, '0');
    final secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }
}
