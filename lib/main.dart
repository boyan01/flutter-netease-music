import 'dart:async';
import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiet/component.dart';
import 'package:quiet/navigation/app.dart';
import 'package:quiet/pages/splash/page_splash.dart';
import 'package:quiet/repository.dart';
import 'package:window_manager/window_manager.dart';

import 'media/tracks/tracks_player_impl_mobile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkRepository.initialize();
  DartVLC.initialize();
  _initialDesktop();
  runZonedGuarded(() {
    runApp(rp.ProviderScope(
      child: PageSplash(
        futures: [
          getApplicationDocumentsDirectory().then((dir) {
            Hive.init(dir.path);
            return Hive.openBox<Map>('player');
          }),
        ],
        builder: (BuildContext context, List<dynamic> data) {
          return MyApp(
            player: data[0] as Box<Map>,
          );
        },
      ),
    ));
  }, (error, stack) {
    debugPrint('uncaught error : $error $stack');
  });
}

void _initialDesktop() async {
  if (!(Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    return;
  }
  await WindowManager.instance.ensureInitialized();
  WindowManager.instance.setMinimumSize(const Size(960, 720));
}

/// The entry of dart background service
/// NOTE: this method will be invoked by native (Android/iOS)
@pragma('vm:entry-point') // avoid Tree Shaking
void playerBackgroundService() {
  WidgetsFlutterBinding.ensureInitialized();
  // 获取播放地址需要使用云音乐 API, 所以需要为此 isolate 初始化一个 repository.
  NetworkRepository.initialize();
  runMobileBackgroundService();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, this.player}) : super(key: key);

  final Box<Map>? player;

  @override
  Widget build(BuildContext context) {
    return const Netease(
      child: OverlaySupport(
        child: QuietApp(),
      ),
    );
  }
}
