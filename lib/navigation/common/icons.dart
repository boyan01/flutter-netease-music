import 'package:flutter/material.dart';
import '../../extension.dart';

class PlayIcon extends StatelessWidget {
  const PlayIcon({
    super.key,
    this.size = 24,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          Center(
            child: Container(color: Colors.white, width: 10, height: 10),
          ),
          Icon(
            Icons.play_circle_rounded,
            color: context.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
