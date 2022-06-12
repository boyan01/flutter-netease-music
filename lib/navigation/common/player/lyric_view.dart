import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../extension.dart';
import '../../../providers/lyric_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';

import '../progress_track_container.dart';
import 'lyric.dart';

class PlayingLyricView extends ConsumerWidget {
  PlayingLyricView({
    super.key,
    this.onTap,
    required this.music,
    required this.textStyle,
    this.textAlign = TextAlign.center,
  })  : assert(textStyle.color != null);
  final VoidCallback? onTap;

  final Track music;

  final TextAlign textAlign;

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlaying = ref.watch(playingTrackProvider);

    if (currentPlaying != music) {
      return _LyricViewLoader(music, textAlign, textStyle, onTap);
    }

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
      {super.key,});

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
            track: music,
          );
        },);
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
    super.key,
    required this.lyric,
    required this.viewportHeight,
    required this.onTap,
    required this.textAlign,
    required this.textStyle,
    required this.track,
  });

  final LyricContent lyric;

  final double viewportHeight;

  final VoidCallback? onTap;

  final TextAlign textAlign;

  final TextStyle textStyle;

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = textStyle.color!;
    final normalStyle = textStyle.copyWith(color: color.withOpacity(0.7));

    final currentPlaying = ref.watch(playingTrackProvider);

    final bool playing;
    final Duration? position;

    if (currentPlaying != track) {
      playing = false;
      position = null;
    } else {
      playing = ref.read(playerStateProvider).isPlaying;
      position = ref.read(playerStateProvider.notifier).position;
    }

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
        position: position?.inMilliseconds ?? 0,
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
