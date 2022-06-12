import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:music_player/music_player.dart';

import '../../component.dart';
import '../../model/persistence_player_state.dart';
import '../../repository.dart';
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
      artists: artists.map((artist) => ArtistMini.fromJson(artist)).toList(),
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
    );
  }
}

class TracksPlayerImplMobile extends TracksPlayer {
  TracksPlayerImplMobile() {
    _player.metadataListenable.addListener(notifyPlayStateChanged);
    _player.playbackStateListenable.addListener(notifyPlayStateChanged);
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
  Future<void> playFromMediaId(int trackId) async {
    await _player.transportControls.playFromMediaId(trackId.toString());
  }

  @override
  double get playbackSpeed => _player.playbackState.speed;

  @override
  Duration? get position {
    final p = _player.playbackState.position;
    return Duration(milliseconds: p);
  }

  // TODO
  @override
  RepeatMode get repeatMode => RepeatMode.all;

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
    // TODO
  }

  @override
  void setTrackList(TrackList trackList) {
    _player.setPlayQueue(trackList.toPlayQueue());
  }

  @override
  Future<void> setVolume(double volume) async {
    // TODO
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
  final result = await neteaseRepository!.getPlayUrl(int.parse(mediaId!));
  if (result.isError) {
    return fallbackUri ?? '';
  }

  /// some devices do not support http request.
  return result.asValue!.value.replaceFirst('http://', 'https://');
}

Future<Uint8List> _loadImageInterceptor(MusicMetadata metadata) async {
  final ImageStream stream =
      CachedImage(metadata.iconUri.toString()).resolve(ImageConfiguration(
    size: const Size(150, 150),
    devicePixelRatio: WidgetsBinding.instance.window.devicePixelRatio,
  ));
  final image = Completer<ImageInfo>();
  stream.addListener(ImageStreamListener((info, a) {
    image.complete(info);
  }, onError: (exception, stackTrace) {
    image.completeError(exception, stackTrace);
  }));
  final result = await image.future
      .then((image) => image.image.toByteData(format: ImageByteFormat.png))
      .then((byte) => byte!.buffer.asUint8List())
      .timeout(const Duration(seconds: 10));
  debugPrint('load image for : ${metadata.title} ${result.length}');
  return result;
}

class _PlayQueueInterceptor extends PlayQueueInterceptor {
  @override
  Future<List<MusicMetadata>> fetchMoreMusic(
      BackgroundPlayQueue queue, PlayMode playMode) async {
    if (queue.queueId == kFmPlayQueueId) {
      final musics = await neteaseRepository!.getPersonalFmMusics();
      if (musics.isError) {
        return [];
      }
      return musics.asValue!.value.map((m) => m.toMetadata()).toList();
    }
    return super.fetchMoreMusic(queue, playMode);
  }
}
