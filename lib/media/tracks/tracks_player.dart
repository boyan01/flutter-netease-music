import 'package:flutter/foundation.dart';

import 'track.dart';
import 'track_list.dart';

enum RepeatMode {
  /// Repeat all the tracks.
  all,

  /// Repeat the current track.
  one,

  /// Do not repeat any tracks.
  none,
}

abstract class TracksPlayer {
  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> seekTo(Duration position);

  Future<void> setVolume(double volume);

  Future<void> setPlaybackSpeed(double speed);

  Future<void> skipToNext();

  Future<void> skipToPrevious();

  Future<void> setRepeatMode(RepeatMode repeatMode);

  Future<void> playFromMediaId(int trackId);

  void setTrackList(TrackList trackList);

  Future<Track?> getNextTrack();

  Future<Track?> getPreviousTrack();

  Future<void> insertToNext(Track track);

  Track? get current;

  Listenable get onTrackChanged;

  TrackList get trackList;

  RepeatMode get repeatMode;

  bool get isPlaying;

  bool get isBuffering;

  Duration? get position;

  Duration? get duration;

  Duration? get bufferedPosition;

  double get volume;

  double get playbackSpeed;

  Listenable get onPlaybackStateChanged;

}
