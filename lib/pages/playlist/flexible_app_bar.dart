import 'dart:math' as math;

import 'package:flutter/material.dart';

///the same as [FlexibleSpaceBar]
class FlexibleDetailBar extends StatelessWidget {
  final Widget content;

  ///[t] 0.0 -> Expanded  1.0 -> Collapsed to toolbar
  final Widget Function(BuildContext context, double t) builder;

  const FlexibleDetailBar(
      {Key key, @required this.content, @required this.builder})
      : assert(content != null),
        assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final FlexibleSpaceBarSettings settings =
        context.inheritFromWidgetOfExactType(FlexibleSpaceBarSettings);

    final List<Widget> children = <Widget>[];

    final double deltaExtent = settings.maxExtent - settings.minExtent;
    // 0.0 -> Expanded
    // 1.0 -> Collapsed to toolbar
    final double t =
        (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
            .clamp(0.0, 1.0);
    final double fadeStart = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
    final double opacity = 1.0 - Interval(fadeStart, 1.0).transform(t);
    children.add(Positioned(
      top: settings.currentExtent - settings.maxExtent,
      left: 0,
      right: 0,
      height: settings.maxExtent,
      child: Opacity(
        opacity: opacity,
        child: content,
      ),
    ));

    children.add(Column(children: <Widget>[builder(context, t)]));

    return ClipRect(child: Stack(children: children, fit: StackFit.expand));
  }
}
