import 'package:flutter/material.dart';
import 'package:quiet/repository/netease.dart';

///登录状态
///在上层嵌套 LoginStateWidget 以监听用户登录状态
class LoginState extends InheritedWidget {
  ///根据BuildContext获取 [LoginState]
  static LoginState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(LoginState);
  }

  LoginState(this.user, this.child) : super(child: child);

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
  int get userId {
    if (!isLogin) {
      throw Exception("当前没有用户登录");
    }
    Map<String, Object> account = user["account"];
    return account["id"];
  }
}

class LoginStateWidget extends StatefulWidget {
  LoginStateWidget(this.child);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginStateWidget> {
  Map<String, Object> user;

  @override
  void initState() {
    super.initState();
    neteaseRepository.user.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    setState(() {
      this.user = neteaseRepository.user.value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    neteaseRepository.user.removeListener(_onUserChanged);
  }

  @override
  Widget build(BuildContext context) {
    return LoginState(user, widget.child);
  }
}