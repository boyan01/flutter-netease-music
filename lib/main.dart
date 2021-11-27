import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:music_player/music_player.dart';
import 'package:netease_music_api/netease_cloud_music.dart' as api;
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiet/component.dart';
import 'package:quiet/material/app.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/pages/splash/page_splash.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'media/tracks/tracks_player_impl_mobile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  neteaseRepository = NeteaseRepository();
  api.debugPrint = debugPrint;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.time} ${record.level.name} '
        '${record.loggerName}: ${record.message}');
  });

  runZonedGuarded(() {
    runApp(ProviderScope(
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
  neteaseRepository = NeteaseRepository();
  runMobileBackgroundService();
}

class MyApp extends ConsumerWidget {
  const MyApp({
    Key? key,
    required this.setting,
    this.player,
  }) : super(key: key);

  final Settings setting;

  final Box<Map>? player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScopedModel<Settings>(
      model: setting,
      child:
          ScopedModelDescendant<Settings>(builder: (context, child, setting) {
        return Netease(
          child: Quiet(
            box: player,
            child: CopyRightOverlay(
              child: OverlaySupport(
                child: MaterialApp(
                  routes: routes,
                  onGenerateRoute: routeFactory,
                  title: 'Quiet',
                  supportedLocales: const [Locale("en"), Locale("zh")],
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                  ],
                  theme: setting.theme,
                  darkTheme: setting.darkTheme,
                  themeMode: setting.themeMode,
                  initialRoute: getInitialRoute(ref),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  String getInitialRoute(WidgetRef ref) {
    final bool login = ref.read(isLoginProvider);
    if (!login && !setting.skipWelcomePage) {
      return pageWelcome;
    }
    return pageMain;
  }
}
