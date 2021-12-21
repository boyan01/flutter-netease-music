import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/providers/lyric_provider.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/repository.dart';

import '../progress_track_container.dart';
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
      builder: (context) => _LyricViewLoader(
        music,
        textAlign,
        textStyle,
        onTap,
      ),
    );
  }
}

class _LyricViewLoader extends ConsumerWidget {
  const _LyricViewLoader(this.music, this.textAlign, this.textStyle, this.onTap,
      {Key? key})
      : super(key: key);

  final Track music;

  final TextAlign textAlign;

  final TextStyle textStyle;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingLyric = ref.watch(lyricProvider(music.id));
    return playingLyric.when(
      data: (lyric) {
        if (lyric == null) {
          return Center(
            child: Text(context.strings.noLyric, style: textStyle),
          );
        }
        return LayoutBuilder(builder: (context, constraints) {
          return _LyricView(
            lyric: lyric,
            viewportHeight: constraints.maxHeight,
            onTap: onTap,
            textStyle: textStyle,
            textAlign: textAlign,
          );
        });
      },
      error: (error, stack) => Center(
        child: Text(context.formattedError(error), style: textStyle),
      ),
      loading: () => Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(color: textStyle.color),
        ),
      ),
    );
  }
}

class _LyricView extends ConsumerWidget {
  const _LyricView({
    Key? key,
    required this.lyric,
    required this.viewportHeight,
    required this.onTap,
    required this.textAlign,
    required this.textStyle,
  }) : super(key: key);

  final LyricContent lyric;

  final double viewportHeight;

  final VoidCallback? onTap;

  final TextAlign textAlign;

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = textStyle.color!;
    final normalStyle = textStyle.copyWith(color: color.withOpacity(0.7));

    final playing = ref.read(playerStateProvider).isPlaying;
    final position = ref.read(playerStateProvider.notifier).position;

    return ShaderMask(
      shaderCallback: (rect) {
        // add transparent gradient to lyric top and bottom.
        return ui.Gradient.linear(
          Offset(rect.width / 2, 0),
          Offset(rect.width / 2, viewportHeight),
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
        lyric: lyric,
        lyricLineStyle: normalStyle,
        highlight: color,
        position: position?.inMilliseconds,
        onTap: onTap,
        size: Size(
          viewportHeight,
          viewportHeight == double.infinity ? 0 : viewportHeight,
        ),
        playing: playing,
        textAlign: textAlign,
      ),
    );
  }
}
