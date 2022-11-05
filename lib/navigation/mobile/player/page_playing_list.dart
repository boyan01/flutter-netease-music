import 'dart:math' as math;

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../media/tracks/track_list.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../../utils/system/scroll_controller.dart';
import '../../common/buttons.dart';
import '../../common/icons.dart';
import '../../common/player/animated_playing_indicator.dart';
import '../../common/player/state.dart';
import '../playlists/add_to_playlist_bottom_sheet.dart';

/// Show current playing list.
void showMobilePlayingBottomSheet(BuildContext context) => showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) {
        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context);
              },
              child: const SizedBox.expand(),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    const Spacer(),
                    SizedBox(
                      height: math.min(500, constraints.maxHeight),
                      child: const PlayingListDialog(),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
      isScrollControlled: true,
    );

class PlayingListDialog extends StatelessWidget {
  const PlayingListDialog({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Material(
            color: context.colorScheme.background,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 12),
                const _Title(),
                _Header(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => _PlayingList(
                      layoutHeight: constraints.maxHeight,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
}

class _Title extends ConsumerWidget {
  const _Title({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingList = ref.watch(playingListProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: context.strings.currentPlaying,
              style: context.textTheme.titleMedium,
            ),
            TextSpan(
              text: ' (${playingList.tracks.length})',
              style: context.textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(playingListProvider).tracks;
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          const SizedBox(width: 8),
          const PlayerRepeatModeIconButton(iconOnly: false),
          const Spacer(),
          AppIconButton(
            onPressed: () {
              if (tracks.isEmpty) {
                return;
              }
              Navigator.pop(context);
              showAddToPlaylistBottomSheet(context, tracks: tracks);
            },
            icon: FluentIcons.collections_add_20_regular,
          ),
          AppIconButton(
            icon: FluentIcons.delete_20_regular,
            onPressed: () async {
              final ret = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(context.strings.sureToClearPlayingList),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.strings.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(context.strings.clear),
                    ),
                  ],
                ),
              );

              if (ret != true) {
                return;
              }
              Navigator.pop(context);
              final player = ref.read(playerProvider);
              player.setTrackList(const TrackList.empty());
            },
          )
        ],
      ),
    );
  }
}

class _PlayingList extends HookConsumerWidget {
  const _PlayingList({super.key, required this.layoutHeight});

  final double layoutHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingList = ref.watch(playingListProvider);

    final initialOffset = useMemoized<double>(() {
      final playing = ref.read(playerStateProvider).playingTrack;
      if (playing == null) {
        return 0;
      }
      final index = playingList.tracks.indexWhere((e) => e.id == playing.id);
      if (index < 0) {
        assert(false, 'playing track should be in the playing list');
        return 0;
      }

      final offset = index * _kHeightMusicTile + _kHeightMusicTile / 2;
      if (offset <= layoutHeight / 2) {
        return 0;
      }

      final totalHeight = playingList.tracks.length * _kHeightMusicTile;
      if (totalHeight - offset <= layoutHeight / 2) {
        return totalHeight - layoutHeight;
      }

      // ensure current track is in the middle of the list.
      return offset - layoutHeight / 2;
    });

    final controller = useAppScrollController(
      initialScrollOffset: initialOffset,
    );

    return ListView.builder(
      controller: controller,
      itemCount: playingList.tracks.length,
      itemBuilder: (context, index) {
        final item = playingList.tracks[index];
        return _MusicTile(music: item);
      },
      itemExtent: _kHeightMusicTile,
    );
  }
}

const _kHeightMusicTile = 48.0;

class _MusicTile extends ConsumerWidget {
  const _MusicTile({super.key, required this.music});

  final Track music;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrentPlaying = ref.watch(
      playerStateProvider.select((value) => value.playingTrack?.id == music.id),
    );

    final isPlaying = ref.watch(isPlayingProvider);

    Widget leading;
    Color? name;
    Color? artist;
    if (isCurrentPlaying) {
      final color = context.colorScheme.primary;
      leading = Container(
        margin: const EdgeInsets.only(right: 4),
        child: AnimatedPlayingIndicator(playing: isPlaying),
      );
      name = color;
      artist = color;
    } else {
      leading = Container();
      name = context.colorScheme.textPrimary;
      artist = context.colorScheme.textHint;
    }
    return InkWell(
      onTap: () {
        if (isCurrentPlaying) {
          if (!isPlaying) {
            ref.read(playerProvider).play();
          }
          return;
        }
        ref.read(playerProvider).playFromMediaId(music.id);
      },
      child: SizedBox(
        height: _kHeightMusicTile,
        child: Row(
          children: [
            const SizedBox(width: 16),
            leading,
            if (music.isRecommend) const RecommendIcon(),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: music.name, style: TextStyle(color: name)),
                    TextSpan(
                      text: ' - ${music.artistString}',
                      style: TextStyle(color: artist, fontSize: 12),
                    )
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppIconButton(
              icon: FluentIcons.dismiss_20_regular,
              size: 18,
              onPressed: () async {
                final player = ref.read(playerProvider);
                final list = player.trackList;
                if (player.current == music) {
                  final next = await player.getNextTrack();
                  if (next == null || list.tracks.length == 1) {
                    Navigator.pop(context);
                    player.setTrackList(const TrackList.empty());
                    return;
                  }
                  await player.playFromMediaId(
                    next.id,
                    play: player.isPlaying,
                  );
                }
                player.setTrackList(
                  list.copyWith(
                    tracks: list.tracks.where((e) => e.id != music.id).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
