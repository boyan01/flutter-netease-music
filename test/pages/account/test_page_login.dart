import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiet/pages/account/page_login.dart';

import '../../widget_test_context.dart';


void main() {
  //只输入手机号时,点击登录按钮
  testWidgets("login only with phone number", (tester) async {
    await tester.pumpWidget(TestContext(child: LoginPage()));
    await tester.pump();

    await tester.enterText(find
        .byType(TextFormField)
        .first, "12345678910");

    await tester.tap(find.widgetWithText(RaisedButton, "点击登录"));
    await tester.pump();

    expect(find.text("密码不能为空"), findsOneWidget);
  });
}
