import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
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
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          title: Text("登录"),
        ),
        body: Form(
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
                Builder(
                  builder: (context) => RaisedButton(
                      onPressed: () async {
                        if (Form.of(context).validate()) {
                          showDialog(
                              context: context, builder: _buildLoginDialog);
                          Form.of(context);
                          var result = await LoginState.of(context,
                                  rebuildOnChange: false)
                              .login(_phoneController.text,
                                  _passwordController.text);
                          if (result["code"] == 200) {
                            Navigator.popUntil(
                                context, ModalRoute.withName("/"));
                          } else {
                            Navigator.pop(context); //dismiss dialog
                            setState(() {
                              _loginFailedMessage =
                                  result["msg"] ?? "登录失败"; //login failed
                            });
                          }
                        }
                      },
                      child: Text("点击登录")),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildLoginDialog(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
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
            semanticLabel: _obscureText ? 'show password' : 'hide password',
          ),
        ),
      ),
    );
  }
}
