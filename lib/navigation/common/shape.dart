import 'package:flutter/material.dart';

class BorderWithArrow extends ShapeBorder {
  const BorderWithArrow({
    this.arrowTop = Size.zero,
    this.arrowBottom = Size.zero,
    this.radius = 10,
  });

  const BorderWithArrow.top({
    Size arrowSize = const Size(10, 6),
    this.radius = 10,
  })  : arrowBottom = Size.zero,
        arrowTop = arrowSize;

  const BorderWithArrow.bottom({
    Size arrowSize = const Size(10, 6),
    this.radius = 10,
  })  : arrowBottom = arrowSize,
        arrowTop = Size.zero;

  final Size arrowTop;
  final Size arrowBottom;

  final double radius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(
        top: arrowTop.height,
        bottom: arrowBottom.height,
      );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(
        RRect.fromLTRBR(
          rect.left,
          rect.top + arrowTop.height,
          rect.right,
          rect.bottom - arrowBottom.height,
          Radius.circular(radius),
        ),
      );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(
        RRect.fromLTRBR(
          rect.left,
          rect.top,
          rect.right,
          rect.bottom,
          Radius.circular(radius),
        ),
      )
      ..addPolygon(
        <Offset>[
          rect.topCenter - Offset(0, arrowTop.height),
          rect.topCenter - Offset(arrowTop.width / 2, 0),
          rect.topCenter + Offset(arrowTop.width / 2, 0),
        ],
        true,
      )
      ..addPolygon(
        <Offset>[
          rect.bottomCenter + Offset(0, arrowBottom.height),
          rect.bottomCenter - Offset(arrowBottom.width / 2, 0),
          rect.bottomCenter + Offset(arrowBottom.width / 2, 0),
        ],
        true,
      );
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? width,
    double? height,
    TextDirection? textDirection,
  }) {}

  @override
  ShapeBorder scale(double t) {
    return const BorderWithArrow();
  }
}
