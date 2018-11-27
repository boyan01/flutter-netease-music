import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:quiet/model/model.dart';
import 'package:video_player/video_player.dart';

_MusicPlayer quiet = _MusicPlayer._private();

class _MusicPlayer extends ValueNotifier<PlayerStateValue> {
  _MusicPlayer._private() : super(PlayerStateValue.uninitialized());

  VideoPlayerController _controller;

  ///play music
  ///if param is null, play current music
  ///if param music is null , current is null , do nothing
  Future<void> play({Music music}) async {
    music ??= value.current;
    if (music == null) {
      //do nothing if source is not available
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
    _controller.addListener(_controllerListener);
  }

  void _controllerListener() {
    value = value.copyWith(state: _controller.value);
  }

  Future<void> pause() {
    return _controller.pause();
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
