import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../netease.dart';
import '../objects/cellphone_existence_check.dart';

final loginApiProvider = Provider((ref) => LoginApi());

class LoginApi {
  Future<Result<CellphoneExistenceCheck>> checkPhoneExist(
      String phone, String countryCode) async {
    final result = await neteaseRepository!.doRequest(
      '/cellphone/existence/check',
      {'phone': phone, 'countrycode': countryCode},
    );
    if (result.isError) return result.asError!;
    final value = CellphoneExistenceCheck.fromJson(result.asValue!.value);
    return Result.value(value);
  }
}
