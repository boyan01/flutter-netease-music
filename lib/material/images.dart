import 'package:flutter/material.dart';
import 'package:quiet/repository/netease.dart';

///圆形图片
class RoundedImage extends StatelessWidget {
  ///图片直径
  final double size;

  final String url;

  const RoundedImage(this.url, {Key key, this.size = 48}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
        child: SizedBox.fromSize(
      size: Size.square(size),
      child: Image(
        height: size,
        width: size,
        image: CachedImage(url),
      ),
    ));
  }
}
