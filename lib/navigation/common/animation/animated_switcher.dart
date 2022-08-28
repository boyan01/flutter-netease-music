import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AnimatedSwitcher extends StatelessWidget {
  const AnimatedSwitcher({
    super.key,
    required this.firstChild,
    required this.secondChild,
    required this.state,
    this.duration = const Duration(milliseconds: 200),
  });

  final Widget firstChild;
  final Widget secondChild;

  final CrossFadeState state;

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final showFirst = state == CrossFadeState.showFirst;

    // start -> show first child
    // end -> show second child
    final animationController = useAnimationController(
      duration: duration,
      initialValue: showFirst ? 0.0 : 1.0,
    );

    useEffect(
      () {
        animationController.duration = duration;
      },
      [duration],
    );

    useEffect(
      () {
        if (!showFirst) {
          animationController.forward();
        } else {
          animationController.reverse();
        }
      },
      [showFirst],
    );

    // 0 -> 0.5: scale down first child from 1 -> 0.6
    // 0.5 -> 1: scale up first child from 0.6 -> 1
    final animatedValue = useAnimation(animationController);

    final double secondScale;
    final double firstScale;

    if (animatedValue < 0.5) {
      secondScale = 0;
      firstScale =
          Tween<double>(begin: 1, end: 0.6).transform(animatedValue * 2.0);
    } else {
      firstScale = 0;
      secondScale = Tween<double>(begin: 0.6, end: 1)
          .transform((animatedValue - 0.5) * 2);
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        if (secondScale >= 0.6)
          Transform.scale(
            scale: secondScale,
            child: secondChild,
          ),
        if (firstScale >= 0.6)
          Transform.scale(
            scale: firstScale,
            child: firstChild,
          ),
      ],
    );
  }
}
