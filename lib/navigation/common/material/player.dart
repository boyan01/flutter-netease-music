import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/player_provider.dart';

const _indexBuffering = 2;
const _indexPlaying = 1;
const _indexPausing = 0;

///
/// an widget which indicator player is Playing/Pausing/Buffering
///
class PlayingIndicator extends HookConsumerWidget {
  const PlayingIndicator({
    super.key,
    required this.playing,
    required this.pausing,
    required this.buffering,
  });

  ///show when player is playing
  final Widget playing;

  ///show when player is pausing
  final Widget pausing;

  ///show when player is buffering
  final Widget buffering;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider);
    final isBuffering = ref.watch(
      playerStateProvider.select((value) => value.isBuffering),
    );
    final index = isBuffering
        ? _indexBuffering
        : isPlaying
            ? _indexPlaying
            : _indexPausing;
    return IndexedStack(
      index: index,
      alignment: Alignment.center,
      children: [pausing, playing, buffering],
    );
  }
}
