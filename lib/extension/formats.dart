import 'package:flutter/cupertino.dart';
import 'package:quiet/component.dart';
import 'package:quiet/component/exceptions.dart';
import 'package:quiet/component/utils/time.dart';

extension ErrorFormat on BuildContext {
  /// human-readable error message
  String formattedError(dynamic error) {
    if (error is NotLoginException) {
      return strings.errorNotLogin;
    }
    return '$error';
  }
}

extension DurationFormat on Duration {
  String get timeStamp => getTimeStamp(inMilliseconds);
}
