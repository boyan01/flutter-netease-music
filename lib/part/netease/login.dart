import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

///登录状态
///在上层嵌套 LoginStateWidget 以监听用户登录状态
class LoginState extends Model {
  static const persistenceKey = 'neteaseLoginUser';

  ///根据BuildContext获取 [LoginState]
  static LoginState of(BuildContext context, {bool rebuildOnChange = true}) {
    return ScopedModel.of<LoginState>(context,
        rebuildOnChange: rebuildOnChange);
  }

  Future<Map> login(String phone, String password) async {
    final result = await neteaseRepository.login(phone, password);
    neteaseLocalData[persistenceKey] = result;
    _user = result;
    notifyListeners();
    return result;
  }

  void logout() {
    _user = null;
    notifyListeners();
    neteaseLocalData[persistenceKey] = null;
    neteaseRepository.logout();
  }

  LoginState() {
    scheduleMicrotask(() async {
      final login = await neteaseLocalData[persistenceKey];
      if (login != null) {
        _user = login;
        debugPrint('persistence user :${_user['account']['id']}');
        notifyListeners();
        //访问api，刷新登陆状态
        final state = await neteaseRepository.refreshLogin();
        if (!state) {
          _user = null;
          notifyListeners();
        }
      }
    });
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
