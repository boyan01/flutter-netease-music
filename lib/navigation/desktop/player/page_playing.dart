import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../component.dart';

import '../../../providers/player_provider.dart';
import '../../common/player/cover.dart';
import '../../common/player/player_actions.dart';
import 'lyric_layout.dart';

class PagePlaying extends StatelessWidget {
  const PagePlaying({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      elevation: 10,
      child: Row(
        children: [
          const Flexible(flex: 5, child: _LayoutCover()),
          Flexible(
            flex: 4,
            child: Consumer(builder: (context, ref, child) {
              return LyricLayout(track: ref.watch(playingTrackProvider)!);
            }),
          ),
        ],
      ),
    );
  }
}

// left cover layout
class _LayoutCover extends ConsumerWidget {
  const _LayoutCover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: IgnorePointer(
              ignoring: true,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AlbumCover(music: ref.watch(playingTrackProvider)!),
              ),
            ),
          ),
          const Spacer(),
          PlayingOperationBar(iconColor: context.iconTheme.color),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
