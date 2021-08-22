import 'package:flutter/material.dart';

class CollectionEmpty extends StatelessWidget {
  const CollectionEmpty({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Image(image: AssetImage("assets/no_copy_right.png")),
        const SizedBox(height: 16),
        const Text(
          "暂无收藏",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.caption,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
