import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:music_player/music_player.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../component/player/player.dart';
import '../../../extension.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../../utils/system/scroll_controller.dart';
import '../../common/buttons.dart';
import '../playlists/dialog_selector.dart';

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
                const Divider(
                  height: 1,
                  thickness: 1,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) =>
                        _PlayingList(layoutHeight: constraints.maxHeight),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            context.strings.currentPlaying,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(width: 4),
          Text(
            '(${playingList.tracks.length})',
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO add play mode.
    const playMode = PlayMode.shuffle;
    final tracks = ref.watch(playingListProvider).tracks;
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          TextButton.icon(
            onPressed: () {
              // FIXME
              // context.player.setPlayMode(playMode.next);
            },
            icon: Icon(playMode.icon),
            label: Text(playMode.name),
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.textPrimary,
            ),
          ),
          const Spacer(),
          AppIconButton(
            onPressed: () async {
              final ids = tracks.map((m) => m.id).toList();
              if (ids.isEmpty) {
                return;
              }
              final succeed =
                  await PlaylistSelectorDialog.addSongs(context, ids);
              if (succeed == null) {
                return;
              }
              if (succeed) {
                showSimpleNotification(const Text('添加到收藏成功'));
              } else {
                showSimpleNotification(
                  const Text('添加到收藏失败'),
                  leading: const Icon(Icons.error),
                  background: Theme.of(context).errorColor,
                );
              }
            },
            icon: Icons.add_box,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              Navigator.pop(context);
              //FIXME
//                  context.player.setPlayList(PlayList.empty());
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
    // final isPlaying = ref.watch(isPlayingProvider);

    Widget leading;
    Color? name;
    Color? artist;
    if (isCurrentPlaying) {
      final color = Theme.of(context).primaryColorLight;
      leading = Container(
        margin: const EdgeInsets.only(right: 8),
        child: Icon(
          Icons.volume_up,
          color: color,
          size: 18,
        ),
      );
      name = color;
      artist = color;
    } else {
      leading = Container();
      name = Theme.of(context).textTheme.bodyMedium!.color;
      artist = Theme.of(context).textTheme.bodySmall!.color;
    }
    return InkWell(
      onTap: () {
        ref.read(playerProvider).playFromMediaId(music.id);
      },
      child: SizedBox(
        height: _kHeightMusicTile,
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: <Widget>[
              leading,
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: music.name, style: TextStyle(color: name)),
                      TextSpan(
                        text: ' - ${music.displaySubtitle}',
                        style: TextStyle(color: artist, fontSize: 12),
                      )
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  // TODO
                  // context.player.removeMusicItem(music.metadata);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
