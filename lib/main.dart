import 'package:flutter/material.dart';
import 'package:quiet/material/app.dart';
import 'package:quiet/repository/netease.dart';

import 'component/global/settings.dart';
import 'component/netease/netease.dart';
import 'part/part.dart';

void main() {
  final settings = Settings();
  neteaseRepository = NeteaseRepository(settings);
  runApp(MyApp(setting: settings));
}

class MyApp extends StatelessWidget {
  final Settings setting;

  const MyApp({Key key, @required this.setting}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Netease(
      child: Quiet(
        child: CopyRightOverlay(
          child: ScopedModel<Settings>(
            model: setting,
            child: ScopedModelDescendant<Settings>(
                builder: (context, child, settings) {
              return MaterialApp(
                initialRoute: "/",
                routes: routes,
                title: 'Quiet',
                theme: ThemeData(
                  primaryColor: settings.theme,
                  textTheme: TextTheme(
                    body1: TextStyle(shadows: [
                      Shadow(
                          offset: Offset(0.08, 0.08),
                          blurRadius: 0.1,
                          color: Colors.black54),
                    ]),
                    body2: TextStyle(shadows: [
                      Shadow(
                          offset: Offset(0.1, 0.1),
                          blurRadius: 0.5,
                          color: Colors.black87)
                    ]),
                  ),
                  dividerColor: Color(0xfff5f5f5),
                  iconTheme: IconThemeData(color: Color(0xFFb3b3b3)),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
