import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'part/part.dart';

void main() => runApp(MyApp());

const NETEASE_SWATCH = const MaterialColor(0xFFdd4237, {
  900: const Color(0xFFae2a20),
  800: const Color(0xFFbe332a),
  700: const Color(0xFFcb3931),
  600: const Color(0xFFdd4237),
  500: const Color(0xFFec4b38),
  400: const Color(0xFFe85951),
  300: const Color(0xFFdf7674),
  200: const Color(0xFFea9c9a),
  100: const Color(0xFFfcced2),
  50: const Color(0xFFfeebee),
});

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LoginStateWidget(
      Quiet(
        child: CustomPaint(
          foregroundPainter: _CopyrightPainter(),
          child: MaterialApp(
            initialRoute: "/",
            routes: routes,
            title: 'Quiet',
            theme: ThemeData(
              primarySwatch: NETEASE_SWATCH,
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
              iconTheme: IconThemeData(color: Color(0xFFb3b3b3)),
            ),
          ),
        ),
      ),
    );
  }
}

class _CopyrightPainter extends CustomPainter {
  final TextPainter _textPainter = TextPainter(
      text: TextSpan(
        text:
            "只用作个人学习研究，禁止用于商业及非法用途     只用作个人学习研究，禁止用于商业及非法用途",
        style: TextStyle(color: Colors.grey.withOpacity(0.3)),
      ),
      textDirection: TextDirection.ltr);

  bool _dirty = true;

  static const double radius = (math.pi / 4);

  @override
  void paint(Canvas canvas, Size size) {
    if (_dirty) {
      _textPainter.layout();
      _dirty = false;
    }
    canvas.rotate(-radius);

    double dy = 0;
    while (dy < size.height) {
      canvas.save();
      double dx = dy * math.tan(radius);
      canvas.translate(-dx, dy);
      _textPainter.paint(canvas, Offset.zero);
      dy += _textPainter.height * 3;
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
