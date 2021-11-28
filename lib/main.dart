import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quiet/component.dart';
import 'package:quiet/material/app.dart';
import 'package:quiet/navigation/app.dart';
import 'package:quiet/pages/splash/page_splash.dart';
import 'package:quiet/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'media/tracks/tracks_player_impl_mobile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkRepository.initialize();
  runZonedGuarded(() {
    runApp(rp.ProviderScope(
      child: PageSplash(
        futures: [
          SharedPreferences.getInstance(),
          getApplicationDocumentsDirectory().then((dir) {
            Hive.init(dir.path);
            return Hive.openBox<Map>('player');
          }),
        ],
        builder: (BuildContext context, List<dynamic> data) {
          return MyApp(
            setting: Settings(data[0] as SharedPreferences),
            player: data[1] as Box<Map>,
          );
        },
      ),
    ));
  }, (error, stack) {
    debugPrint('uncaught error : $error $stack');
  });
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
  const MyApp({
    Key? key,
    required this.setting,
    this.player,
  }) : super(key: key);

  final Settings setting;

  final Box<Map>? player;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Settings>.value(
      value: setting,
      child: Netease(
        child: Quiet(
          box: player,
          child: const CopyRightOverlay(
            child: OverlaySupport(
              child: QuietApp(),
            ),
          ),
        ),
      ),
    );
  }
}
