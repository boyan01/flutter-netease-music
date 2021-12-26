import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AppScrollController useAppScrollController() {
  final controller = useMemoized(() => AppScrollController());
  useEffect(() {
    return controller.dispose;
  }, [controller]);
  return controller;
}

class AppScrollController extends ScrollController {
  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return _ScrollPositionWithSingleContext(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _ScrollPositionWithSingleContext extends ScrollPositionWithSingleContext {
  _ScrollPositionWithSingleContext({
    required ScrollPhysics physics,
    required ScrollContext context,
    double? initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition? oldPosition,
    String? debugLabel,
  }) : super(
          physics: physics,
          context: context,
          initialPixels: initialPixels,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        );

  @override
  void pointerScroll(double delta) {
    assert(delta != 0.0);
    final double scrollerScale;
    if (defaultTargetPlatform == TargetPlatform.windows) {
      scrollerScale = window.devicePixelRatio * 2;
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      scrollerScale = window.devicePixelRatio;
    } else {
      scrollerScale = 1;
    }
    super.pointerScroll(delta * scrollerScale);
  }
}
