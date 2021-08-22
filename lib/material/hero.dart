import 'package:flutter/material.dart';
import 'package:quiet/component.dart';

class QuietHero extends StatelessWidget {
  const QuietHero({Key? key, required this.tag, required this.child})
      : super(key: key);

  final Object tag;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.isLandscape) {
      // disable hero animation in landscape mode
      return child;
    }
    return Hero(tag: tag, child: child);
  }
}
