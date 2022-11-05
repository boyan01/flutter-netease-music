import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../extension.dart';

class AnimatedPlayingIndicator extends HookWidget {
  const AnimatedPlayingIndicator({super.key, required this.playing});

  final bool playing;

  @override
  Widget build(BuildContext context) {
    const initialValues = <double>[math.pi / 2, 0, -math.pi / 2];

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1000),
      upperBound: math.pi * 2,
    );

    useEffect(
      () {
        if (playing) {
          controller.repeat();
        } else {
          controller.stop();
        }
      },
      [playing],
    );

    final animationValue = useValueListenable(controller);

    return SizedBox(
      height: 8,
      width: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final initial in initialValues)
            _IndicatorBar(
              value: (math.sin(initial + animationValue) + 1) / 2,
            ),
        ],
      ),
    );
  }
}

class _IndicatorBar extends StatelessWidget {
  const _IndicatorBar({
    super.key,
    required this.value,
  });

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: value * 6 + 2,
      width: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.primary,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
