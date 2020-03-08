import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:music_player/music_player.dart';
import 'package:quiet/part/part.dart';

///
/// an widget which indicator player is Playing/Pausing/Buffering
///
class PlayingIndicator extends StatefulWidget {
  ///show when player is playing
  final Widget playing;

  ///show when player is pausing
  final Widget pausing;

  ///show when player is buffering
  final Widget buffering;

  const PlayingIndicator({Key key, this.playing, this.pausing, this.buffering}) : super(key: key);

  @override
  _PlayingIndicatorState createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<PlayingIndicator> {
  ///delay 200ms to change current state
  static const _durationDelay = Duration(milliseconds: 200);

  static const _INDEX_BUFFERING = 2;
  static const _INDEX_PLAYING = 1;
  static const _INDEX_PAUSING = 0;

  int _index = _INDEX_PAUSING;

  final _changeStateOperations = <CancelableOperation>[];

  MusicPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = context.player..addListener(_onMusicStateChanged);
    _index = _playerState;
  }

  ///get current player state index
  int get _playerState => _player.playbackState.isBuffering
      ? _INDEX_BUFFERING
      : _player.playbackState.isPlaying ? _INDEX_PLAYING : _INDEX_PAUSING;

  void _onMusicStateChanged() {
    final target = _playerState;
    if (target == _index) return;

    final action = CancelableOperation.fromFuture(Future.delayed(_durationDelay));
    _changeStateOperations.add(action);
    action.value.whenComplete(() {
      if (target == _playerState) _changeState(target);
      _changeStateOperations.remove(action);
    });
  }

  void _changeState(int state) {
    if (!mounted) {
      return;
    }
    setState(() {
      _index = state;
    });
  }

  @override
  void dispose() {
    _player.removeListener(_onMusicStateChanged);
    _changeStateOperations.forEach((o) => o.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _index,
      alignment: Alignment.center,
      children: <Widget>[widget.pausing, widget.playing, widget.buffering],
    );
  }
}

/// 监听播放器播放进度的 Widget
/// 使用 [ProgressTrackingContainer]
@deprecated
class ProgressTrackContainer extends StatefulWidget {
  final WidgetBuilder builder;

  const ProgressTrackContainer({Key key, @required this.builder}) : super(key: key);

  @override
  _ProgressTrackContainerState createState() => _ProgressTrackContainerState();
}

class _ProgressTrackContainerState extends State<ProgressTrackContainer> {
  MusicPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = context.player..addListener(_onStateChanged);
    _onStateChanged();
  }

  bool _tracking = false;

  Timer _timer;

  void _onStateChanged() {
    final needTrack = context.player.playbackState.isPlaying;
    if (_tracking == needTrack) return;
    if (_tracking) {
      _tracking = false;
      _timer?.cancel();
    } else {
      _tracking = true;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _player.removeListener(_onStateChanged);
    _tracking = false;
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
