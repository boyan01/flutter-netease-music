import 'package:flutter/material.dart';

///在 widget 底部添加分割线
class DividerWrapper extends StatelessWidget {
  final Widget child;

  final double indent;

  final double extent;

  const DividerWrapper({Key key, this.child, this.indent = 0, this.extent = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          child,
          SizedBox(height: extent),
          Divider(height: 0, indent: indent,color: Colors.black12,)
        ],
      ),
    );
  }
}
