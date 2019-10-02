import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:music_player/music_player.dart';
import 'package:quiet/repository/netease.dart';

class BackgroundInterceptors {
  // 获取播放地址
  static Future<String> playUriInterceptor(String mediaId, String fallbackUri) async {
    final result = await neteaseRepository.getPlayUrl(int.parse(mediaId));
    if (result.isError) {
      return fallbackUri;
    }
    return result.asValue.value;
  }

  static Future<Uint8List> loadImageInterceptor(MediaDescription description) async {
    final ImageStream stream = CachedImage(description.iconUri.toString()).resolve(ImageConfiguration(
      size: const Size(150, 150),
      devicePixelRatio: WidgetsBinding.instance.window.devicePixelRatio,
    ));
    final image = Completer<ImageInfo>();
    stream.addListener(ImageStreamListener((info, a) {
      image.complete(info);
    }, onError: (dynamic exception, StackTrace stackTrace) {
      image.completeError(exception, stackTrace);
    }));
    final result = await image.future
        .then((image) => image.image.toByteData(format: ImageByteFormat.png))
        .then((byte) => byte.buffer.asUint8List())
        .timeout(const Duration(seconds: 10));
    debugPrint("load image for : ${description.title} ${result.length}");
    return result;
  }
}
