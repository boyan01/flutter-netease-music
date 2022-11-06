import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../extension.dart';

import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../common/icons.dart';
import '../../common/navigation_target.dart';
import '../../common/playlist/track_list_container.dart';

class PlaylistCollapsedTitle extends StatelessWidget {
  const PlaylistCollapsedTitle({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              text,
              style: context.textTheme.titleLarge,
            ),
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                splashRadius: 20,
                tooltip: context.strings.playAll,
                icon: const PlayIcon(),
                color: context.colorScheme.primary,
                onPressed: () {
                  final controller = TrackTileContainer.controller(context);
                  final state = ref.read(playerStateProvider);
                  if (state.playingList.id == controller.playlistId &&
                      state.isPlaying) {
                    ref
                        .read(navigatorProvider.notifier)
                        .navigate(NavigationTargetPlaying());
                  } else {
                    controller.play(null);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
