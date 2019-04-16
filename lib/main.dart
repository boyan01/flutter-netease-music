import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'part/part.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final QuietTheme _theme = QuietTheme();

  @override
  Widget build(BuildContext context) {
    return Netease(
      child: Quiet(
        child: CustomPaint(
          foregroundPainter: _CopyrightPainter(),
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

class _CopyrightPainter extends CustomPainter {
  final TextPainter _textPainter = TextPainter(
      text: TextSpan(
        text: "只用作个人学习研究，禁止用于商业及非法用途     只用作个人学习研究，禁止用于商业及非法用途",
        style: TextStyle(color: Colors.grey.withOpacity(0.3)),
      ),
      textDirection: TextDirection.ltr);

  bool _dirty = true;

  static const double radius = (math.pi / 4);

  @override
  void paint(Canvas canvas, Size size) {
    var debugMode = false;
    assert(() {
      debugMode = true;
      return true;
    }());
    if (debugMode) {
      return;
    }

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
