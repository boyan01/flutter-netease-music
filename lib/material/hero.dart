import 'package:flutter/material.dart';
import '../component.dart';

class QuietHero extends StatelessWidget {
  const QuietHero({super.key, required this.tag, required this.child});

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
