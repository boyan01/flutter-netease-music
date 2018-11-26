import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:quiet/model/model.dart';

const MethodChannel _channel = const MethodChannel('tech.soit.quiet/player');

MusicPlayer quiet = MusicPlayer._private();

typedef MusicChangeCallback = void Function(Music);

class MusicPlayer {
  MusicPlayer._private();

  ///current playing music list
  List<Music> get playlist => _playlist;

  List<Music> _playlist;

  ///current playing music
  Music get current => _current;
  Music _current;

  List<MusicChangeCallback> musicChangeCallbacks = [];

  ///play music
  ///if param is null, play current music
  ///if param music is null , current is null , do nothing
  Future<bool> play({Music music}) async {
    music ??= current;
    if (music == null) {
      return false;
    }
    assert(
        music.url != null && music.url.isNotEmpty, "music url can not be null");
    var data = {
      'title': music.title,
      'subTitle': music.subTitle,
      'imageUrl': music.album.coverImageUrl,
      'playUrl': music.url
    };

    var success = await _channel.invokeMethod("play", data);
    if (success) {
      _current = music;
      musicChangeCallbacks.forEach((f) => f(current));
    }

    return success;
  }

  Future<bool> pause() async {
    await _channel.invokeMethod("pause");
    return true;
  }

  void playNext() {
    //TODO
  }

  void playPrevious() {}

  Future<bool> setVolume(double volume) async {
    var success = await _channel.invokeMethod("volume", volume);
    return success;
  }

  void addMusicChangeListener(MusicChangeCallback callback) {
    musicChangeCallbacks.add(callback);
    callback(current);
  }

  void removeMusicChangeListener(MusicChangeCallback callback) {
    musicChangeCallbacks.remove(callback);
  }
}

enum PlayerState { playing, buffering, pause, idle }

class Quiet extends StatefulWidget {
  Quiet(
      {@Required() this.child,
      this.playerState = false,
      this.playingMusic = false});

  ///listen player state event
  ///use [MusicPlayerState.of]
  final bool playerState;

  ///listen playing music change event
  final bool playingMusic;

  final Widget child;

  @override
  State<StatefulWidget> createState() => _QuietState();
}

class _QuietState extends State<Quiet> {
  PlayerState state;

  Music current;

  void _onMusicChange(Music music) {
    setState(() {
      current = music;
    });
  }

  @override
  void initState() {
    super.initState();
    quiet.addMusicChangeListener(_onMusicChange);
  }

  @override
  void dispose() {
    super.dispose();
    quiet.removeMusicChangeListener(_onMusicChange);
  }

  @override
  Widget build(BuildContext context) {
    var result = widget.child;

    if (widget.playerState) {
      result = MusicPlayerState(result, state);
    }
    if (widget.playingMusic) {
      result = PlayingMusic(result, current);
    }
    return result;
  }
}

class MusicPlayerState extends InheritedWidget {
  ///get current Music player state
  static MusicPlayerState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MusicPlayerState);
  }

  MusicPlayerState(Widget child, this.state) : super(child: child);

  final PlayerState state;

  @override
  bool updateShouldNotify(MusicPlayerState oldWidget) {
    return state == oldWidget.state;
  }
}

class PlayingMusic extends InheritedWidget {
  PlayingMusic(Widget child, this.playing) : super(child: child);

  ///get current playing music
  final Music playing;

  static PlayingMusic of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(PlayingMusic);
  }

  @override
  bool updateShouldNotify(PlayingMusic oldWidget) {
    return playing != oldWidget.playing;
  }
}
