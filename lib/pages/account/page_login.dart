import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/part/part.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final GlobalKey<FormState> _formState = GlobalKey();

  TextEditingController _phoneController;
  TextEditingController _passwordController;

  String _loginFailedMessage;

  @override
  void initState() {
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("登录"),
        ),
        body: Form(
          key: _formState,
          autovalidate: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 100,
                ),
                TextFormField(
                  controller: _phoneController,
                  validator: (text) {
                    if (text.trim().isEmpty) {
                      return "手机号不能为空";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    errorText: _loginFailedMessage,
                    filled: true,
                    labelText: "手机号码",
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofocus: false,
                ),
                const SizedBox(
                  height: 24,
                ),
                PasswordField(
                  validator: (text) {
                    if (text.trim().isEmpty) {
                      return "密码不能为空";
                    }
                    return null;
                  },
                  controller: _passwordController,
                ),
                const SizedBox(
                  height: 24,
                ),
                RaisedButton(
                  onPressed: _onLogin,
                  child: Text("点击登录",
                      style: Theme.of(context).primaryTextTheme.body1),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ));
  }

  void _onLogin() async {
    if (_formState.currentState.validate()) {
      bool confirm = await showConfirmDialog(context,
          Text('即将与 http://127.0.0.1:3000 明文通信你的账号和密码\n务必确保网络环境可靠再进行登录操作！'));
      if (confirm != true) return;
      var result = await showLoaderOverlay(
          context,
          UserAccount.of(context, rebuildOnChange: false)
              .login(_phoneController.text, _passwordController.text));
      if (!result.isError) {
        Navigator.pop(context); //login succeed
      } else {
        showSimpleNotification(context, Text(result.asError.error.toString()));
      }
    }
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    this.validator,
    this.controller,
  });

  final FormFieldValidator<String> validator;
  final TextEditingController controller;

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscureText,
      validator: widget.validator,
      controller: widget.controller,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        filled: true,
        labelText: "密码",
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscureText ? '显示密码' : '隐藏密码',
          ),
        ),
      ),
    );
  }
}
