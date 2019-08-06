import 'dart:async';

import 'package:quiet/repository/netease.dart';

///
///既然这些 api 在其他地方也用不到,那就干脆将 api 的实现移动到专属页面来吧
///感觉既方便维护,结构也更加清晰一些
///
class WelcomeRepository {
  ///检测手机号是否已存在
  static Future<Result<PhoneCheckResult>> checkPhoneExist(String phone) async {
    final result = await neteaseRepository.doRequest(
      '/cellphone/existence/check',
      {'phone': phone},
    );
    if (result.isError) return result.asError;
    final value = PhoneCheckResult.fromJsonMap(result.asValue.value);
    return Result.value(value);
  }
}

class PhoneCheckResult {
  final int exist;
  final String nickname;
  final bool hasPassword;

  bool get isExist => exist == 1;

  PhoneCheckResult.fromJsonMap(Map<String, dynamic> map)
      : exist = map["exist"],
        nickname = map["nickname"],
        hasPassword = map["hasPassword"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['exist'] = exist;
    data['nickname'] = nickname;
    data['hasPassword'] = hasPassword;
    return data;
  }
}
