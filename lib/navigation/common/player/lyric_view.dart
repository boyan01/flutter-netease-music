import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:quiet/component.dart';
import 'package:quiet/repository.dart';

import '../../../material/player/progress_track_container.dart';
import 'lyric.dart';

class PlayingLyricView extends StatelessWidget {
  PlayingLyricView({
    Key? key,
    this.onTap,
    required this.music,
    required this.textStyle,
    this.textAlign = TextAlign.center,
  })  : assert(textStyle.color != null),
        super(key: key);
  final VoidCallback? onTap;

  final Track music;

  final TextAlign textAlign;

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return ProgressTrackingContainer(
        builder: _buildLyric, player: context.player);
  }

  Widget _buildLyric(BuildContext context) {
    final playingLyric = PlayingLyric.of(context);
    final color = textStyle.color!;
    if (playingLyric.hasLyric) {
      return LayoutBuilder(builder: (context, constraints) {
        final normalStyle = textStyle.copyWith(color: color.withOpacity(0.7));
        //歌词顶部与尾部半透明显示
        return ShaderMask(
          shaderCallback: (rect) {
            return ui.Gradient.linear(
              Offset(rect.width / 2, 0),
              Offset(rect.width / 2, constraints.maxHeight),
              [
                color.withOpacity(0),
                color,
                color,
                color.withOpacity(0),
              ],
              const [0.0, 0.15, 0.85, 1],
            );
          },
          child: Lyric(
            lyric: playingLyric.lyric!,
            lyricLineStyle: normalStyle,
            highlight: color,
            position: context.player.position?.inMilliseconds,
            onTap: onTap,
            size: Size(
                constraints.maxWidth,
                constraints.maxHeight == double.infinity
                    ? 0
                    : constraints.maxHeight),
            playing: context.isPlaying,
            textAlign: textAlign,
          ),
        );
      });
    } else {
      return Center(
        child: Text(playingLyric.message!, style: textStyle),
      );
    }
  }
}
