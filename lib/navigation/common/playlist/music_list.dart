import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../media/tracks/track_list.dart';
import '../../../media/tracks/tracks_player.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/playlist_detail_provider.dart';
import '../../../repository.dart';
import '../../mobile/playlists/dialog_selector.dart';
import '../navigation_target.dart';

enum PlayResult {
  success,
  alreadyPlaying,
  fail,
}

extension _TracksPlayer on TracksPlayer {
  PlayResult playWithList(
    String listId,
    List<Track> tracks, {
    Track? track,
    bool isUserFavoriteList = false,
    int? rawPlaylistId,
  }) {
    if (!trackList.isFM && trackList.id == listId && current == track) {
      if (isPlaying) {
        return PlayResult.alreadyPlaying;
      }
      play();
      return PlayResult.success;
    } else {
      final list = TrackList.playlist(
        id: listId,
        tracks:
            tracks.whereNot((e) => e.type == TrackType.noCopyright).toList(),
        isUserFavoriteList: isUserFavoriteList,
        rawPlaylistId: rawPlaylistId,
      );
      if (list.tracks.isEmpty) {
        return PlayResult.fail;
      }
      final toPlay = track ??
          (trackList.id == listId ? current : null) ??
          list.tracks.first;
      setTrackList(list);
      playFromMediaId(toPlay.id);
      return PlayResult.success;
    }
  }
}

typedef TrackDeleteHandler = Future<void> Function(WidgetRef read, Track track);

class TrackTileContainer extends StatelessWidget {
  factory TrackTileContainer.album({
    required Album album,
    required List<Track> tracks,
    required Widget child,
    required TracksPlayer player,
  }) {
    final id = 'album_${album.id}';
    return TrackTileContainer._private(
      (track) => player.playWithList(id, tracks, track: track),
      null,
      id: id,
      tracks: tracks,
      child: child,
    );
  }

  factory TrackTileContainer.trackList({
    required List<Track> tracks,
    required Widget child,
    required TracksPlayer player,
    required String id,
  }) {
    return TrackTileContainer._private(
      (track) => player.playWithList(id, tracks, track: track),
      null,
      id: id,
      tracks: tracks,
      child: child,
    );
  }

  factory TrackTileContainer.daily({
    required List<Track> tracks,
    required DateTime dateTime,
    required Widget child,
    required TracksPlayer player,
  }) {
    final id =
        'daily_playlist_${dateTime.year}_${dateTime.month}_${dateTime.day}';
    return TrackTileContainer.trackList(
      tracks: tracks,
      player: player,
      id: id,
      child: child,
    );
  }

  factory TrackTileContainer.cloudTracks({
    required List<Track> tracks,
    required Widget child,
    required TracksPlayer player,
  }) {
    return TrackTileContainer.trackList(
      tracks: tracks,
      player: player,
      id: 'user_cloud_tracks',
      child: child,
    );
  }

  factory TrackTileContainer.playlist({
    required PlaylistDetail playlist,
    required Widget child,
    required TracksPlayer player,
    required bool skipAccompaniment,
    int? userId,
  }) {
    final id = 'playlist_${playlist.id}';
    final isUserPlaylist = userId != null && playlist.creator.userId == userId;
    return TrackTileContainer._private(
      (track) {
        final List<Track> tracks;
        if (skipAccompaniment) {
          tracks = playlist.tracks
              .whereNot((value) => value.name.contains('伴奏'))
              .toList();
        } else {
          tracks = playlist.tracks;
        }
        return player.playWithList(
          id,
          tracks,
          track: track,
          isUserFavoriteList: playlist.isFavorite,
          rawPlaylistId: playlist.id,
        );
      },
      isUserPlaylist
          ? (ref, track) async {
              await ref
                  .read(playlistDetailProvider(playlist.id).notifier)
                  .removeTrack(track);
            }
          : null,
      tracks: playlist.tracks,
      id: id,
      child: child,
    );
  }

  /// Difference [TrackTileContainer.trackList]
  /// Track item will only be insert to current playing list.
  factory TrackTileContainer.simpleList({
    required List<Track> tracks,
    required Widget child,
    required TracksPlayer player,
    TrackDeleteHandler? onDelete,
  }) {
    return TrackTileContainer._private(
      (track) {
        assert(track != null);
        if (track == null) {
          return PlayResult.fail;
        }
        if (player.trackList.isFM) {
          return player.playWithList('', [track], track: track);
        } else {
          player
            ..insertToNext(track)
            ..playFromMediaId(track.id);
          return PlayResult.success;
        }
      },
      onDelete,
      tracks: tracks,
      id: '',
      child: child,
    );
  }

