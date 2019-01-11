import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

MethodChannel _channel = MethodChannel("tech.soit.quiet/palette");

class PaletteGenerator {
  ///generate primary color from image
  static Future<Color> getPrimaryColor(ImageProvider imageProvider,
      {Duration timeout = const Duration(seconds: 15), Size size}) async {
    final ImageStream stream = imageProvider.resolve(
      ImageConfiguration(size: size, devicePixelRatio: 1.0),
    );
    final Completer<ui.Image> imageCompleter = Completer<ui.Image>();
    Timer loadFailureTimeout;
    void imageListener(ImageInfo info, bool synchronousCall) {
      loadFailureTimeout?.cancel();
      stream.removeListener(imageListener);
      imageCompleter.complete(info.image);
    }

    if (timeout != Duration.zero) {
      loadFailureTimeout = Timer(timeout, () {
        stream.removeListener(imageListener);
        imageCompleter.completeError(
          TimeoutException(
              'Timeout occurred trying to load from $imageProvider'),
        );
      });
    }
    stream.addListener(imageListener);
    ui.Image image = await imageCompleter.future;
    ByteData data = await image.toByteData(format: ui.ImageByteFormat.png);

    try {
      final int color = await _channel
          .invokeMethod("getPrimaryColor", data.buffer.asUint8List())
          .timeout(timeout);
      return Color(color);
    } catch (e) {
      return Colors.blueGrey;
    }
  }
}
