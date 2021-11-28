import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:music_player/music_player.dart';
import 'package:provider/provider.dart';
import 'package:quiet/component/player/lryic.dart';
import 'package:quiet/media/tracks/track_list.dart';
import 'package:quiet/media/tracks/tracks_player.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/data/track.dart';
import 'package:scoped_model/scoped_model.dart';

export 'package:quiet/component/player/bottom_player_bar.dart';
export 'package:quiet/component/player/lryic.dart';

part 'persistence.dart';

const String kFmPlayQueueId = "personal_fm";

//
/////key which save playing music to local preference
//const String _PREF_KEY_PLAYING = "quiet_player_playing";
//
/////key which save playing music list to local preference
//const String _PREF_KEY_PLAYLIST = "quiet_player_playlist";
//
/////key which save playing list token to local preference
//const String _PREF_KEY_TOKEN = "quiet_player_token";
//
/////key which save playing mode to local preference
//const String _PREF_KEY_PLAY_MODE = "quiet_player_play_mode";

extension PlayModeGetNext on PlayMode {
  PlayMode get next {
    if (this == PlayMode.sequence) {
      return PlayMode.shuffle;
    } else if (this == PlayMode.shuffle) {
      return PlayMode.single;
    } else {
      return PlayMode.sequence;
    }
  }
}

extension QuitPlayerExt on BuildContext {
  TracksPlayer get player => read<TracksPlayer>();

  TracksPlayerState get watchPlayerValue =>
      watch<ValueNotifier<TracksPlayerState>>().value;

  Track? get playingTrack => watchPlayerValue.current;

  bool get isPlaying => watchPlayerValue.playing;

  PlayMode get playMode => PlayMode.sequence;

  TrackList get playingTrackList => watchPlayerValue.list;
}

extension PlayQueueExt on PlayQueue {
  /// 是否处于私人FM 播放模式
  bool get isPlayingFm => queueId == kFmPlayQueueId;
}

extension MusicPlayerExt on MusicPlayer {
  //FIXME is this logic right???
  bool get initialized =>
      value.metadata != null && value.metadata!.duration > 0;
}

class Quiet extends StatefulWidget {
  const Quiet({required this.child, Key? key, this.box}) : super(key: key);

  final Widget child;

  final Box<Map>? box;

  @override
  State<StatefulWidget> createState() => _QuietState();
}

class TracksPlayerState with EquatableMixin {
  const TracksPlayerState({
    required this.playing,
    required this.buffering,
    required this.current,
    required this.list,
    required this.initialized,
  });

  final bool playing;
  final bool buffering;
  final Track? current;
  final TrackList list;
  final bool initialized;

  @override
  List<Object?> get props => [
        playing,
        buffering,
        current,
        list,
        initialized,
      ];
}

class _QuietState extends State<Quiet> {
  late PlayingLyric _playingLyric;

  final _player = TracksPlayer.platform();

  final _playState = ValueNotifier<TracksPlayerState>(const TracksPlayerState(
    playing: false,
    buffering: false,
    current: null,
    list: TrackList.empty(),
    initialized: false,
  ));

  @override
  void initState() {
    super.initState();
    _playingLyric = PlayingLyric(_player);
    _player.onTrackChanged.addListener(_notifyPlayState);
    _player.onPlaybackStateChanged.addListener(_notifyPlayState);
  }

  void _notifyPlayState() {
    _playState.value = TracksPlayerState(
      playing: _player.isPlaying,
      buffering: _player.isBuffering,
      current: _player.current,
      list: _player.trackList,
      initialized: _player.duration != null,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _player.onTrackChanged.removeListener(_notifyPlayState);
    _player.onPlaybackStateChanged.removeListener(_notifyPlayState);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: _player,
      child: ChangeNotifierProvider<ValueNotifier<TracksPlayerState>>.value(
        value: _playState,
        child: ScopedModel(
          model: _playingLyric,
          child: widget.child,
        ),
      ),
    );
  }
}

extension PlayModeDescription on PlayMode {
  IconData get icon {
    if (this == PlayMode.single) {
      return Icons.repeat_one;
    } else if (this == PlayMode.shuffle) {
      return Icons.shuffle;
    } else {
      return Icons.repeat;
    }
  }

  String get name {
    if (this == PlayMode.single) {
      return "单曲循环";
    } else if (this == PlayMode.shuffle) {
      return "随机播放";
    } else {
      return "列表循环";
    }
  }
}
