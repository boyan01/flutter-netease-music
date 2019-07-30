import 'dart:async';

import 'package:flutter/material.dart';

///used to build application widget
///[data] the data initial in [PageSplash]
typedef AppBuilder = Function(BuildContext context, List<dynamic> data);

///the splash screen of application
class PageSplash extends StatefulWidget {
  ///the data need init before application running
  final List<Future> futures;

  final AppBuilder builder;

  const PageSplash({Key key, @required this.futures, @required this.builder}) : super(key: key);

  @override
  _PageSplashState createState() => _PageSplashState();
}

class _PageSplashState extends State<PageSplash> {
  List _data;

  @override
  void initState() {
    super.initState();
    final start = DateTime.now().millisecondsSinceEpoch;
    Future.wait(widget.futures).then((data) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      debugPrint("flutter initial in : $duration");
      setState(() {
        _data = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return Container(color: const Color(0xFFd92e29));
    }
    return widget.builder(context, _data);
  }
}
