import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:music_player/music_player.dart';
import 'package:quiet/repository/netease.dart';
import 'package:quiet/model/model.dart';

import 'player.dart';

class BackgroundInterceptors {
  // 获取播放地址
  static Future<String> playUriInterceptor(String mediaId, String fallbackUri) async {
    final result = await neteaseRepository.getPlayUrl(int.parse(mediaId));
    if (result.isError) {
      return fallbackUri;
    }

    /// some devices do not support http request.
    return result.asValue.value.replaceFirst("http://", "https://");
  }

  static Future<Uint8List> loadImageInterceptor(MusicMetadata metadata) async {
    final ImageStream stream = CachedImage(metadata.iconUri.toString()).resolve(ImageConfiguration(
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
    debugPrint("load image for : ${metadata.title} ${result.length}");
    return result;
  }
}

class QuietPlayQueueInterceptor extends PlayQueueInterceptor {
  @override
  Future<List<MusicMetadata>> fetchMoreMusic(BackgroundPlayQueue queue, PlayMode playMode) async {
    if (queue.queueId == FM_PLAY_QUEUE_ID) {
      final musics = await neteaseRepository.getPersonalFmMusics();
      return musics.toMetadataList();
    }
    return super.fetchMoreMusic(queue, playMode);
  }
}
