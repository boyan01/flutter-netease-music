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

class RecommendIcon extends StatelessWidget {
  const RecommendIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: context.strings.intelligenceRecommended,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: context.colorScheme.textHint,
            ),
          ),
          width: 14,
          height: 14,
          child: Center(
            child: Text(
              context.strings.recommendTrackIconText,
              style: context.textTheme.caption?.copyWith(
                fontSize: 10,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
