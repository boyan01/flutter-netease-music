import 'package:flutter/material.dart';

///配置一些通用用于测试的Widget上下文
class TestContext extends StatelessWidget {
  final Widget child;

  const TestContext({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(child: child),
    );
  }
}
