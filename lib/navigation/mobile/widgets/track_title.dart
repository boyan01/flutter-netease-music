import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../common/playlist/music_list.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.index,
  });

  final Track track;

  final int index;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (track.type == TrackType.noCopyright) {
          toast(context.strings.trackNoCopyright);
          return;
        }
        TrackTileContainer.playTrack(context, track);
      },
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            const SizedBox(width: 12),
            SizedBox(
              width: 32,
              child:
                  Center(child: _IndexOrPlayIcon(track: track, index: index)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                        color: track.type == TrackType.noCopyright
                            ? context.theme.disabledColor
                            : null,),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.displaySubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              splashRadius: 24,
              iconSize: 24,
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _IndexOrPlayIcon extends ConsumerWidget {
  const _IndexOrPlayIcon({
    super.key,
    required this.track,
    required this.index,
  });

  final Track track;

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingListId = ref.watch(playingListProvider).id;
    final playingTrack = ref.watch(playingTrackProvider);
    final isCurrent =
        TrackTileContainer.getPlaylistId(context) == playingListId &&
            playingTrack == track;
    final isPlaying = ref.watch(isPlayingProvider);
    if (isCurrent) {
      return isPlaying
          ? const Icon(Icons.volume_up, size: 24)
          : const Icon(Icons.volume_mute, size: 24);
    } else {
      return Text(
        index.toString().padLeft(2, '0'),
        style: context.textTheme.caption!.copyWith(fontSize: 15),
      );
    }
  }
}
