import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quiet/model/model.dart';

const MethodChannel _channel = MethodChannel("tech.soit.quiet/player");

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
      this.playWhenReady = false,
      this.buffered = const [],
      this.playbackState = PlaybackState.none,
      this.current,
      this.playingList = const [],
      this.token,
      this.playMode = PlayMode.sequence,
      this.errorMsg = _ERROR_NONE});

  static const String _ERROR_NONE = "NONE";

  PlayerControllerState.uninitialized() : this(duration: null);

  final Duration duration;
  final Duration position;

  final List<DurationRange> buffered;

  final PlaybackState playbackState;

  ///whether playback should proceed when isReady become true
  final bool playWhenReady;

  ///audio is buffering
  bool get isBuffering => playbackState == PlaybackState.buffering && !hasError;

  ///might be null
  final Music current;

  final String errorMsg;

  final List<Music> playingList;

  final String token;

  final PlayMode playMode;

  bool get initialized => duration != null;

  bool get hasError => errorMsg != _ERROR_NONE;

  bool get isPlaying => (playbackState == PlaybackState.ready) && playWhenReady && !hasError;

  PlayerControllerState clearError() {
    if (!hasError) {
      return this;
    }
    return copyWith(errorMsg: _ERROR_NONE);
  }

  PlayerControllerState copyWith({
    Duration duration,
    Duration position,
    bool playWhenReady,
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
        playWhenReady: playWhenReady ?? this.playWhenReady,
        errorMsg: errorMsg ?? this.errorMsg,
        buffered: buffered ?? this.buffered,
        playbackState: playbackState ?? this.playbackState,
        playingList: playingList ?? this.playingList,
        current: current ?? this.current,
        playMode: playMode ?? this.playMode,
        token: token ?? this.token);
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

enum PlaybackState { none, buffering, ready, ended }

///channel contract with platform player service
class PlayerController extends ValueNotifier<PlayerControllerState> {
  PlayerController._() : super(PlayerControllerState.uninitialized()) {
    _init();
  }

  static PlayerController _instance;

  factory PlayerController() {
    if (_instance == null) _instance = PlayerController._();
    return _instance;
  }

  void _init() {
    _channel.setMethodCallHandler((method) async {
      switch (method.method) {
        case "onPlayerStateChanged":
          PlaybackState newState;
          bool playWhenReady = method.arguments["playWhenReady"];
          switch (method.arguments["playbackState"]) {
            case 1:
              newState = PlaybackState.none;
              break;
            case 2:
              newState = PlaybackState.buffering;
              break;
            case 3:
              newState = PlaybackState.ready;
              break;
            case 4:
              newState = PlaybackState.ended;
              break;
          }
          value = value.copyWith(playbackState: newState, playWhenReady: playWhenReady).clearError();
          break;
        case "onPlayerError":
          value = value.copyWith(
              errorMsg: method.arguments["message"], playWhenReady: false, playbackState: PlaybackState.none);
          debugPrint("on player error : ${method.arguments}");
          break;
        case "onMusicChanged":
          value = value.copyWith(current: Music.fromMap(method.arguments));
          break;
        case "onPlaylistUpdated":
          var map = method.arguments as Map;
          value = value.copyWith(
              playingList: (map["list"] as List).cast<Map>().map(Music.fromMap).toList(), token: map["token"]);
          break;
        case "onPositionChanged":
          value = value.copyWith(
              position: Duration(milliseconds: method.arguments["position"]),
              duration: Duration(milliseconds: method.arguments["duration"]));
          break;
        case "onPlayModeChanged":
          value = value.copyWith(playMode: PlayMode.values[method.arguments % 3]);
          break;
      }
    });
  }

  ///return the previous of current playing music
  Future<Music> getPrevious() async {
    return Music.fromMap(await _channel.invokeMethod("getPrevious"));
  }

  ///return the next of current playing music
  Future<Music> getNext() async {
    return Music.fromMap(await _channel.invokeMethod("getNext"));
  }

  ///play next music
  Future<void> playNext() {
    return _channel.invokeMethod("playNext");
  }

  ///play previous music
  Future<void> playPrevious() {
    return _channel.invokeMethod("playPrevious");
  }

  ///do init to player
  ///if player is running , will do nothing
  ///maybe should move load and restore preference logic to player service
  Future<void> init(List<Music> list, Music music, String token, PlayMode playMode) {
    return _channel.invokeMethod("init", {
      "list": list == null ? null : list.map((m) => m.toMap()).toList(),
      "music": music?.toMap(),
      "token": token,
      "playMode": playMode.index
    });
  }

  ///start player
  ///try to play current music if player is not available
  Future<void> setPlayWhenReady(bool playWhenReady) {
    return _channel.invokeMethod("setPlayWhenReady", playWhenReady);
  }

  Future<void> playWith(Music music) {
    assert(music != null);
    return _channel.invokeMethod("playWithQinDing", music.toMap());
  }

  Future<void> updatePlaylist(List<Music> musics, String token) {
    assert(musics != null && musics.isNotEmpty);
    assert(token != null);

    return _channel.invokeMethod("updatePlaylist", {
      "list": musics.map((m) => m.toMap()).toList(),
      "token": token,
    });
  }

  Future<void> setPlayMode(PlayMode playMode) {
    return _channel.invokeMethod("setPlayMode", playMode.index);
  }

  Future<void> seekTo(int position) async {
    value = value.copyWith(position: Duration(milliseconds: position));
    await _channel.invokeMethod("seekTo", position);
  }

  Future<void> setVolume(double volume) {
    return _channel.invokeMethod("setVolume", volume);
  }

  ///the position of current media
  Future<Duration> get position async {
    return Duration(milliseconds: await _channel.invokeMethod("position"));
  }

  ///this player can not be disposable
  ///this method will only close MusicPlayer
  // ignore: must_call_super
  Future<void> dispose() {
    value = PlayerControllerState.uninitialized();
    return _channel.invokeMethod("quiet");
  }
}

class FakePlayerController extends ValueNotifier<PlayerControllerState> implements PlayerController {
  FakePlayerController._private() : super(PlayerControllerState.uninitialized());

  static FakePlayerController _instance;

  factory FakePlayerController() {
    if (_instance == null) {
      _instance = FakePlayerController._private();
    }
    return _instance;
  }

  @override
  void _init() {
    //do nothing
  }

  @override
  Future<Music> getNext() async {
    if (value.playingList.isEmpty) {
      return null;
    }
    var index = value.playingList.indexOf(value.current) + 1;
    if (index == value.playingList.length) index = 0;
    return value.playingList[index];
  }

  @override
  Future<Music> getPrevious() async {
    if (value.playingList.isEmpty) {
      return null;
    }
    var index = value.playingList.indexOf(value.current) - 1;
    if (index <= -1) index = value.playingList.length - 1;
    return value.playingList[index];
  }

  @override
  Future<void> init(List<Music> list, Music music, String token, PlayMode playMode) async {
    value = value.copyWith(playingList: list, current: music, token: token, playMode: playMode);
  }

  @override
  Future<void> playNext() async {
    playWith(await getNext());
  }

  @override
  Future<void> playPrevious() async {
    playWith(await getPrevious());
  }

  @override
  Future<void> playWith(Music music) async {
    value = value.copyWith(current: music);
  }

  @override
  Future<Duration> get position => Future.value(Duration.zero);

  @override
  Future<void> seekTo(int position) async {
    //do nothing
  }

  @override
  Future<void> setPlayMode(PlayMode playMode) async {
    value = value.copyWith(playMode: playMode);
  }

  @override
  Future<void> setPlayWhenReady(bool playWhenReady) async {
    //do nothing
  }

  @override
  Future<void> setVolume(double volume) async {
    //do nothing
  }

  @override
  Future<void> updatePlaylist(List<Music> musics, String token) async {
    value = value.copyWith(playingList: musics, token: token);
  }

  @override
  // ignore: must_call_super
  Future<void> dispose() {
    value = PlayerControllerState.uninitialized();
    return Future.value();
  }
}
