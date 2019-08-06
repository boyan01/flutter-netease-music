import 'package:flutter/material.dart';

import 'page_login_password.dart';
import 'page_login_phone.dart';

const pageLoginPhone = "loginWithPhone";

///
/// 需要的参数:
/// phone : 手机号
///
const pageLoginPassword = "loginPassword";

const pageRegister = "register";

///登录子流程
class LoginNavigator extends StatelessWidget {
  const LoginNavigator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Navigator(
        initialRoute: pageLoginPhone,
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(settings: settings, builder: (context) => _generatePage(settings));
        },
      ),
    );
  }

  Widget _generatePage(RouteSettings settings) {
    switch (settings.name) {
      case pageLoginPhone:
        return PageLoginWithPhone();
      case pageLoginPassword:
        final args = settings.arguments as Map<String, Object>;
        return PageLoginPassword(
          phone: args['phone'],
        );
    }
    return null;
  }
}
