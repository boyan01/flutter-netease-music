import 'package:flutter/material.dart';

///the same as [FlexibleSpaceBar]
class FlexibleDetailBar extends StatelessWidget {
  ///the content of bar
  ///scroll with the parent ScrollView
  final Widget content;

  ///the background of bar
  ///scroll in parallax
  final Widget background;

  ///custom content interaction with t
  ///[t] 0.0 -> Expanded  1.0 -> Collapsed to toolbar
  final Widget Function(BuildContext context, double t) builder;

  const FlexibleDetailBar({
    Key key,
    @required this.content,
    this.builder,
    @required this.background,
  })  : assert(content != null),
        assert(background != null),
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

    //背景添加视差滚动效果
    children.add(Positioned(
      top: -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t),
      left: 0,
      right: 0,
      height: settings.maxExtent,
      child: background,
    ));

    children.add(Positioned(
      top: settings.currentExtent - settings.maxExtent,
      left: 0,
      right: 0,
      height: settings.maxExtent,
      child: Opacity(
        opacity: 1 - t,
        child: content,
      ),
    ));

    if (builder != null) {
      children.add(Column(children: <Widget>[builder(context, t)]));
    }

    return ClipRect(child: Stack(children: children, fit: StackFit.expand));
  }
}
