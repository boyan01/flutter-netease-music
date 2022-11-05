import 'dart:math' as math;

import 'package:flutter/material.dart';

mixin _UnboundedTrackShapeMixin implements BaseSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight!;
    assert(trackHeight >= 0);

    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackRight = trackLeft + parentBox.size.width;
    final trackBottom = trackTop + trackHeight;
    return Rect.fromLTRB(
      math.min(trackLeft, trackRight),
      trackTop,
      math.max(trackLeft, trackRight),
      trackBottom,
    );
  }
}

class UnboundedRectangularSliderTrackShape extends RectangularSliderTrackShape
    with _UnboundedTrackShapeMixin {
  const UnboundedRectangularSliderTrackShape();
}

class UnboundedRoundedRectSliderTrackShape extends RoundedRectSliderTrackShape
    with _UnboundedTrackShapeMixin {
  const UnboundedRoundedRectSliderTrackShape({
    this.removeAdditionalActiveTrackHeight = false,
  });

  final bool removeAdditionalActiveTrackHeight;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight:
          removeAdditionalActiveTrackHeight ? 0 : additionalActiveTrackHeight,
    );
  }
}
