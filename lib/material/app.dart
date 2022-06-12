import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../extension.dart';

import '../providers/settings_provider.dart';

class CopyRightOverlay extends HookConsumerWidget {
  const CopyRightOverlay({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copyRight = context.strings.copyRightOverlay;
    final textStyle = context.textTheme.caption!.copyWith(
      color: context.textTheme.caption!.color!.withOpacity(0.3),
    );
    final painter = useMemoized(
      () => _CopyrightPainter(copyright: copyRight, style: textStyle),
    );
    useEffect(
      () {
        painter.setText(copyRight, textStyle);
      },
      [copyRight, textStyle],
    );
    return CustomPaint(
      foregroundPainter:
          ref.watch(settingStateProvider.select((value) => value.copyright))
              ? null
              : painter,
      child: child,
    );
  }
}

class _CopyrightPainter extends CustomPainter {
  _CopyrightPainter({
    required String copyright,
    required TextStyle style,
  }) : _textPainter = TextPainter(
          text: TextSpan(
            text: copyright,
            style: style,
          ),
          textDirection: TextDirection.ltr,
        );

  final TextPainter _textPainter;

  bool _dirty = true;

  void setText(String text, TextStyle style) {
    _textPainter.text = TextSpan(
      text: text,
      style: style,
    );
    _dirty = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const radius = math.pi / 4;
    if (_dirty) {
      _textPainter.layout();
      _dirty = false;
    }
    canvas.rotate(-radius);
    canvas.translate(-size.width, 0);

    var dy = 0.0;
    while (dy < size.height * 1.5) {
      var dx = 0.0;
      while (dx < size.width * 1.5) {
        _textPainter.paint(canvas, Offset(dx, dy));
        dx += _textPainter.width * 1.5;
      }
      dy += _textPainter.height * 3;
      dx = 0;
    }
  }

  @override
  bool shouldRepaint(_CopyrightPainter oldDelegate) {
    return _textPainter != oldDelegate._textPainter;
  }
}
