import 'package:flutter/material.dart';
import 'package:mixin_logger/mixin_logger.dart';

import '../../utils/cache/cached_image.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.gaplessPlayback = false,
  });

  final String? url;

  final double? width;
  final double? height;

  final BoxFit fit;

  final bool gaplessPlayback;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return SizedBox(width: width, height: height);
    }

    Widget buildImage(ImageProvider image) => Image(
          image: image,
          height: height,
          width: width,
          fit: fit,
          gaplessPlayback: gaplessPlayback,
        );

    final image = CachedImage(url!);

    final scale = MediaQuery.of(context).devicePixelRatio;

    if (width != null || height != null) {
      return buildImage(
        ResizeImage(
          image,
          width: width == null ? null : (width! * scale).toInt(),
          height: height == null ? null : (height! * scale).toInt(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        var size = constraints.biggest;
        if (size.isFinite) {
          size = size * scale;
          return buildImage(
            ResizeImage(
              image,
              width: size.width.toInt(),
              height: size.height.toInt(),
            ),
          );
        }
        e('size is not finite: $size ${StackTrace.current}');
        return buildImage(image);
      },
    );
  }
}
