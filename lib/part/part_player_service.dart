import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:quiet/model/model.dart';
import 'package:quiet/service/channel_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

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
      PlayingList playingList;
      try {
        current = Music.fromMap(json.decode(preference.get(_PREF_KEY_PLAYING)));
        String token = preference.get(_PREF_KEY_TOKEN);
        List<Music> musicList =
            (json.decode(preference.get(_PREF_KEY_PLAYLIST)) as List)
                .cast<Map>()
                .map(Music.fromMap)
                .toList();
        PlayMode playMode =
            PlayMode.values[preference.getInt(_PREF_KEY_PLAY_MODE) ?? 0];
        if (musicList == null || token == null) {
          playingList = PlayingList.empty;
        } else {
          playingList = PlayingList(token, musicList, playMode: playMode);
        }
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
          preference.setString(
              _PREF_KEY_PLAYLIST,
              json.encode(value.playlist.musics,
                  toEncodable: (e) => e.toMap()));
          preference.setInt(_PREF_KEY_PLAY_MODE, value.playlist.playMode.index);
          preference.setString(_PREF_KEY_TOKEN, value.playlist.token);
          playingList = value.playlist;
        }
      });
      value = value.copyWith(current: current, playlist: playingList);
    }();
  }

  VideoPlayerController _controller;

  ///play a single song
  Future<void> play({Music music}) async {
    if (!value.playlist.musics.contains(music)) {
      value.playlist.insertToNext(value.current, music);
      notifyListeners();
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

    if (value.playlist.token != token || value.playlist.musics != list) {
      //need update playing list
      PlayingList playingList =
          PlayingList(token, list, playMode: value.playlist.playMode);
      value = value.copyWith(playlist: playingList);
    }
    _performPlay(music);
  }

  //perform to play music
  Future<void> _performPlay(Music music) async {
    if (music == null) {
      if (_controller != null &&
          _controller.value.initialized &&
          !_controller.value.isPlaying) {
        notification.update(value.current, true);
        await _controller.play();
      }
      if (value.current != null) {
        await _performPlay(value.current);
      }
      return;
    }
    if (_controller != null &&
        value.current == music &&
        _controller.value.initialized) {
      notification.update(music, true);
      await _controller.play();
      return;
    }
    assert(
        music.url != null && music.url.isNotEmpty, "music url can not be null");
    _newController(music.url);
    //refresh state
    value = value.copyWith(current: music);
    notification.update(music, true);
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
    if (value.current != null) {
      notification.update(value.current, false);
    } else {
      notification.cancel();
    }
    return _controller.pause();
  }

  void quiet() {
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    _controller = null;
    value = PlayerStateValue.uninitialized();
  }

  void playNext() {
    Music next = value.playlist.getNext(value.current);
    _performPlay(next);
  }

  void playPrevious() {
    Music previous = value.playlist.getPrevious(value.current);
    _performPlay(previous);
  }

  ///seek to position in milliseconds
  Future<void> seekTo(int position) {
    return _controller.seekTo(Duration(milliseconds: position));
  }

  Future<void> setVolume(double volume) {
    return _controller.setVolume(volume);
  }
}

///the current playing list, playing song , player state
///aways available in [PlayerState]
class PlayerStateValue {
  PlayerStateValue(this.state, this.playlist, this.current);

  PlayerStateValue.uninitialized()
      : this(VideoPlayerValue.uninitialized(), PlayingList.empty, null);

  /// The duration, current position, buffering state, error state and settings
  /// of a [VideoPlayerController].
  final VideoPlayerValue state;

  ///current playlist
  final PlayingList playlist;

  ///current playing music;
  final Music current;

  PlayerStateValue copyWith(
      {VideoPlayerValue state, PlayingList playlist, Music current}) {
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

///play mode determine [PlayingList] how to play next song
enum PlayMode {
  ///aways play single song
  single,

  ///play current list sequence
  sequence,

  ///random to play next song
  shuffle
}

///playing list
class PlayingList {
  static const String TOKEN_EMPTY = "empty_playlist";

  static final PlayingList empty = PlayingList(TOKEN_EMPTY, []);

  PlayingList(this.token, this.musics, {this.playMode = PlayMode.sequence})
      : assert(token != null),
        assert(musics != null),
        assert(playMode != null);

  final List<Music> musics;

  List<Music> shuffleMusicList;

  ///token identify this PlayingList
  final String token;

  ///current playing list play mode
  PlayMode playMode;

  ///get next music can be play by current
  Music getNext(Music current) {
    if (musics.isEmpty) {
      return null;
    }
    if (current == null) {
      return musics[0];
    }
    switch (playMode) {
      case PlayMode.single:
        return current;
      case PlayMode.sequence:
        var index = musics.indexOf(current) + 1;
        if (index == musics.length) {
          return musics.first;
        } else {
          return musics[index];
        }
        break;
      case PlayMode.shuffle:
        _ensureShuffleListGenerate();
        var index = shuffleMusicList.indexOf(current);
        if (index == -1) {
          return musics.first;
        } else if (index == musics.length - 1) {
          //shuffle list has been played to end, regenerate a list
          _isShuffleListDirty = true;
          _ensureShuffleListGenerate();
          return shuffleMusicList.first;
        } else {
          return shuffleMusicList[index + 1];
        }
        break;
    }
    throw Exception("illega state to get next music");
  }

  ///insert a song to playing list next position
  void insertToNext(Music current, Music next) {
    if (musics.isEmpty) {
      musics.add(next);
      return;
    }
    _ensureShuffleListGenerate();

    //if inserted is current, do nothing
    if (current == next) {
      return;
    }
    //remove if music list contains the insert item
    if (musics.remove(next)) {
      _isShuffleListDirty = true;
      _ensureShuffleListGenerate();
    }

    int index = musics.indexOf(current) + 1;
    musics.insert(index, next);

    int indexShuffle = shuffleMusicList.indexOf(current) + 1;
    shuffleMusicList.insert(indexShuffle, next);
  }

  ///get previous music can be play by current
  Music getPrevious(Music current) {
    if (musics.isEmpty) {
      return null;
    }
    if (current == null) {
      return musics.first;
    }
    switch (playMode) {
      case PlayMode.single:
        return current;
      case PlayMode.sequence:
        var index = musics.indexOf(current);
        if (index == -1) {
          return musics.first;
        } else if (index == 0) {
          return musics.last;
        } else {
          return musics[index - 1];
        }
        break;
      case PlayMode.shuffle:
        _ensureShuffleListGenerate();
        var index = shuffleMusicList.indexOf(current);
        if (index == -1) {
          return musics.first;
        } else if (index == 0) {
          //has reach the shuffle list head, need regenerate a shuffle list
          _isShuffleListDirty = true;
          _ensureShuffleListGenerate();
          return shuffleMusicList.last;
        } else {
          return shuffleMusicList[index - 1];
        }
        break;
    }
    throw Exception("illega state to get previous music");
  }

  bool _isShuffleListDirty = true;

  /// create shuffle list for [PlayMode.shuffle]
  void _ensureShuffleListGenerate() {
    if (!_isShuffleListDirty) {
      return;
    }
    shuffleMusicList = List.from(musics);
    shuffleMusicList.shuffle();
    _isShuffleListDirty = false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingList &&
          runtimeType == other.runtimeType &&
          musics == other.musics &&
          token == other.token &&
          playMode == other.playMode;

  @override
  int get hashCode => musics.hashCode ^ token.hashCode ^ playMode.hashCode;
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
