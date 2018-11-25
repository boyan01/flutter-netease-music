import 'package:flutter/material.dart';
import 'package:quiet/repository/netease.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24, right: 24),
            children: <Widget>[
              SizedBox(
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
                    errorText: _loginFailedMessage,
                    hintText: "手机号码",
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                autofocus: false,
              ),
              SizedBox(
                height: 32,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (text) {
                  if (text.trim().isEmpty) {
                    return "密码不能为空";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    hintText: "密码",
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                autofocus: false,
              ),
              SizedBox(
                height: 32,
              ),
              Builder(builder: (context) {
                return FlatButton(
                    onPressed: () async {
                      if (Form.of(context).validate()) {
                        showDialog(
                            context: context, builder: _buildLoginDialog);
                        var result = await neteaseRepository.login(
                            _phoneController.text, _passwordController.text);
                        if (result["code"] == 200) {
                          var preference =
                              await SharedPreferences.getInstance();
                          preference.setString(
                              "login_user", json.encode(result));
                          Navigator.popUntil(context, ModalRoute.withName("/"));
                        } else {
                          setState(() {
                            _loginFailedMessage =
                                result["msg"] ?? "登录失败"; //login failed
                          });
                        }
                      }
                    },
                    child: Text("点击登录"));
              })
            ],
          ),
        ));
  }

  Widget _buildLoginDialog(BuildContext context) {
    return Dialog(
      child: Container(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
