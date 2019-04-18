import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

///版权说明浮层
class CopyRightOverlay extends StatefulWidget {
  final Widget child;

  const CopyRightOverlay({Key key, this.child}) : super(key: key);

  static void setDismiss(BuildContext context, bool dismiss) {
    _CopyRightOverlayState state = context
        .ancestorStateOfType(const TypeMatcher<_CopyRightOverlayState>());
    state._setDismissed(dismiss);
  }

  static bool isShouldDismiss(BuildContext context) {
    _CopyRightOverlayState state = context
        .ancestorStateOfType(const TypeMatcher<_CopyRightOverlayState>());
    return state.dismiss;
  }

  @override
  _CopyRightOverlayState createState() => _CopyRightOverlayState();
}

class _CopyRightOverlayState extends State<CopyRightOverlay> {
  final _painter = _CopyrightPainter();

  static final _keyDismiss = 'dissmiss_copy_right_overlay';

  bool dismiss = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((preferences) {
      setState(() {
        dismiss = preferences.getBool(_keyDismiss) ?? false;
      });
    });
  }

  void _setDismissed(bool dismiss) {
    if (this.dismiss == dismiss) return;
    setState(() {
      this.dismiss = dismiss;
      SharedPreferences.getInstance().then((preferences) {
        preferences.setBool(_keyDismiss, dismiss);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build with painter : $dismiss");
    return CustomPaint(
      foregroundPainter: dismiss ? null : _painter,
      child: widget.child,
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
    return true;
  }
}
