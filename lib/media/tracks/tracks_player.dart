import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/persistence_player_state.dart';

import '../../repository/data/track.dart';
import 'track_list.dart';
import 'tracks_player_impl_mobile.dart';
import 'tracks_player_impl_vlc.dart';

enum RepeatMode {
  /// Repeat all the tracks.
  all,

  /// Repeat the current track.
  one,

  /// Do not repeat any tracks.
  none,
}

class TracksPlayerState with EquatableMixin {
  const TracksPlayerState({
    required this.isBuffering,
    required this.isPlaying,
    required this.playingTrack,
    required this.playingList,
    required this.duration,
    required this.volume,
  });

  final bool isBuffering;
  final bool isPlaying;
  final Track? playingTrack;
  final TrackList playingList;
  final Duration? duration;
  final double volume;

  @override
  List<Object?> get props => [
        isPlaying,
        isBuffering,
        playingTrack,
        playingList,
        duration,
        volume,
      ];
}

abstract class TracksPlayer extends StateNotifier<TracksPlayerState> {
  TracksPlayer()
      : super(const TracksPlayerState(
          isPlaying: false,
          isBuffering: false,
          playingTrack: null,
          playingList: TrackList.empty(),
          duration: null,
          volume: 0,
        ),);

  factory TracksPlayer.platform() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return TracksPlayerImplVlc();
    }
    return TracksPlayerImplMobile();
  }

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

  void restoreFromPersistence(PersistencePlayerState state);

  Track? get current;

  TrackList get trackList;

  RepeatMode get repeatMode;

  bool get isPlaying;

  bool get isBuffering;

  Duration? get position;

  Duration? get duration;

  Duration? get bufferedPosition;

  double get volume;

  double get playbackSpeed;

  @protected
  void notifyPlayStateChanged() {
    state = TracksPlayerState(
      isPlaying: isPlaying,
      isBuffering: isBuffering,
      playingTrack: current,
      playingList: trackList,
      duration: duration,
      volume: volume,
    );
  }
}
