import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quiet/model/model.dart';
import 'package:quiet/part/part_player_service.dart';

MethodChannel _channel = MethodChannel("tech.soit.quiet/notification");

QuietNotification notification = QuietNotification._();

///use to create a notification for android
///has no effect for ios
class QuietNotification {

  QuietNotification._() {
    _initialize();
  }

  void _initialize() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "playPrevious":
          quiet.playPrevious();
          break;
        case "playOrPause":
          if (!quiet.value.state.isPlaying) {
            quiet.play();
          } else {
            quiet.pause();
          }
          break;
        case "playNext":
          quiet.playNext();
          break;
        case "quiet":
          quiet.quiet();
          break;
        case "like":
          debugPrint("like current music");
          break;
        case "dislike":
          debugPrint("dislike current music");
          break;
      }
    });
  }

  ///update notification by music
  Future<void> update(Music music, bool isPlaying) {
    assert(music != null);
    //TODO add image
//    void onImageAvailable(ImageInfo image, bool synchronousCall) {
//      image.image.toByteData().then((bytes) async {
//        _channel.invokeMethod("update", {
//          "title": music.title,
//          "subtitle": music.subTitle,
//          "isFavorite": false,
//          "coverBytes": Uint8List.view(bytes.buffer),
//          "background": (await PaletteGenerator.fromImage(image.image))
//              .mutedColor
//              .color
//              .value,
//        });
//      });
//    }

    return _channel.invokeMethod("update", {
      "title": music.title,
      "subtitle": music.subTitle,
      "isFavorite": false,
      "isPlaying": isPlaying,
    });
  }

  ///cancel player notification
  Future<void> cancel() {
    return _channel.invokeMethod("cancel");
  }
}
