import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:quiet/model/model.dart';
import 'package:video_player/video_player.dart';

MusicPlayer quiet = MusicPlayer._private();

class MusicPlayer extends ValueNotifier<PlayerStateValue> {
  MusicPlayer._private() : super(PlayerStateValue.uninitialized());

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
    super.initState();
    value = quiet.value;
    quiet.addListener(_onPlayerChange);
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

class PlayerState extends InheritedWidget {
  PlayerState({@required Widget child, @required this.value})
      : super(child: child);

  ///get current playing music
  final PlayerStateValue value;

  static PlayerState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(PlayerState);
  }

  @override
  bool updateShouldNotify(PlayerState oldWidget) {
    return value != oldWidget.value;
  }
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
