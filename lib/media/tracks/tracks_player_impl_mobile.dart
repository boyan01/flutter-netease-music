import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:mixin_logger/mixin_logger.dart';
import 'package:music_player/music_player.dart';

import '../../model/persistence_player_state.dart';
import '../../repository.dart';
import '../../utils/media_cache/media_cache.dart';
import 'track_list.dart';
import 'tracks_player.dart';

extension _Metadata on MusicMetadata {
  Track toTrack() {
    final List<Map<String, dynamic>> artists;
    final Map<String, dynamic>? album;

    if (extras != null) {
      artists = (jsonDecode(extras!['artists']) as List).cast();
      album = jsonDecode(extras!['album']) as Map<String, dynamic>?;
    } else {
      artists = const [];
      album = null;
    }
    return Track(
      id: int.parse(mediaId),
      name: title ?? '',
      uri: mediaUri,
      artists: artists.map(ArtistMini.fromJson).toList(),
      album: album == null ? null : AlbumMini.fromJson(album),
      imageUrl: extras?['imageUrl'] as String,
      duration: Duration(milliseconds: duration),
      type: TrackType.values.byName(extras?['fee']),
    );
  }
}

extension _Track on Track {
  MusicMetadata toMetadata() {
    return MusicMetadata(
      mediaId: id.toString(),
      title: name,
      mediaUri: uri,
      subtitle: '$name - ${artists.map((e) => e.name).join('/')}',
      extras: {
        'album': jsonEncode(album?.toJson()),
        'artists': jsonEncode(artists.map((e) => e.toJson()).toList()),
        'imageUrl': imageUrl,
        'fee': type.name,
      },
    );
  }
}

extension _TrackList on TrackList {
  PlayQueue toPlayQueue() {
    return PlayQueue(
      queueId: id,
      queueTitle: 'play_list',
      queue: tracks.map((e) => e.toMetadata()).toList(),
      extras: {
        'isUserFavoriteList': isUserFavoriteList,
        'rawPlaylistId': rawPlaylistId,
      },
    );
  }
}

extension _PlayQueue on PlayQueue {
  TrackList toTrackList() {
    if (queueId == kFmTrackListId) {
      return TrackList.fm(tracks: queue.map((e) => e.toTrack()).toList());
    }
    return TrackList.playlist(
      id: queueId,
      tracks: queue.map((e) => e.toTrack()).toList(),
      isUserFavoriteList: extras?['isUserFavoriteList'] as bool? ?? false,
      rawPlaylistId: extras?['rawPlaylistId'] as int?,
    );
  }
}

const _playModeHeart = 3;

class TracksPlayerImplMobile extends TracksPlayer {
  TracksPlayerImplMobile() {
    _player.metadataListenable.addListener(notifyPlayStateChanged);
    _player.playbackStateListenable.addListener(notifyPlayStateChanged);
    _player.playModeListenable.addListener(notifyPlayStateChanged);
  }

  final _player = MusicPlayer();

  @override
  Duration? get bufferedPosition =>
      Duration(milliseconds: _player.playbackState.bufferedPosition);

  @override
  Track? get current => _player.metadata?.toTrack();

  @override
  Duration? get duration {
    final d = _player.metadata?.duration;
    if (d == null) {
      return null;
    }
    return Duration(milliseconds: d);
  }

  @override
  Future<Track?> getNextTrack() async {
    final current = _player.metadata;
    if (current == null) {
      return null;
    }
    final next = await _player.getNextMusic(current);
    return next.toTrack();
  }

  @override
  Future<Track?> getPreviousTrack() async {
    final current = _player.metadata;
    if (current == null) {
      return null;
    }
    final previous = await _player.getPreviousMusic(current);
    return previous.toTrack();
  }

  @override
  Future<void> insertToNext(Track track) async {
    _player.insertToNext(track.toMetadata());
  }

  @override
  bool get isPlaying =>
      _player.value.playbackState.state == PlayerState.Playing;

  @override
  Future<void> pause() async {
    await _player.transportControls.pause();
  }

  @override
  Future<void> play() {
    return _player.transportControls.play();
  }

  @override
  Future<void> playFromMediaId(int trackId, {bool play = true}) async {
    if (play) {
      await _player.transportControls.playFromMediaId(trackId.toString());
    } else {
      await _player.transportControls.prepareFromMediaId(trackId.toString());
    }
  }

  @override
  double get playbackSpeed => _player.playbackState.speed;

  @override
  Duration? get position {
    final p = _player.playbackState.computedPosition;
    return Duration(milliseconds: p);
  }

  @override
  RepeatMode get repeatMode {
    final playMode = _player.playMode;
    if (playMode == PlayMode.sequence) {
      return RepeatMode.sequence;
    } else if (playMode == PlayMode.shuffle) {
      return RepeatMode.shuffle;
    } else if (playMode == PlayMode.single) {
      return RepeatMode.single;
    } else if (playMode.index == _playModeHeart) {
      return RepeatMode.heart;
    } else {
      assert(false, 'unknown play mode: $playMode');
      return RepeatMode.sequence;
    }
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _player.transportControls.seekTo(position.inMilliseconds);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) {
    return _player.transportControls.setPlaybackSpeed(speed);
  }

