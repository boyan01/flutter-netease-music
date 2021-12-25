import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';

import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../common/icons.dart';
import '../../common/navigation_target.dart';
import '../../common/playlist/music_list.dart';

class PlaylistCollapsedTitle extends StatelessWidget {
  const PlaylistCollapsedTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              text,
              style: context.primaryTextTheme.titleLarge,
            ),
          ),
          const SizedBox(width: 8),
          Consumer(builder: (context, ref, child) {
            return IconButton(
              splashRadius: 20,
              tooltip: context.strings.playAll,
              icon: const PlayIcon(),
              color: context.colorScheme.primary,
              onPressed: () {
                final id = TrackTileContainer.getPlaylistId(context);
                final state = ref.read(playerStateProvider);
                if (state.playingList.id == id && state.isPlaying) {
                  ref
                      .read(navigatorProvider.notifier)
                      .navigate(NavigationTargetPlaying());
                } else {
                  TrackTileContainer.playTrack(context, null);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
