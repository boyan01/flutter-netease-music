import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/pages/account/page_login.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../repository/mock.dart';
import '../../widget_test_context.dart';

const _PHONE_NUMBER = '12345678910';
const _PASSWORD = 'abcdef';

void main() {
  //只输入手机号时,点击登录按钮
  testWidgets("login only with phone number", (tester) async {
    await tester.pumpWidget(TestContext(child: LoginPage()));
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).first, _PHONE_NUMBER);

    await tester.tap(find.widgetWithText(RaisedButton, "点击登录"));
    await tester.pump();

    expect(find.text("手机号不能为空"), findsNothing);
    expect(find.text("密码不能为空"), findsOneWidget);
  });

  testWidgets("login only with password", (tester) async {
    await tester.pumpWidget(TestContext(child: LoginPage()));
    await tester.pump();

    await tester.enterText(find.byType(PasswordField), _PASSWORD);

    await tester.tap(find.widgetWithText(RaisedButton, "点击登录"));
    await tester.pump();

    expect(find.text("手机号不能为空"), findsOneWidget);
    expect(find.text("密码不能为空"), findsNothing);
  });

  kNotificationDuration = Duration.zero;
  kNotificationSlideDuration = Duration.zero;

  final loginModel = MockLoginState();
  testWidgets("login", (tester) async {
    await tester.pumpWidget(TestContext(
        child: ScopedModel<UserAccount>(
      model: loginModel,
      child: LoginPage(),
    )));
    await tester.pump();

    when(loginModel.login(_PHONE_NUMBER, _PASSWORD))
        .thenAnswer((_) => Future.value({"code": 100}));

    await tester.enterText(find.byType(TextFormField).first, _PHONE_NUMBER);
    await tester.enterText(find.byType(PasswordField), _PASSWORD);
    await tester.pump();

    await tester.tap(find.widgetWithText(RaisedButton, "点击登录"));
    await tester.pump(const Duration(seconds: 1));

    verify(loginModel.login(_PHONE_NUMBER, _PASSWORD));
  });
}
