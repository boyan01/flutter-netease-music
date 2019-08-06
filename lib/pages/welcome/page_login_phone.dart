import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/material/dialogs.dart';
import 'package:quiet/pages/welcome/login_sub_navigation.dart';

import '_repository.dart';

class PageLoginWithPhone extends StatefulWidget {
  @override
  _PageLoginWithPhoneState createState() => _PageLoginWithPhoneState();
}

class _PageLoginWithPhoneState extends State<PageLoginWithPhone> {
  final _phoneInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneInputController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('手机号登录'),
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).maybePop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 30),
            Text(
              '未注册手机号登陆后将自动创建账号',
              style: Theme.of(context).textTheme.caption,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: _PhoneInput(controller: _phoneInputController),
            ),
            _ButtonNextStep(controller: _phoneInputController),
          ],
        ),
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  final TextEditingController controller;

  _PhoneInput({Key key, this.controller}) : super(key: key);

  Color _textColor(BuildContext context) {
    if (controller.text.isEmpty) {
      return Theme.of(context).disabledColor;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.body1.copyWith(
          fontSize: 16,
          color: _textColor(context),
        );
    return DefaultTextStyle(
      style: style,
      child: TextField(
        controller: controller,
        style: style,
        maxLength: 11,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.all(12),
            child: Text('+86'),
          ),
        ),
      ),
    );
  }
}

class _ButtonNextStep extends StatelessWidget {
  final TextEditingController controller;

  const _ButtonNextStep({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textColor: Theme.of(context).primaryTextTheme.body1.color,
      child: Text('下一步'),
      onPressed: () async {
        final text = controller.text;
        if (text.isEmpty) {
          toast('请输入手机号');
          return;
        }
        if (text.length < 11) {
          toast('请输入11位手机号码');
          return;
        }
        final result = await showLoaderOverlay(context, WelcomeRepository.checkPhoneExist(text));
        if (result.isError) {
          toast(result.asError.error.toString());
        }
        final value = result.asValue.value;
        if (!value.isExist) {
          toast('注册流程开发未完成,欢迎贡献代码...');
          return;
        }
        if (!value.hasPassword) {
          toast('无密码登录流程的开发未完成,欢迎提出PR贡献代码...');
          return;
        }
        Navigator.pushNamed(context, pageLoginPassword, arguments: {'phone': text});
      },
    );
  }
}
