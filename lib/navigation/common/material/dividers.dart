import 'package:flutter/material.dart';

///在 widget 底部添加分割线
class DividerWrapper extends StatelessWidget {
  const DividerWrapper({
    super.key,
    this.child,
    this.indent = 0,
    this.extent = 0,
  });

  final Widget? child;

  final double indent;

  final double extent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        child!,
        SizedBox(height: extent),
        Divider(
          height: 0,
          indent: indent,
          color: Colors.black12,
        ),
      ],
    );
  }
}
