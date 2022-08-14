import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lychee_player/lychee_player.dart';

import '../../extension.dart';
import '../../model/persistence_player_state.dart';
import '../../repository.dart';
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

  Track? _current;

  LycheeAudioPlayer? _player;

  double _volume = 1;

  @override
  Duration? get bufferedPosition => null;

  @override
  Track? get current => _current;

  @override
  Duration? get duration => _player?.duration().toDuration();

  @override
  Future<Track?> getNextTrack() async {
    final index = _trackList.tracks.cast().indexOf(current);
    if (index == -1) {
      return _trackList.tracks.firstOrNull;
    }
    final nextIndex = index + 1;
    if (nextIndex >= _trackList.tracks.length) {
      return null;
    }
    return _trackList.tracks[nextIndex];
  }

  @override
  Future<Track?> getPreviousTrack() async {
    final index = _trackList.tracks.cast().indexOf(current);
    if (index == -1) {
      return _trackList.tracks.lastOrNull;
    }
    final previousIndex = index - 1;
    if (previousIndex < 0) {
      return null;
    }
    return _trackList.tracks[previousIndex];
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
  RepeatMode get repeatMode => RepeatMode.all;

  @override
  Future<void> seekTo(Duration position) async {
    _player?.seek(position.inMilliseconds / 1000);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    // TODO implement setPlaybackSpeed
  }

  @override
  Future<void> setRepeatMode(RepeatMode repeatMode) async {}

  @override
  void setTrackList(TrackList trackList) {
    final needStop = trackList.id != _trackList.id;
    if (needStop) {
      stop();
      _current = null;
    }
    _trackList = trackList;
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
      final url = await neteaseRepository!.getPlayUrl(track.id);
      if (url.isError) {
        debugPrint('Failed to get play url: ${url.asError!.error}');
        return;
      }
      if (_current != track) {
        // skip play. since the track is changed.
        return;
      }
      _player?.dispose();
      _player = LycheeAudioPlayer(url.asValue!.value)
        ..playWhenReady = playWhenReady
        ..onPlayWhenReadyChanged.addListener(notifyPlayStateChanged)
        ..state.addListener(() {
          if (_player?.state.value == PlayerState.end) {
            skipToNext();
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
    if (state.playingTrack != null) {
      _playTrack(state.playingTrack!, playWhenReady: false);
    }
    setVolume(state.volume);
    notifyPlayStateChanged();
  }
}
