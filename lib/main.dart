import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_player/music_player.dart';
import 'package:netease_music_api/netease_cloud_music.dart' as api;
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/route.dart';
import 'package:quiet/material/app.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/pages/splash/page_splash.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'component/global/settings.dart';
import 'component/netease/netease.dart';
import 'component/player/interceptors.dart';
import 'component/player/player.dart';
import 'component/utils/crypto.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  WidgetsFlutterBinding.ensureInitialized();
  neteaseRepository = NeteaseRepository();
  api.debugPrint = debugPrint;
  runApp(PageSplash(
    futures: [
      api.startServer(decryptor: NeteaseCloudApiCrypto().decrypt),
      SharedPreferences.getInstance(),
      UserAccount.getPersistenceUser(),
    ],
    builder: (context, data) {
      final setting = Settings(data[1]);
      return MyApp(setting: setting, user: data[2]);
    },
  ));
}

/// this method will be invoked by native (Android/iOS)
void playerBackgroundService() {
  WidgetsFlutterBinding.ensureInitialized();
  neteaseRepository = NeteaseRepository(3001);
  // fixme don't use socket!!
  api.startServer(port: 3001, decryptor: NeteaseCloudApiCrypto().decrypt);
  runBackgroundService(
    imageLoadInterceptor: BackgroundInterceptors.loadImageInterceptor,
    playUriInterceptor: BackgroundInterceptors.playUriInterceptor,
  );
}

class MyApp extends StatelessWidget {
  final Settings setting;

  final Map user;

  const MyApp({Key key, @required this.setting, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<Settings>(
      model: setting,
      child: ScopedModelDescendant<Settings>(builder: (context, child, setting) {
        return Netease(
          user: user,
          child: Quiet(
            child: CopyRightOverlay(
              child: OverlaySupport(
                child: MaterialApp(
                  routes: routes,
                  onGenerateRoute: routeFactory,
                  title: 'Quiet',
                  theme: setting.theme,
                  initialRoute: getInitialRoute(),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  String getInitialRoute() {
    bool login = user != null;
    if (!login && !setting.skipWelcomePage) {
      return pageWelcome;
    }
    return pageMain;
  }
}
