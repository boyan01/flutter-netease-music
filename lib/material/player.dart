import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:music_player/music_player.dart';
import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/part/part.dart';

import 'user.dart';

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

/// 歌曲喜欢按钮
class LikeButton extends StatelessWidget {
  static final _logger = Logger("LikeButton");

  final Music music;

  const LikeButton({Key key, @required this.music})
      : assert(music != null),
        super(key: key);

  factory LikeButton.current(BuildContext context) {
    return LikeButton(music: context.listenPlayerValue.current);
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = FavoriteMusicList.contain(context, music);
    return IconButton(
      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
      onPressed: () async {
        if (!UserAccount.of(context, rebuildOnChange: false).isLogin) {
          final login = await showNeedLoginToast(context);
          _logger.info("show login: $login");
          if (!login) {
            return;
          }
        }
        if (!isLiked) {
          FavoriteMusicList.of(context).likeMusic(music);
        } else {
          FavoriteMusicList.of(context).dislikeMusic(music);
        }
      },
    );
  }
}
