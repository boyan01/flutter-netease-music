///
///
/// 一些 setting 用到的 Widget
///
///
import 'package:flutter/material.dart';

class SettingGroup extends StatelessWidget {
  const SettingGroup({Key key, @required this.title, @required this.children}) : super(key: key);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SettingTitle(title: title),
          Column(
            children: children,
            mainAxisSize: MainAxisSize.min,
          )
        ],
      ),
    );
  }
}

class _SettingTitle extends StatelessWidget {
  final String title;

  const _SettingTitle({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        title,
        style: TextStyle(color: const Color.fromARGB(255, 175, 175, 175)),
      ),
      padding: const EdgeInsets.only(left: 8, top: 6, bottom: 6),
    );
  }
}
