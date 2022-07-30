import 'package:flutter/cupertino.dart';
import 'package:netease_api/netease_api.dart';

import '../component.dart';
import '../component/exceptions.dart';
import '../component/utils/time.dart';

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
  String get timeStamp => getTimeStamp(inMilliseconds);
}
