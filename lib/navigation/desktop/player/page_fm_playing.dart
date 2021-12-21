import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/common/like_button.dart';
import 'package:quiet/providers/player_provider.dart';

import 'lyric_layout.dart';

class PageFmPlaying extends StatelessWidget {
  const PageFmPlaying({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      child: Row(
        children: const [
          Flexible(flex: 5, child: _CoverLayout()),
          Flexible(flex: 5, child: LyricLayout()),
        ],
      ),
    );
  }
}

class _CoverLayout extends ConsumerWidget {
  const _CoverLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(playingTrackProvider)!;
    return Column(
      children: [
        const SizedBox(height: 80),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image(
            image: CachedImage(track.imageUrl!),
            width: 300,
            height: 300,
          ),
        ),
        const Spacer(),
        const _FmButtonBars(),
        const Spacer(),
      ],
    );
  }
}

class _FmButtonBars extends ConsumerWidget {
  const _FmButtonBars({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        LikeButton(
          music: ref.watch(playingTrackProvider)!,
          iconSize: 24,
        ),
        IconButton(
          splashRadius: 24,
          iconSize: 24,
          onPressed: () {},
          icon: const Icon(Icons.delete_rounded),
        ),
        IconButton(
          splashRadius: 24,
          iconSize: 24,
          onPressed: () {},
          icon: const Icon(Icons.skip_next_rounded),
        ),
        IconButton(
          splashRadius: 24,
          iconSize: 24,
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }
}
