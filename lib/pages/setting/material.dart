///
///
/// 一些 setting 用到的 Widget
///
///
import 'package:flutter/material.dart';

class SettingGroup extends StatelessWidget {
  const SettingGroup({Key? key, required this.title, required this.children})
      : super(key: key);

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
            mainAxisSize: MainAxisSize.min,
            children: children,
          )
        ],
      ),
    );
  }
}

class _SettingTitle extends StatelessWidget {
  const _SettingTitle({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, top: 6, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(color: Color.fromARGB(255, 175, 175, 175)),
      ),
    );
  }
}
