import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:quiet/model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

MusicPlayer quiet = MusicPlayer._private();

class MusicPlayer extends ValueNotifier<PlayerStateValue> {
  MusicPlayer._private() : super(PlayerStateValue.uninitialized()) {
    () async {
      var preference = await SharedPreferences.getInstance();
      Music current;
      List<Music> playlist;
      try {
        current =
            Music.fromMap(json.decode(preference.get("quiet_player_playing")));
        playlist =
            (json.decode(preference.get("quiet_player_playlist")) as List)
                .cast<Map>()
                .map(Music.fromMap)
                .toList();
        debugPrint("current : $current");
      } catch (e) {
        debugPrint(e.toString());
      }

      addListener(() {
        if (current != value.current) {
          preference.setString("quiet_player_playing",
              json.encode(value.current, toEncodable: (e) => e.toMap()));
          current = value.current;
        }
        if (playlist != value.playlist) {
          preference.setString("quiet_player_playlist",
              json.encode(value.playlist, toEncodable: (e) => e.toMap()));
        }
      });
      value = value.copyWith(current: current, playlist: playlist);
    }();
  }

  VideoPlayerController _controller;

  ///play music
  ///if param is null, play current music
  ///if param music is null , current is null , do nothing
  Future<void> play({Music music}) async {
    if (music == null) {
      if (_controller.value.initialized && !_controller.value.isPlaying) {
        await _controller.play();
      }
      if (value.current != null) {
        await play(music: value.current);
      }
      return;
    }
    if (value.current == music && _controller.value.initialized) {
      await _controller.play();
      return;
    }
    assert(
        music.url != null && music.url.isNotEmpty, "music url can not be null");
    _newController(music.url);
    //refresh state
    value = value.copyWith(current: music);
    return await _controller.play();
  }

  //create a new player controller
  void _newController(String url) {
    _controller?.removeListener(_controllerListener);
    _controller?.dispose();

    _controller = VideoPlayerController.network(url);
    _controller.initialize();
    _controller.addListener(_controllerListener);
  }

  void _controllerListener() {
    value = value.copyWith(state: _controller.value);
  }

  Future<void> pause() {
    return _controller.pause();
  }

  void quiet() {
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    _controller = null;
    value = PlayerStateValue.uninitialized();
  }

  void playNext() {}

  void playPrevious() {}

  Future<void> setVolume(double volume) {
    return _controller.setVolume(volume);
  }
}

class PlayerStateValue {
  PlayerStateValue(this.state, this.playlist, this.current);

  PlayerStateValue.uninitialized()
      : this(VideoPlayerValue.uninitialized(), [], null);

  final VideoPlayerValue state;

  final List<Music> playlist;

  final Music current;

  PlayerStateValue copyWith(
      {VideoPlayerValue state, List<Music> playlist, Music current}) {
    return PlayerStateValue(state ?? this.state, playlist ?? this.playlist,
        current ?? this.current);
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
