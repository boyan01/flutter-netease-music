import 'package:flutter/material.dart';

///the same as [FlexibleSpaceBar]
class FlexibleDetailBar extends StatelessWidget {
  const FlexibleDetailBar({
    super.key,
    required this.content,
    this.builder,
    required this.background,
    this.customBuilder,
  });

  ///the content of bar
  ///scroll with the parent ScrollView
  final Widget content;

  ///the background of bar
  ///scroll in parallax
  final Widget background;

  /// custom content interaction with t
  /// bottom 0.0 -> Expanded  1.0 -> Collapsed to toolbar
  final Widget Function(BuildContext context, double t)? builder;

  final Widget Function(
    BuildContext context,
    double contentHeight,
    double height,
  )? customBuilder;

  static double percentage(BuildContext context) {
    final value =
        context.dependOnInheritedWidgetOfExactType<_FlexibleDetail>();
    assert(value != null, 'ooh , can not find');
    return value!.t;
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;

    final children = <Widget>[];

    final deltaExtent = settings.maxExtent - settings.minExtent;
    // 0.0 -> Expanded
    // 1.0 -> Collapsed to toolbar
    final t =
        (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
            .clamp(0.0, 1.0);

    // add parallax effect to background.
    children.add(Positioned(
      top: -Tween<double>(begin: 0, end: deltaExtent / 4.0).transform(t),
      left: 0,
      right: 0,
      // to avoid one line gap between bottom and blow content.
      bottom: 0,
      child: ClipRect(child: background),
    ),);

    // need add a padding to avoid overlap the bottom widget.
    var bottomPadding = 0.0;
    final sliverBar =
        context.findAncestorWidgetOfExactType<SliverAppBar>();
    if (sliverBar != null && sliverBar.bottom != null) {
      bottomPadding = sliverBar.bottom!.preferredSize.height;
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
            color: Colors.transparent,
            child: DefaultTextStyle(
                style: Theme.of(context).primaryTextTheme.bodyText2!,
                child: content,),
          ),
        ),
      ),
    ),);

    if (builder != null) {
      children.add(Column(children: <Widget>[builder!(context, t)]));
    }
    if (customBuilder != null) {
      children.add(Positioned(
        top: settings.currentExtent - settings.maxExtent,
        left: 0,
        right: 0,
        height: settings.maxExtent,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: customBuilder!(
            context,
            settings.currentExtent - settings.minExtent,
            settings.maxExtent - settings.minExtent,
          ),
        ),
      ),);
    }

    return _FlexibleDetail(t,
        child: ClipRect(
            child: DefaultTextStyle(
                style: Theme.of(context).primaryTextTheme.bodyText2!,
                child: Stack(
                  fit: StackFit.expand,
                  children: children,
                ),),),);
  }
}

class _FlexibleDetail extends InheritedWidget {
  const _FlexibleDetail(this.t, {required super.child});

  ///0 : Expanded
  ///1 : Collapsed
  final double t;

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
  const FlexShadowBackground({super.key, this.child});
  final Widget? child;

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
