import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:netease_music_api/netease_cloud_music.dart';
import 'package:quiet/material/app.dart';
import 'package:quiet/repository/netease.dart';

import 'component/global/settings.dart';
import 'component/netease/netease.dart';
import 'part/part.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  startServer();
  final settings = Settings();
  neteaseRepository = NeteaseRepository();
  runApp(MyApp(setting: settings));
}

class MyApp extends StatelessWidget {
  final Settings setting;

  const MyApp({Key key, @required this.setting}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<Settings>(
      model: setting,
      child:
          ScopedModelDescendant<Settings>(builder: (context, child, setting) {
        return Netease(
          child: Quiet(
            child: CopyRightOverlay(
              child: MaterialApp(
                initialRoute: "/",
                routes: routes,
                title: 'Quiet',
                theme: setting.theme,
              ),
            ),
          ),
        );
      }),
    );
  }
}