  @override
  Future<void> setRepeatMode(RepeatMode repeatMode) async {
    final PlayMode playMode;
    switch (repeatMode) {
      case RepeatMode.shuffle:
        playMode = PlayMode.shuffle;
        break;
      case RepeatMode.single:
        playMode = PlayMode.single;
        break;
      case RepeatMode.sequence:
        playMode = PlayMode.sequence;
        break;
      case RepeatMode.heart:
        playMode = PlayMode.undefined(_playModeHeart);
        break;
    }
    await _player.transportControls.setPlayMode(playMode);
  }

  @override
  void setTrackList(TrackList trackList) {
    _player.setPlayQueue(trackList.toPlayQueue());
  }

  @override
  Future<void> setVolume(double volume) async {
    // no need to implement
  }

  @override
  Future<void> skipToNext() {
    return _player.transportControls.skipToNext();
  }

  @override
  Future<void> skipToPrevious() {
    return _player.transportControls.skipToPrevious();
  }

  @override
  Future<void> stop() {
    // FIXME stop impl
    return _player.transportControls.pause();
  }

  @override
  TrackList get trackList => _player.queue.toTrackList();

  @override
  double get volume => 1;

  @override
  bool get isBuffering => _player.playbackState.state == PlayerState.Buffering;

  @override
  void restoreFromPersistence(PersistencePlayerState state) {
    _player.setPlayQueue(state.playingList.toPlayQueue());
    setRepeatMode(state.repeatMode);
    if (state.playingTrack != null) {
      _player.transportControls
          .prepareFromMediaId(state.playingTrack!.id.toString());
    }
  }
}

void runMobileBackgroundService() {
  runBackgroundService(
    imageLoadInterceptor: _loadImageInterceptor,
    playUriInterceptor: _playUriInterceptor,
    playQueueInterceptor: _PlayQueueInterceptor(),
  );
}

// 获取播放地址
Future<String> _playUriInterceptor(String? mediaId, String? fallbackUri) async {
  final trackId = int.parse(mediaId!);
  final result = await neteaseRepository!.getPlayUrl(trackId);

  if (result.isError) {
    e('get play url error: ${result.asError!.error}');
  }

  final url = result.isError
      ? fallbackUri
      : result.asValue!.value.replaceFirst('http://', 'https://');
  if (url == null) {
    return '';
  }
  final proxyUrl = await generateTrackProxyUrl(trackId, url);
  d('play url: $proxyUrl');
  return proxyUrl;
}

Future<Uint8List> _loadImageInterceptor(MusicMetadata metadata) async {
  final stream = CachedImage(metadata.iconUri.toString()).resolve(
    ImageConfiguration(
      size: const Size(150, 150),
      devicePixelRatio: WidgetsBinding.instance.window.devicePixelRatio,
    ),
  );
  final image = Completer<ImageInfo>();
  stream.addListener(
    ImageStreamListener(
      (info, a) {
        image.complete(info);
      },
      onError: image.completeError,
    ),
  );
  final result = await image.future
      .then((image) => image.image.toByteData(format: ImageByteFormat.png))
      .then((byte) => byte!.buffer.asUint8List())
      .timeout(const Duration(seconds: 10));
  debugPrint('load image for : ${metadata.title} ${result.length}');
  return result;
}

class _PlayQueueInterceptor extends PlayQueueInterceptor {
  @override
  Future<MusicMetadata?> onPlayNextNoMoreMusic(
    BackgroundPlayQueue queue,
    PlayMode playMode,
  ) async {
    if (playMode.index == _playModeHeart) {
      final current = player!.metadata?.mediaId;
      if (current == null) {
        return null;
      }
      var index =
          queue.queue.indexWhere((element) => element.mediaId == current) + 1;
      if (index >= queue.queue.length) {
        index = 0;
      }
      return queue.queue[index];
    }
    return super.onPlayNextNoMoreMusic(queue, playMode);
  }

  @override
  Future<MusicMetadata> onPlayPreviousNoMoreMusic(
    BackgroundPlayQueue queue,
    PlayMode playMode,
  ) {
    if (playMode.index == _playModeHeart) {
      final current = player!.metadata?.mediaId;
      if (current == null) {
        return Future.value(queue.queue.last);
      }
      var index =
          queue.queue.indexWhere((element) => element.mediaId == current) - 1;
      if (index < 0) {
        index = queue.queue.length - 1;
      }
      return Future.value(queue.queue[index]);
    }
    return super.onPlayPreviousNoMoreMusic(queue, playMode);
  }

  @override
  Future<List<MusicMetadata>> fetchMoreMusic(
    BackgroundPlayQueue queue,
    PlayMode playMode,
  ) async {
    if (queue.queueId == kFmTrackListId) {
      final musics = await neteaseRepository!.getPersonalFmMusics();
      if (musics.isError) {
        return [];
      }
      return musics.asValue!.value.map((m) => m.toMetadata()).toList();
    }
    return super.fetchMoreMusic(queue, playMode);
  }
}
