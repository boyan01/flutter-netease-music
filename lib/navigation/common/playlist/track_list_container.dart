import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart';

import '../../../extension.dart';
import '../../../media/tracks/track_list.dart';
import '../../../media/tracks/tracks_player.dart';
import '../../../providers/key_value/settings_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/playlist_detail_provider.dart';
import '../../../providers/repository_provider.dart';
import '../../../repository.dart';
import '../navigation_target.dart';

enum PlayResult {
  success,
  alreadyPlaying,
  fail,
}

typedef PlayTrackAction = FutureOr<PlayResult> Function(
  WidgetRef ref,
  Track? track,
);

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

abstract class TrackListController {
  FutureOr<PlayResult> play(Track? track);

  String get playlistId;

  Future<void> delete(Track track);

  bool get canDelete;
}

class TrackTileContainer extends ConsumerStatefulWidget {
  factory TrackTileContainer.album({
    required Album album,
    required List<Track> tracks,
    required Widget child,
  }) {
    final id = 'album_${album.id}';
    return TrackTileContainer._private(
      (ref, track) {
        final player = ref.read(playerProvider);
        return player.playWithList(id, tracks, track: track);
      },
      null,
      id: id,
      tracks: tracks,
      child: child,
    );
  }

  factory TrackTileContainer.trackList({
    required List<Track> tracks,
    required Widget child,
    required String id,
  }) {
    return TrackTileContainer._private(
      (ref, track) {
        final player = ref.read(playerProvider);
        return player.playWithList(id, tracks, track: track);
      },
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
  }) {
    final id =
        'daily_playlist_${dateTime.year}_${dateTime.month}_${dateTime.day}';
    return TrackTileContainer.trackList(
      tracks: tracks,
      id: id,
      child: child,
    );
  }

  factory TrackTileContainer.cloudTracks({
    required List<Track> tracks,
    required Widget child,
  }) {
    return TrackTileContainer.trackList(
      tracks: tracks,
      id: 'user_cloud_tracks',
      child: child,
    );
  }

  factory TrackTileContainer.playlist({
    required PlaylistDetail playlist,
    required Widget child,
    int? userId,
  }) {
    final id = 'playlist_${playlist.id}';
    final isUserPlaylist = userId != null && playlist.creator.userId == userId;
    return TrackTileContainer._private(
      (ref, track) async {
        final player = ref.read(playerProvider);
        final skipAccompaniment =
            ref.read(settingKeyValueProvider).skipAccompaniment;
        final List<Track> tracks;
        if (skipAccompaniment) {
          tracks = playlist.tracks
              .whereNot((value) => value.name.contains('伴奏'))
              .toList();
        } else {
          tracks = playlist.tracks;
        }

        if (player.repeatMode == RepeatMode.heart && playlist.isMyFavorite) {
          try {
            final toPlay = track ?? tracks.firstOrNull;
            if (toPlay == null) {
              return PlayResult.fail;
            }
            final list = await ref
                .read(neteaseRepositoryProvider)
                .playModeIntelligenceList(
                  id: toPlay.id,
                  playlistId: playlist.id,
                );
            return player.playWithList(
              id,
              [toPlay, ...list],
              track: toPlay,
              isUserFavoriteList: true,
              rawPlaylistId: playlist.id,
            );
          } catch (error, stacktrace) {
            e('error: $error, $stacktrace');
            return PlayResult.fail;
          }
        } else {
          if (player.repeatMode == RepeatMode.heart) {
            player.setRepeatMode(RepeatMode.sequence);
          }
          return player.playWithList(
            id,
            tracks,
            track: track,
            isUserFavoriteList: playlist.isMyFavorite,
            rawPlaylistId: playlist.id,
          );
        }
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
    TrackDeleteHandler? onDelete,
  }) {
    return TrackTileContainer._private(
      (ref, track) {
        assert(track != null);
        if (track == null) {
          return PlayResult.fail;
        }
        final player = ref.read(playerProvider);

        final insertToNext =
            !player.trackList.isFM && !player.trackList.isEmpty;
        if (insertToNext) {
          player
            ..insertToNext(track)
            ..playFromMediaId(track.id);
          return PlayResult.success;
        } else {
          return player.playWithList('simple_play_list', [track], track: track);
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

  static TrackListController controller(BuildContext context) {
    final state = context.findAncestorStateOfType<_TrackTileContainerState>();
    assert(state != null, 'Can not find TrackTileContainerState');
    return state!;
  }

  final List<Track> tracks;

  final String id;

  final Widget child;

  final PlayTrackAction _playbackMusic;

  final TrackDeleteHandler? _deleteMusic;

  @override
  ConsumerState<TrackTileContainer> createState() => _TrackTileContainerState();
}

class _TrackTileContainerState extends ConsumerState<TrackTileContainer>
    implements TrackListController {
  @override
  Widget build(BuildContext context) => widget.child;

  @override
  bool get canDelete => widget._deleteMusic != null;

  @override
  Future<void> delete(Track track) async {
    await widget._deleteMusic?.call(ref, track);
  }

  @override
  FutureOr<PlayResult> play(Track? track) {
    final state = ref.read(playerStateProvider);

    var alreadyPlaying = state.playingList.id == playlistId && state.isPlaying;

    if (track != null) {
      alreadyPlaying = alreadyPlaying && state.playingTrack?.id == track.id;
    }
    if (alreadyPlaying) {
      ref.read(navigatorProvider.notifier).navigate(NavigationTargetPlaying());
      return PlayResult.alreadyPlaying;
    }
    return widget._playbackMusic(ref, track);
  }

  @override
  String get playlistId => widget.id;
}
