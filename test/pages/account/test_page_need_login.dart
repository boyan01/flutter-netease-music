import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:quiet/pages/account/page_need_login.dart';

import '../../repository/mock.dart';
import '../../widget_test_context.dart';

void main() {
  testWidgets('test need login', (tester) async {
    final loginModel = MockLoginState();
    when(loginModel.isLogin).thenReturn(false);

    await tester.pumpWidget(TestContext(
      child: Provider.value(
          value: loginModel,
          child: PageNeedLogin(
            builder: (context) => Container(),
          )),
    ));
    expect(find.text('当前页面需要登陆'), findsOneWidget);
  });

  testWidgets('test has login', (tester) async {
    final loginModel = MockLoginState();
    when(loginModel.isLogin).thenReturn(true);

    await tester.pumpWidget(TestContext(
      child: Provider.value(
          value: loginModel,
          child: PageNeedLogin(
            builder: (context) => Container(child: Text('已登录')),
          )),
    ));
    expect(find.text('当前页面需要登陆'), findsNothing);
    expect(find.text('已登录'), findsOneWidget);
  });
}
