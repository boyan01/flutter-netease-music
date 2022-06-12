import 'package:flutter/cupertino.dart';
import '../component.dart';
import '../component/exceptions.dart';
import '../component/utils/time.dart';

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
