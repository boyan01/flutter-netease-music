import 'package:flutter/material.dart';

class SlideUpPage extends Page<dynamic> {
  const SlideUpPage({
    required this.child,
    super.name,
  });

  final Widget child;

  @override
  Route createRoute(BuildContext context) => _SlideUpPageRouter(page: this);
}

class _SlideUpPageRouter<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _SlideUpPageRouter({required this.page}) : super(settings: page);

  final SlideUpPage page;

  @override
  Widget buildContent(BuildContext context) => page.child;

  @override
  bool get maintainState => true;

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    // make other pages do not slide left/up
    return false;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _FadeUpwardsPageTransition(
      routeAnimation: animation,
      child: child,
    );
  }
}

// Slides the page upwards and fades it in.
class _FadeUpwardsPageTransition extends StatelessWidget {
  _FadeUpwardsPageTransition({
    super.key,
    // The route's linear 0.0 - 1.0 animation.
    required Animation<double> routeAnimation,
    required this.child,
  })  : _positionAnimation =
            routeAnimation.drive(_bottomUpTween.chain(_fastOutSlowInTween)),
        _opacityAnimation =
            routeAnimation.drive(_alphaTween.chain(_easeInTween));

  static final Tween<Offset> _bottomUpTween = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  );

  static final Tween<double> _alphaTween = Tween<double>(
    begin: 0.5,
    end: 1,
  );

  static final Animatable<double> _fastOutSlowInTween =
      CurveTween(curve: Curves.fastOutSlowIn);
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);

  final Animation<Offset> _positionAnimation;
  final Animation<double> _opacityAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _positionAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: child,
      ),
    );
  }
}
