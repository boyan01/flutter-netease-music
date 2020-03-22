import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:music_player/music_player.dart';
import 'package:quiet/component/player/lryic.dart';
import 'package:quiet/model/model.dart';
import 'package:quiet/part/part.dart';
import 'package:scoped_model/scoped_model.dart';

export 'package:quiet/component/player/bottom_player_bar.dart';
export 'package:quiet/component/player/lryic.dart';

const String FM_PLAY_QUEUE_ID = "pernal_fm";

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
  MusicPlayer get player {
    try {
      return ScopedModel.of<QuietModel>(this).player;
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }

  TransportControls get transportControls => player.transportControls;

  /// use [listenPlayerValue]
  @deprecated
  MusicPlayerValue get playerValue {
    return ScopedModel.of<QuietModel>(this, rebuildOnChange: true).player.value;
  }

  MusicPlayerValue get listenPlayerValue {
    return ScopedModel.of<QuietModel>(this, rebuildOnChange: true).player.value;
  }

  PlaybackState get playbackState => playerValue.playbackState;

  PlayMode get playMode => playerValue.playMode;

  PlayQueue get playList => playerValue.queue;
}

extension PlayQueueExt on PlayQueue {
  /// 是否处于私人FM 播放模式
  bool get isPlayingFm => queueId == FM_PLAY_QUEUE_ID;
}

extension MusicPlayerExt on MusicPlayer {
  //FIXME is this logic right???
  bool get initialized => value.metadata != null && value.metadata.duration > 0;

  /// 播放私人 FM
  /// [musics] 初始化数据
  void playFm(List<Music> musics) {
    final queue = PlayQueue(queueTitle: "私人FM", queueId: FM_PLAY_QUEUE_ID, queue: musics.toMetadataList());
    playWithQueue(queue);
  }
}

extension MusicPlayerValueExt on MusicPlayerValue {
  ///might be null
  Music get current => Music.fromMetadata(metadata);

  List<Music> get playingList => queue.queue.map((e) => Music.fromMetadata(e)).toList();
}

extension PlaybackStateExt on PlaybackState {
  bool get hasError => state == PlayerState.Error;

  bool get isPlaying => (state == PlayerState.Playing) && !hasError;

  ///audio is buffering
  bool get isBuffering => state == PlayerState.Buffering;

  bool get initialized => state != PlayerState.None;

  /// Current real position
  int get positionWithOffset => position + (DateTime.now().millisecondsSinceEpoch - updateTime);
}

@visibleForTesting
class QuietModel extends Model {
  MusicPlayer player = MusicPlayer();

  QuietModel() {
    player.addListener(() {
      this.notifyListeners();
    });
  }
}

class Quiet extends StatefulWidget {
  Quiet({@Required() this.child, Key key}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _QuietState();
}

class _QuietState extends State<Quiet> {
  final QuietModel _quiet = QuietModel();

  PlayingLyric _playingLyric;

  @override
  void initState() {
    super.initState();
    _playingLyric = PlayingLyric(_quiet.player);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: _quiet,
      child: ScopedModel(
        model: _playingLyric,
        child: widget.child,
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
