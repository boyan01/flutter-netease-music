import 'package:flutter/services.dart';
import 'package:quiet/model/model.dart';

MethodChannel _channel = MethodChannel("tech.soit.quiet/notification");

QuietNotification notification = QuietNotification();

///use to create a notification for android
///has no effect for ios
class QuietNotification {

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
