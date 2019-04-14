import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
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

  const PlayingIndicator({Key key, this.playing, this.pausing, this.buffering})
      : super(key: key);

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

  @override
  void initState() {
    super.initState();
    quiet.addListener(_onMusicStateChanged);
    _index = playerState;
  }

  ///get current player state index
  int get playerState => quiet.value.isBuffering
      ? _INDEX_BUFFERING
      : quiet.value.isPlaying ? _INDEX_PLAYING : _INDEX_PAUSING;

  void _onMusicStateChanged() {
    final target = playerState;
    if (target == _index) return;

    final action =
        CancelableOperation.fromFuture(Future.delayed(_durationDelay));
    _changeStateOperations.add(action);
    action.value.whenComplete(() {
      if (target == playerState) _changeState(target);
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
    quiet.removeListener(_onMusicStateChanged);
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
