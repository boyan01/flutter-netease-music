import 'package:flutter/material.dart';

class CollectionEmpty extends StatelessWidget {
  final String message;

  const CollectionEmpty({Key key, @required this.message})
      : assert(message != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image(image: AssetImage("assets/no_copy_right.png")),
        SizedBox(height: 16),
        Text(
          "暂无收藏",
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.caption,
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