  const TrackTileContainer._private(
    this._playbackMusic,
    this._deleteMusic, {
    super.key,
    required this.tracks,
    required this.id,
    required this.child,
  });

  static PlayResult playTrack(
    BuildContext context,
    Track? track,
  ) {
    final container =
        context.findAncestorWidgetOfExactType<TrackTileContainer>();
    assert(container != null, 'container is null');
    if (container == null) {
      return PlayResult.fail;
    }
    return container._playbackMusic(track);
  }

  static String getPlaylistId(BuildContext context) {
    final container =
        context.findAncestorWidgetOfExactType<TrackTileContainer>();
    assert(container != null, 'container is null');
    if (container == null) {
      return '';
    }
    return container.id;
  }

  static Future<void> deleteTrack(
    BuildContext context,
    WidgetRef ref,
    Track track,
  ) {
    final container =
        context.findAncestorWidgetOfExactType<TrackTileContainer>();
    assert(container != null, 'container is null');
    if (container == null) {
      return Future.value();
    }
    assert(container._deleteMusic != null, 'deleteMusic is null');
    return container._deleteMusic?.call(ref, track) ?? Future.value();
  }

  static bool canDeleteTrack(BuildContext context) {
    final container =
        context.findAncestorWidgetOfExactType<TrackTileContainer>();
    assert(container != null, 'container is null');
    if (container == null) {
      return false;
    }
    return container._deleteMusic != null;
  }

  final List<Track> tracks;

  final String id;

  final Widget child;

  final PlayResult Function(Track?) _playbackMusic;

  final TrackDeleteHandler? _deleteMusic;

  @override
  Widget build(BuildContext context) => child;
}

class MusicTileConfiguration extends StatelessWidget {
  const MusicTileConfiguration({
    super.key,
    this.token,
    required this.musics,
    this.onMusicTap = MusicTileConfiguration.defaultOnTap,
    this.child,
    this.leadingBuilder = MusicTileConfiguration.indexedLeadingBuilder,
    this.trailingBuilder = MusicTileConfiguration.defaultTrailingBuilder,
    this.supportAlbumMenu = true,
    this.remove,
  });

  static MusicTileConfiguration of(BuildContext context) {
    final list =
        context.findAncestorWidgetOfExactType<MusicTileConfiguration>();
    assert(list != null, 'you can only use [MusicTile] inside MusicList scope');
    return list!;
  }

  static Widget defaultTrailingBuilder(BuildContext context, Music music) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[IconMV(music), _IconMore(music)],
    );
  }

  static Widget indexedLeadingBuilder(BuildContext context, Music music) {
    final index = MusicTileConfiguration.of(context).musics.indexOf(music) + 1;
    return _buildPlayingLeading(context, music) ??
        Container(
          margin: const EdgeInsets.only(left: 8, right: 8),
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              index.toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        );
  }

  static Widget coverLeadingBuilder(BuildContext context, Music music) {
    return _buildPlayingLeading(context, music) ??
        Container(
          margin: const EdgeInsets.only(left: 8, right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: FadeInImage(
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              image: CachedImage(music.imageUrl?.toString() ?? ''),
              placeholder: const AssetImage('assets/playlist_playlist.9.png'),
            ),
          ),
        );
  }

  //return null if current music is not be playing
  static Widget? _buildPlayingLeading(BuildContext context, Music music) {
    // TODO remove this.
    return null;
  }

  static void defaultOnTap(BuildContext context, Music music) {
    // TODO remove this.
  }

  final String? token;

  final List<Music> musics;

  final void Function(BuildContext context, Music muisc) onMusicTap;

  final Widget Function(BuildContext context, Music music) leadingBuilder;

  final Widget Function(BuildContext context, Music music) trailingBuilder;

  final bool supportAlbumMenu;

  final void Function(Music music)? remove;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return child!;
  }
}

/// music item widget
class MusicTile extends StatelessWidget {
  const MusicTile(this.music, {super.key});

  final Music music;

  @override
  Widget build(BuildContext context) {
    final list = MusicTileConfiguration.of(context);
    return SizedBox(
      height: 56,
      child: InkWell(
        onTap: () {
          list.onMusicTap.call(context, music);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (list.leadingBuilder)(context, music),
            Expanded(
              child: _SimpleMusicTile(music),
            ),
            (list.trailingBuilder)(context, music),
          ],
        ),
      ),
    );
  }
}

