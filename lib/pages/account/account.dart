import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

///登录状态
class UserAccount extends Model {
  ///get user info from persistence data
  static Future<Map> getPersistenceUser() async {
    return await neteaseLocalData[persistenceKey];
  }

  static const persistenceKey = 'neteaseLoginUser';

  ///根据BuildContext获取 [UserAccount]
  static UserAccount of(BuildContext context, {bool rebuildOnChange = true}) {
    return ScopedModel.of<UserAccount>(context, rebuildOnChange: rebuildOnChange);
  }

  Future<Result<Map>> login(String phone, String password) async {
    final result = await neteaseRepository.login(phone, password);
    if (result.isValue) {
      final json = result.asValue.value;
      neteaseLocalData[persistenceKey] = json;
      _user = json;
      notifyListeners();
    }
    return result;
  }

  void logout() {
    _user = null;
    notifyListeners();
    neteaseLocalData[persistenceKey] = null;
    neteaseRepository.logout();
  }

  UserAccount(Map user) {
    if (user != null) {
      _user = user;
      debugPrint('persistence user :${_user['account']['id']}');

      //访问api，刷新登陆状态
      neteaseRepository.refreshLogin()?.then((needLogin) {
        if (needLogin) {
          logout();
        }
      }, onError: () {
        debugPrint("refresh login status failed");
      });
    }
  }

  Map _user;

  ///null -> not login
  ///not null -> login
  Map get user => _user;

  ///当前是否已登录
  bool get isLogin {
    return user != null;
  }

  ///当前登录用户的id
  ///null if not login
  int get userId {
    if (!isLogin) {
      return null;
    }
    Map<String, Object> account = user["account"];
    return account["id"];
  }
}
