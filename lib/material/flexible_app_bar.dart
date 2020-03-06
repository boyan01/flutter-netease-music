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

  static double percentage(BuildContext context) {
    _FlexibleDetail value = context.dependOnInheritedWidgetOfExactType<_FlexibleDetail>();
    assert(value != null, 'ooh , can not find');
    return value.t;
  }

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
    final FlexibleSpaceBarSettings settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    final List<Widget> children = <Widget>[];

    final double deltaExtent = settings.maxExtent - settings.minExtent;
    // 0.0 -> Expanded
    // 1.0 -> Collapsed to toolbar
    final double t = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0);

    //背景添加视差滚动效果
    children.add(Positioned(
      top: -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t),
      left: 0,
      right: 0,
      height: settings.maxExtent,
      child: background,
    ));

    //为content 添加 底部的 padding
    double bottomPadding = 0;
    SliverAppBar sliverBar = context.findAncestorWidgetOfExactType<SliverAppBar>();
    if (sliverBar != null && sliverBar.bottom != null) {
      bottomPadding = sliverBar.bottom.preferredSize.height;
    }
    children.add(Positioned(
      top: settings.currentExtent - settings.maxExtent,
      left: 0,
      right: 0,
      height: settings.maxExtent,
      child: Opacity(
        opacity: 1 - t,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Material(
              child: DefaultTextStyle(style: Theme.of(context).primaryTextTheme.bodyText2, child: content),
              elevation: 0,
              color: Colors.transparent),
        ),
      ),
    ));

    if (builder != null) {
      children.add(Column(children: <Widget>[builder(context, t)]));
    }

    return _FlexibleDetail(t,
        child: ClipRect(
            child: DefaultTextStyle(
                style: Theme.of(context).primaryTextTheme.bodyText2,
                child: Stack(children: children, fit: StackFit.expand))));
  }
}

class _FlexibleDetail extends InheritedWidget {
  ///0 : Expanded
  ///1 : Collapsed
  final double t;

  _FlexibleDetail(this.t, {Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(_FlexibleDetail oldWidget) {
    return t != oldWidget.t;
  }
}

///
/// 用在 [FlexibleDetailBar.background]
/// child上下滑动的时候会覆盖上黑色阴影
///
class FlexShadowBackground extends StatelessWidget {
  final Widget child;

  const FlexShadowBackground({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var t = FlexibleDetailBar.percentage(context);
    t = Curves.ease.transform(t) / 2 + 0.2;
    return Container(
      foregroundDecoration: BoxDecoration(color: Colors.black.withOpacity(t)),
      child: child,
    );
  }
}
