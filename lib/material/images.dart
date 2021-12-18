import 'package:flutter/material.dart';
import 'package:quiet/repository.dart';

///圆形图片
class RoundedImage extends StatelessWidget {
  const RoundedImage(this.url, {Key? key, this.size = 48}) : super(key: key);

  ///图片直径
  final double size;

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
        child: SizedBox.fromSize(
      size: Size.square(size),
      child: Image(
        height: size,
        width: size,
        image: CachedImage(url!),
      ),
    ));
  }
}
