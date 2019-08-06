import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/material/dialogs.dart';
import 'package:quiet/pages/account/account.dart';

import 'page_welcome.dart';

///登录流程: 密码输入
class PageLoginPassword extends StatefulWidget {
  ///手机号
  final String phone;

  const PageLoginPassword({Key key, @required this.phone}) : super(key: key);

  @override
  _PageLoginPasswordState createState() => _PageLoginPasswordState();
}

class _PageLoginPasswordState extends State<PageLoginPassword> {
  final _inputController = TextEditingController();

  @override
  void initState() {
    _inputController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('手机号登录')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: TextField(
                controller: _inputController,
                obscureText: true,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(hintText: '请输入密码'),
              ),
            ),
            StretchButton(
              text: '登录',
              primary: false,
              onTap: _doLogin,
            ),
          ],
        ),
      ),
    );
  }

  void _doLogin() async {
    final password = _inputController.text;
    if (password.isEmpty) {
      toast('请输入密码');
      return;
    }
    final account = UserAccount.of(context, rebuildOnChange: false);
    final result = await showLoaderOverlay(context, account.login(widget.phone, password));
    if (result.isValue) {
      //退出登录流程,表示我们登录成功了
      Navigator.of(context, rootNavigator: true).pop(true);
    } else {
      toast('登录失败:${result.asError.error}');
    }
  }
}
