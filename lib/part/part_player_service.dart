import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:quiet/model/model.dart';
import 'package:quiet/service/channel_media_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

MusicPlayer quiet = MusicPlayer._private();

///key which save playing music to local preference
const String _PREF_KEY_PLAYING = "quiet_player_playing";

///key which save playing music list to local preference
const String _PREF_KEY_PLAYLIST = "quiet_player_playlist";

///key which save playing list token to local preference
const String _PREF_KEY_TOKEN = "quiet_player_token";

///key which save playing mode to local preference
const String _PREF_KEY_PLAY_MODE = "quiet_player_play_mode";

class MusicPlayer extends ValueNotifier<PlayerStateValue> {
  MusicPlayer._private() : super(PlayerStateValue.uninitialized()) {
    () async {
      var preference = await SharedPreferences.getInstance();
      Music current;
      List<Music> playingList;
      String token;
      PlayMode playMode;
      try {
        current = Music.fromMap(json.decode(preference.get(_PREF_KEY_PLAYING)));
        token = preference.get(_PREF_KEY_TOKEN);
        playingList = (json.decode(preference.get(_PREF_KEY_PLAYLIST)) as List)
            .cast<Map>()
            .map(Music.fromMap)
            .toList();
        playMode = PlayMode.values[preference.getInt(_PREF_KEY_PLAY_MODE) ?? 0];
      } catch (e) {
        debugPrint(e.toString());
      }

      addListener(() {
        if (current != value.current) {
          preference.setString(_PREF_KEY_PLAYING,
              json.encode(value.current, toEncodable: (e) => e.toMap()));
          current = value.current;
        }
        if (playingList != value.playlist) {
          preference.setString(_PREF_KEY_PLAYLIST,
              json.encode(value.playlist, toEncodable: (e) => e.toMap()));
          playingList = value.playlist;
        }
        if (playMode != value.playMode) {
          preference.setInt(_PREF_KEY_PLAY_MODE, value.playMode.index);
          playMode = value.playMode;
        }
        if (token != value.token) {
          preference.setString(_PREF_KEY_TOKEN, value.token);
          token = value.token;
        }
      });
      value = value.copyWith(
          current: current,
          playlist: playingList,
          playMode: playMode,
          token: token);
    }();

    ///listener player controller state
    _controller
        .addListener(() => value = value.copyWith(state: _controller.value));
    _controller.onComplete = () {
      playNext();
    };
  }

  PlayerController get _controller => quietPlayerController;

  ///play a single song
  Future<void> play({Music music}) async {
    music = music ?? value.current;
    if (music == null) {
      //null music, null current playing, this is an error state
      return;
    }
    if (!value.playlist.contains(music)) {
      value.insertToNext(music);
    }
    await _performPlay(music);
  }

  Future<void> playWithList(Music music, List<Music> list, String token) async {
    assert(list != null && token != null);
    if (list.isEmpty) {
      return;
    }
    if (music == null) {
      music = list.first;
    }
    assert(list.contains(music));

    if (value.token != token || value.playlist != list) {
      //need update playing list
      value = value.copyWith(playlist: list, token: token);
      _controller.setPlaylist(list);
    }
    _performPlay(music);
  }

  //perform to play music
  Future<void> _performPlay(Music music) async {
    assert(music != null);

    if (value.current == music && _controller.value.initialized) {
      await _controller.play();
      return;
    }
    assert(
        music.url != null && music.url.isNotEmpty, "music url can not be null");
    await _controller.play(music: music);
    //refresh state
    value = value.copyWith(current: music);
    return await _controller.play(music: music);
  }

  Future<void> pause() {
    return _controller.pause();
  }

  void quiet() {
    _controller.dispose();
    value = PlayerStateValue.uninitialized();
  }

  Future<void> playNext() async {
    await _controller.playNext();
  }

  Future<void> playPrevious() async {
    await _controller.playPrevious();
  }

