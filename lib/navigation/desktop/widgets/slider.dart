import 'dart:math' as math;

import 'package:flutter/material.dart';

class UnboundedRectangularSliderTrackShape extends RectangularSliderTrackShape {
  const UnboundedRectangularSliderTrackShape();

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