class _SimpleMusicTile extends StatelessWidget {
  const _SimpleMusicTile(this.music, {super.key});

  final Music music;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Spacer(),
                Text(
                  music.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Padding(padding: EdgeInsets.only(top: 3)),
                Text(
                  music.displaySubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The header view of MusicList
class MusicListHeader extends ConsumerWidget implements PreferredSizeWidget {
  const MusicListHeader(this.count, {this.tail, super.key});

  final int count;

  final Widget? tail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: context.colorScheme.background,
      child: InkWell(
        onTap: () {
          final player = ref.read(playerProvider);
          final state = ref.read(playerStateProvider);
          final list = MusicTileConfiguration.of(context);
          if (state.playingList.id == list.token && state.isPlaying) {
            ref
                .read(navigatorProvider.notifier)
                .navigate(NavigationTargetPlaying());
          } else {
            player
              ..setTrackList(
                TrackList.playlist(
                  id: list.token!,
                  tracks: list.musics,
                  rawPlaylistId: null,
                ),
              )
              ..play();
          }
        },
        child: SizedBox.fromSize(
          size: preferredSize,
          child: Row(
            children: [
              const SizedBox(width: 16),
              SizedBox.square(
                dimension: 24,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      FluentIcons.play_circle_20_filled,
                      color: context.colorScheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.strings.playAll,
                style: context.textTheme.titleSmall,
              ),
              const SizedBox(width: 6),
              Text(
                '(${context.strings.musicCountFormat(count)})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (tail != null) tail!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class IconMV extends StatelessWidget {
  const IconMV(this.music, {super.key});

  final Music music;

  @override
  Widget build(BuildContext context) {
    // TODO add MV.
    return Container();
  }
}

enum _MusicAction {
  addToNext,
  delete,

  ///添加到歌单
  addToPlaylist,

  ///导航到专辑
  album,

  ///导航到歌手
  artists,
}

class _IconMore extends ConsumerWidget {
  const _IconMore(this.music, {super.key});

  final Music music;

  List<PopupMenuItem> _buildMenu(BuildContext context) {
    final items = [
      const PopupMenuItem(
        value: _MusicAction.addToNext,
        child: Text('下一首播放'),
      ),
      const PopupMenuItem(
        value: _MusicAction.addToPlaylist,
        child: Text('收藏到歌单'),
      ),
    ];

    items.add(
      PopupMenuItem(
        enabled: music.artists.fold(0, (dynamic c, ar) => c + ar.id) != 0,
        value: _MusicAction.artists,
        child: Text(
          "歌手: ${music.artists.map((a) => a.name).join('/')}",
          maxLines: 1,
        ),
      ),
    );

    if (MusicTileConfiguration.of(context).supportAlbumMenu) {
      items.add(
        const PopupMenuItem(
          value: _MusicAction.album,
          child: Text('专辑'),
        ),
      );
    }
    if (MusicTileConfiguration.of(context).remove != null) {
      items.add(
        const PopupMenuItem(
          value: _MusicAction.delete,
          child: Text('删除'),
        ),
      );
    }
    return items;
  }

  Future<void> _handleMusicAction(
    BuildContext context,
    _MusicAction type,
    WidgetRef ref,
  ) async {
    switch (type) {
      case _MusicAction.addToNext:
        await ref.read(playerProvider).insertToNext(music);
        break;
      case _MusicAction.delete:
        MusicTileConfiguration.of(context).remove!(music);
        break;
      case _MusicAction.addToPlaylist:
        final id = await showDialog(
          context: context,
          builder: (context) {
            return const PlaylistSelectorDialog();
          },
        );
        if (id != null) {
          final succeed = await neteaseRepository!
              .playlistTracksEdit(PlaylistOperation.add, id, [music.id]);
          final scaffold = Scaffold.maybeOf(context);
          if (scaffold == null) {
            //not notify when scaffold is empty
            return;
          }
          if (succeed) {
            showSimpleNotification(const Text('已添加到收藏'));
          } else {
            showSimpleNotification(
              const Text('收藏歌曲失败!'),
              leading: const Icon(Icons.error),
              background: Theme.of(context).errorColor,
            );
          }
        }
        break;
      case _MusicAction.album:
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        //   return AlbumDetailPage(albumId: music.album!.id.parseToInt());
        // }));
        break;
      case _MusicAction.artists:
        // launchArtistDetailPage(context, music.artists);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      itemBuilder: _buildMenu,
      onSelected: (dynamic type) => _handleMusicAction(context, type, ref),
    );
  }
}