  ///seek to position in milliseconds
  Future<void> seekTo(int position) {
    return _controller.seekTo(position);
  }

  Future<void> setVolume(double volume) {
    return _controller.setVolume(volume);
  }
}

///the current playing list, playing song , player state
///aways available in [PlayerState]
class PlayerStateValue {
  PlayerStateValue(
      this.state, this.playlist, this.current, this.token, this.playMode);

  PlayerStateValue.uninitialized()
      : this(PlayerControllerState.uninitialized(), const [], null, null,
            PlayMode.sequence);

  /// The duration, current position, buffering state, error state and settings
  /// of a [VideoPlayerController].
  final PlayerControllerState state;

  final List<Music> playlist;

  final PlayMode playMode;

  ///current playing music;
  final Music current;

  final String token;

  PlayerStateValue copyWith(
      {PlayerControllerState state,
      List<Music> playlist,
      Music current,
      String token,
      PlayMode playMode}) {
    return PlayerStateValue(
        state ?? this.state,
        playlist ?? this.playlist,
        current ?? this.current,
        token ?? this.token,
        playMode ?? this.playMode);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStateValue &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          playlist == other.playlist &&
          current == other.current;

  @override
  int get hashCode => state.hashCode ^ playlist.hashCode ^ current.hashCode;

  @override
  String toString() {
    return 'PlayerStateValue{state: $state, playlist: $playlist, current: $current}';
  }

  ///insert music to after of current playing
  void insertToNext(Music music) {
    playlist.insert(playlist.indexOf(current) + 1, music);
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

class Quiet extends StatefulWidget {
  Quiet({@Required() this.child, Key key}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _QuietState();
}

class _QuietState extends State<Quiet> {
  PlayerStateValue value;

  void _onPlayerChange() {
    setState(() {
      value = quiet.value;
    });
  }

  @override
  void initState() {
    value = quiet.value;
    quiet.addListener(_onPlayerChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    quiet.removeListener(_onPlayerChange);
  }

  @override
  Widget build(BuildContext context) {
    return PlayerState(
      child: widget.child,
      value: value,
    );
  }
}

class PlayerState extends InheritedModel<PlayerStateAspect> {
  PlayerState({@required Widget child, @required this.value})
      : super(child: child);

  ///get current playing music
  final PlayerStateValue value;

  static PlayerState of(BuildContext context, {PlayerStateAspect aspect}) {
    return context.inheritFromWidgetOfExactType(PlayerState, aspect: aspect);
  }

  @override
  bool updateShouldNotify(PlayerState oldWidget) {
    return value != oldWidget.value;
  }

  @override
  bool updateShouldNotifyDependent(
      PlayerState oldWidget, Set<PlayerStateAspect> dependencies) {
    if (dependencies.contains(PlayerStateAspect.position) &&
        (value.state.position != oldWidget.value.state.position)) {
      return true;
    }
    if (dependencies.contains(PlayerStateAspect.play) &&
        (value.state.isPlaying != oldWidget.value.state.isPlaying)) {
      return true;
    }
    if (dependencies.contains(PlayerStateAspect.playlist) &&
        (value.playlist != oldWidget.value.playlist)) {
      return true;
    }
    if (dependencies.contains(PlayerStateAspect.music) &&
        (value.current != oldWidget.value.current)) {
      return true;
    }
    return false;
  }
}

enum PlayerStateAspect {
  ///the position of playing
  position,

  ///the playing state
  play,

  ///the current playing
  music,

  ///the current playing playlist
  playlist
}

///format milliseconds to time stamp like "06:23", which
///means 6 minute 23 seconds
String getTimeStamp(int milliseconds) {
  int seconds = (milliseconds / 1000).truncate();
  int minutes = (seconds / 60).truncate();

  String minutesStr = (minutes % 60).toString().padLeft(2, '0');
  String secondsStr = (seconds % 60).toString().padLeft(2, '0');

  return "$minutesStr:$secondsStr";
}
