import 'dart:math';

import 'package:flutter/widgets.dart';

// Switched to CustomPaint icons by https://github.com/esDotDev

/// Close
class CloseIcon extends StatelessWidget {
  const CloseIcon({Key? key, required this.color}) : super(key: key);
  final Color color;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topLeft,
        child: Stack(children: [
          // Use rotated containers instead of a painter because it renders slightly crisper than a painter for some reason.
          Transform.rotate(
              angle: pi * .25,
              child:
                  Center(child: Container(width: 14, height: 1, color: color))),
          Transform.rotate(
              angle: pi * -.25,
              child:
                  Center(child: Container(width: 14, height: 1, color: color))),
        ]),
      );
}

/// Maximize
class MaximizeIcon extends StatelessWidget {
  const MaximizeIcon({Key? key, required this.color}) : super(key: key);
  final Color color;

  @override
  Widget build(BuildContext context) => _AlignedPaint(_MaximizePainter(color));
}

class _MaximizePainter extends _IconPainter {
  _MaximizePainter(Color color) : super(color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width - 1, size.height - 1), p);
  }
}

/// Restore
class RestoreIcon extends StatelessWidget {
  const RestoreIcon({
    Key? key,
    required this.color,
  }) : super(key: key);
  final Color color;

  @override
  Widget build(BuildContext context) => _AlignedPaint(_RestorePainter(color));
}

class _RestorePainter extends _IconPainter {
  _RestorePainter(Color color) : super(color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color);
    canvas.drawRect(Rect.fromLTRB(0, 2, size.width - 2, size.height), p);
    canvas.drawLine(const Offset(2, 2), const Offset(2, 0), p);
    canvas.drawLine(const Offset(2, 0), Offset(size.width, 0), p);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, size.height - 2), p);
    canvas.drawLine(Offset(size.width, size.height - 2),
        Offset(size.width - 2, size.height - 2), p);
  }
}

/// Minimize
class MinimizeIcon extends StatelessWidget {
  const MinimizeIcon({Key? key, required this.color}) : super(key: key);
  final Color color;

  @override
  Widget build(BuildContext context) => _AlignedPaint(_MinimizePainter(color));
}

class _MinimizePainter extends _IconPainter {
  _MinimizePainter(Color color) : super(color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color);
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
  }
}

/// Helpers
abstract class _IconPainter extends CustomPainter {
  _IconPainter(this.color);

  final Color color;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AlignedPaint extends StatelessWidget {
  const _AlignedPaint(this.painter, {Key? key}) : super(key: key);
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: CustomPaint(size: const Size(10, 10), painter: painter));
  }
}

Paint getPaint(Color color, [bool isAntiAlias = false]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..isAntiAlias = isAntiAlias
  ..strokeWidth = 1;
