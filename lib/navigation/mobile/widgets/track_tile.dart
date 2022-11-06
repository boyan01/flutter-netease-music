import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../common/buttons.dart';
import '../../common/navigation_target.dart';
import '../../common/player/animated_playing_indicator.dart';
import '../../common/playlist/track_list_container.dart';
import '../dialog/track_menu_bottom_sheet.dart';

class TrackTile extends ConsumerWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.index,
    this.trailing,
  });

  final Track track;

  final int index;

  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        if (track.type == TrackType.noCopyright) {
          toast(context.strings.trackNoCopyright);
          return;
        }
        final player = ref.read(playerProvider);
        final controller = TrackTileContainer.controller(context);
        if (player.trackList.id == controller.playlistId) {
          ref
              .read(navigatorProvider.notifier)
              .navigate(NavigationTargetPlaying());
          if (!player.isPlaying) {
            player.play();
          }
        } else {
          controller.play(null);
        }
      },
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            const SizedBox(width: 12),
            SizedBox(
              width: 32,
              child: Center(
                child: _IndexOrPlayIndicator(track: track, index: index),
              ),
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
                          ? context.colorScheme.textDisabled
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.displaySubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppIconButton(
              icon: FluentIcons.more_vertical_20_regular,
              onPressed: () {
                showTrackMenuBottomSheet(
                  context,
                  controller: TrackTileContainer.controller(context),
                  track: track,
                );
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _IndexOrPlayIndicator extends ConsumerWidget {
  const _IndexOrPlayIndicator({
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
        TrackTileContainer.controller(context).playlistId == playingListId &&
            playingTrack?.id == track.id;
    final isPlaying = ref.watch(isPlayingProvider);
    if (isCurrent) {
      return AnimatedPlayingIndicator(playing: isPlaying);
    } else {
      return Text(
        index.toString().padLeft(2, '0'),
        style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
      );
    }
  }
}
