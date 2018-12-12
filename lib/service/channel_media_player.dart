import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quiet/model/model.dart';

MethodChannel _channel = MethodChannel("tech.soit.quiet/player");

PlayerController quietPlayerController = PlayerController._();

class DurationRange {
  DurationRange(this.start, this.end);

  final Duration start;
  final Duration end;

  double startFraction(Duration duration) {
    return start.inMilliseconds / duration.inMilliseconds;
  }

  double endFraction(Duration duration) {
    return end.inMilliseconds / duration.inMilliseconds;
  }

  @override
  String toString() => '$runtimeType(start: $start, end: $end)';

  static DurationRange from(dynamic value) {
    final List<dynamic> pair = value;
    return DurationRange(
      Duration(milliseconds: pair[0]),
      Duration(milliseconds: pair[1]),
    );
  }
}

class PlayerControllerState {
  PlayerControllerState(
      {this.duration,
      this.position = Duration.zero,
      this.isPlayWhenReady = false,
      this.buffered = const [],
      this.playbackState = PlaybackState.none,
      this.current,
      this.playingList = const [],
      this.token,
      this.playMode = PlayMode.sequence,
      this.errorMsg});

  PlayerControllerState.uninitialized() : this(duration: null);

  final Duration duration;
  final Duration position;

  final List<DurationRange> buffered;

  final PlaybackState playbackState;

  ///whether playback should proceed when isReady become true
  final bool isPlayWhenReady;

  ///audio is buffering
  bool get isBuffering => playbackState == PlaybackState.buffering;

  final Music current;

  final String errorMsg;

  final List<Music> playingList;

  final String token;

  final PlayMode playMode;

  bool get initialized => duration != null;

  bool get hasError => errorMsg != null;

  bool get isPlaying => playbackState == PlaybackState.playing;

  PlayerControllerState copyWith({
    Duration duration,
    Duration position,
    bool isPlayWhenReady,
    String errorMsg,
    List<DurationRange> buffered,
    PlaybackState playbackState,
    Music current,
    List<Music> playingList,
    String token,
    PlayMode playMode,
  }) {
    return PlayerControllerState(
        duration: duration ?? this.duration,
        position: position ?? this.position,
        isPlayWhenReady: isPlayWhenReady ?? this.isPlayWhenReady,
        errorMsg: errorMsg ?? this.errorMsg,
        buffered: buffered ?? this.buffered,
        playbackState: playbackState ?? this.playbackState,
        playingList: playingList ?? this.playingList,
        current: current ?? this.current,
        playMode: playMode ?? this.playMode,
        token: token ?? this.token);
  }

  void insertToNext(Music music) {
    if (playingList.contains(music)) {
      return;
    }
    var index = playingList.indexOf(current) + 1;
    playingList.insert(index, music);
  }
}

///play mode determine [PlayingList] how to play next song
enum PlayMode {
  ///aways play single song
  single,

  ///play current list sequence
  sequence,

  ///random to play next song
  shuffle
}

enum PlaybackState { none, playing, paused, buffering }

class PlayerController extends ValueNotifier<PlayerControllerState> {
  PlayerController._() : super(PlayerControllerState.uninitialized()) {
    _init();
  }

  void _init() {
    _channel.setMethodCallHandler((method) {
      switch (method.method) {
        case "onPlayStateChanged":
          value = value.copyWith(
              playbackState: PlaybackState.values[method.arguments]);
          break;
        case "onPlayingMusicChanged":
          value = value.copyWith(current: Music.fromMap(method.arguments));
          break;
        case "onPlayingListChanged":
          var map = method.arguments as Map;
          value = value.copyWith(
              playingList:
                  (map["list"] as List).cast<Map>().map(Music.fromMap).toList(),
              token: map["token"]);
          break;
        case "onPositionChanged":
          value = value.copyWith(
              position: Duration(milliseconds: method.arguments));
          break;
      }
    });
  }

  ///prepare play url
  Future<void> prepare(String url) async {
    value = PlayerControllerState.uninitialized();

    final Completer<void> initializingCompleter = Completer<void>();

    _channel.invokeMethod("prepare", {"url": url}).then((result) {
      value =
          value.copyWith(duration: Duration(milliseconds: result["duration"]));
      initializingCompleter.complete(null);
    });

    return initializingCompleter.future;
  }

  Future<void> playNext() {
    return _channel.invokeMethod("playNext");
  }

  Future<void> playPrevious() {
    return _channel.invokeMethod("playPrevious");
  }

  Future<void> play({Music music}) {
    return _channel.invokeMethod("play", music == null ? null : music.toMap());
  }

  Future<void> setPlaylist(List<Music> musics, String token,
      {PlayMode playMode = PlayMode.sequence}) {
    assert(musics != null);
    value = value.copyWith(playingList: musics, token: token);
    return _channel.invokeMethod("setPlaylist", {
      "list": musics.map((m) => m.toMap()).toList(),
      "token": token,
      "playMode": playMode.index
    });
  }

  Future<void> pause() {
    return _channel.invokeMethod("pause");
  }

  Future<void> setPlayMode(PlayMode playMode) {
    return _channel.invokeMethod("setPlayMode", playMode.index);
  }

  Future<void> seekTo(int position) async {
    await _channel.invokeMethod("seekTo", {"position": position});
    value = value.copyWith(position: Duration(milliseconds: position));
  }

  Future<void> setVolume(double volume) {
    return _channel.invokeMethod("setVolume", volume);
  }

  ///the position of current media
  Future<Duration> get position async {
    return Duration(milliseconds: await _channel.invokeMethod("position"));
  }

  ///this player can not be disposable
  ///this method will only release media player
  // ignore: must_call_super
  Future<void> dispose() async {}
}
