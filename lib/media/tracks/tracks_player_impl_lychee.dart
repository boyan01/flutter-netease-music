import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lychee_player/lychee_player.dart';
import 'package:mixin_logger/mixin_logger.dart';

import '../../extension.dart';
import '../../model/persistence_player_state.dart';
import '../../repository.dart';
import '../../utils/media_cache/media_cache.dart';
import 'track_list.dart';
import 'tracks_player.dart';

extension _SecondsExt on double {
  Duration toDuration() {
    return Duration(milliseconds: (this * 1000).toInt());
  }
}

class TracksPlayerImplLychee extends TracksPlayer {
  TracksPlayerImplLychee();

  var _trackList = const TrackList.empty();
  var _shuffleTrackIds = const <int>[];

  Track? _current;

  LycheeAudioPlayer? _player;

  double _volume = 1;

  RepeatMode _repeatMode = RepeatMode.sequence;

  @override
  Duration? get bufferedPosition => null;

  @override
  Track? get current => _current;

  @override
  Duration? get duration => _player?.duration().toDuration();

  @override
  Future<Track?> getNextTrack() async {
    final shuffle = _repeatMode == RepeatMode.shuffle;
    if (_trackList.tracks.isEmpty) {
      assert(false, 'track list is empty');
      return null;
    }
    if (!shuffle) {
      final index = _trackList.tracks.cast().indexOf(current) + 1;
      if (index < _trackList.tracks.length) {
        return _trackList.tracks[index];
      }
      return _trackList.tracks.firstOrNull;
    } else {
      assert(_shuffleTrackIds.isNotEmpty, 'shuffle track ids is empty');
      if (_shuffleTrackIds.isEmpty) {
        _generateShuffleList();
      }
      final int index;
      if (current == null) {
        index = 0;
      } else {
        index = _shuffleTrackIds.indexOf(current!.id) + 1;
      }
      final int trackId;
      if (index < _shuffleTrackIds.length) {
        trackId = _shuffleTrackIds[index];
      } else {
        trackId = _shuffleTrackIds.first;
      }
      return _trackList.tracks.firstWhereOrNull((e) => e.id == trackId);
    }
  }

  @override
  Future<Track?> getPreviousTrack() async {
    final shuffle = _repeatMode == RepeatMode.shuffle;
    if (_trackList.tracks.isEmpty) {
      assert(false, 'track list is empty');
      return null;
    }
    if (!shuffle) {
      final index = _trackList.tracks.cast().indexOf(current) - 1;
      if (index >= 0) {
        return _trackList.tracks[index];
      }
      return _trackList.tracks.lastOrNull;
    } else {
      assert(_shuffleTrackIds.isNotEmpty, 'shuffle track ids is empty');
      if (_shuffleTrackIds.isEmpty) {
        _generateShuffleList();
      }
      final int index;
      if (current == null) {
        index = 0;
      } else {
        index = _shuffleTrackIds.indexOf(current!.id) - 1;
      }
      final int trackId;
      if (index >= 0) {
        trackId = _shuffleTrackIds[index];
      } else {
        trackId = _shuffleTrackIds.last;
      }
      return _trackList.tracks.firstWhereOrNull((e) => e.id == trackId);
    }
  }

  @override
  Future<void> insertToNext(Track track) async {
    final index = _trackList.tracks.cast().indexOf(current);
    if (index == -1) {
      return;
    }
    final nextIndex = index + 1;
    if (nextIndex >= _trackList.tracks.length) {
      _trackList.tracks.add(track);
    } else {
      final next = _trackList.tracks[nextIndex];
      if (next != track) {
        _trackList.tracks.insert(nextIndex, track);
      }
    }
    notifyPlayStateChanged();
  }

  @override
  bool get isBuffering => _player?.state.value == PlayerState.buffering;

  @override
  bool get isPlaying =>
      _player?.state.value == PlayerState.ready &&
      _player?.playWhenReady == true;

  @override
  Future<void> pause() async {
    _player?.playWhenReady = false;
  }

  @override
  Future<void> play() async {
    _player?.playWhenReady = true;
  }

  @override
  Future<void> playFromMediaId(int trackId) async {
    await stop();
    final item = _trackList.tracks.firstWhereOrNull((t) => t.id == trackId);
    if (item != null) {
      _playTrack(item);
    }
  }

  @override
  double get playbackSpeed => 1;

  @override
  Duration? get position => _player?.currentTime().toDuration();

  @override
  RepeatMode get repeatMode => _repeatMode;

  @override
  Future<void> seekTo(Duration position) async {
    _player?.seek(position.inMilliseconds / 1000);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    // TODO implement setPlaybackSpeed
  }

  @override
  Future<void> setRepeatMode(RepeatMode repeatMode) async {
    _repeatMode = repeatMode;
    notifyPlayStateChanged();
  }

  void _generateShuffleList() {
    _shuffleTrackIds = trackList.tracks.map((e) => e.id).toList();
    _shuffleTrackIds.shuffle();
  }

  @override
  void setTrackList(TrackList trackList) {
    final needStop = trackList.id != _trackList.id;
    if (needStop) {
      stop();
      _current = null;
    }
    _trackList = trackList;
    _generateShuffleList();
    notifyPlayStateChanged();
  }

  @override
  Future<void> setVolume(double volume) async {
    _player?.volume = volume;
    _volume = volume;
    notifyPlayStateChanged();
  }

  @override
  Future<void> skipToNext() async {
    final next = await getNextTrack();
    if (next != null) {
      _playTrack(next);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final previous = await getPreviousTrack();
    if (previous != null) {
      _playTrack(previous);
    }
  }

  @override
  Future<void> stop() async {
    _player?.playWhenReady = false;
    _player?.dispose();
    _player = null;
    _current = null;
    notifyPlayStateChanged();
  }

  @override
  TrackList get trackList => _trackList;

  @override
  double get volume => _volume;

  void _playTrack(
    Track track, {
    bool playWhenReady = true,
  }) {
    scheduleMicrotask(() async {
      final urlResult = await neteaseRepository!.getPlayUrl(track.id);
      if (urlResult.isError) {
        debugPrint('Failed to get play urlResult: ${urlResult.asError!.error}');
        return;
      }
      final url =
          await generateTrackProxyUrl(track.id, urlResult.asValue!.value);
      d('Play url: $url');
      if (_current != track) {
        // skip play. since the track is changed.
        return;
      }
      _player?.dispose();
      _player = LycheeAudioPlayer(url)
        ..playWhenReady = playWhenReady
        ..onPlayWhenReadyChanged.addListener(notifyPlayStateChanged)
        ..state.addListener(() {
          if (_player?.state.value == PlayerState.end) {
            final isSingle = _repeatMode == RepeatMode.single;
            if (isSingle) {
              _playTrack(track);
            } else {
              skipToNext();
            }
          }
          notifyPlayStateChanged();
        })
        ..volume = _volume;
    });
    _current = track;
    notifyPlayStateChanged();
  }

  @override
  void restoreFromPersistence(PersistencePlayerState state) {
    _trackList = state.playingList;
    _repeatMode = state.repeatMode;
    _generateShuffleList();
    if (state.playingTrack != null) {
      _playTrack(state.playingTrack!, playWhenReady: false);
    }
    setVolume(state.volume);
    notifyPlayStateChanged();
  }
}
