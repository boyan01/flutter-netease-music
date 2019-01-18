import 'package:flutter/material.dart';

///登录状态
///在上层嵌套 LoginStateWidget 以监听用户登录状态
class LoginState extends InheritedWidget {
  ///根据BuildContext获取 [LoginState]
  static LoginState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(LoginState);
  }

  LoginState(this.user, {@required this.child}) : super(child: child);

  ///null -> not login
  ///not null -> login
  final Map<String, Object> user;

  final Widget child;

  @override
  bool updateShouldNotify(LoginState oldWidget) {
    var update = user != oldWidget.user;
    return update;
  }

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
