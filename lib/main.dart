import 'package:flutter/material.dart';
import 'package:quiet/material/app.dart';

import 'part/part.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final QuietTheme _theme = QuietTheme();

  @override
  Widget build(BuildContext context) {
    return Netease(
      child: Quiet(
        child: CopyRightOverlay(
          child: ScopedModel<QuietTheme>(
            model: _theme,
            child: ScopedModelDescendant<QuietTheme>(
                builder: (context, child, manager) {
              return MaterialApp(
                initialRoute: "/",
                routes: routes,
                title: 'Quiet',
                theme: ThemeData(
                  primaryColor: manager.current,
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
