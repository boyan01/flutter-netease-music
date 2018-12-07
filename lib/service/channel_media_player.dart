import 'package:flutter/services.dart';

MethodChannel _channel = MethodChannel("tech.soit.quiet/player")
// This will clear all open videos on the platform when a full restart is
// performed.
  ..invokeMethod("init");

class PlayerController {




}



