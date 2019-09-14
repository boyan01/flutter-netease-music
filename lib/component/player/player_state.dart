import 'package:music_player/music_player.dart';
import 'package:quiet/model/model.dart';

class PlayerControllerState {
  PlayerControllerState(this.state)
      : duration = Duration(milliseconds: state.metadata?.duration ?? 0),
        playWhenReady = true,
        current = state.metadata == null ? null : _Music(state.metadata),
        playingList = state.queue.map((q) => _Music.fromDescription(q.description)).toList();

  PlayerControllerState.uninitialized() : this(const MusicPlayerState.none());

  final MusicPlayerState state;

  final Duration duration;

  Duration get position {
    int diff = DateTime.now().millisecondsSinceEpoch - state.playbackState.lastPositionUpdateTime;
    return Duration(milliseconds: state.playbackState.position + diff);
  }

  ///whether playback should proceed when isReady become true
  final bool playWhenReady;

  ///audio is buffering
  bool get isBuffering => state.playbackState.state == PlaybackState.STATE_BUFFERING;

  ///might be null
  final Music current;

  final List<Music> playingList;

  String get token => state.queueTitle;

  PlayMode get playMode {
    if (state.shuffleMode == PlaybackState.SHUFFLE_MODE_ALL) {
      return PlayMode.shuffle;
    }
    if (state.repeatMode == PlaybackState.REPEAT_MODE_NONE) {
      return PlayMode.single;
    }
    return PlayMode.sequence;
  }

  bool get initialized => duration != null;

  bool get hasError => state.playbackState.state == PlaybackState.STATE_ERROR;

  bool get isPlaying => (state.playbackState.state == PlaybackState.STATE_PLAYING) && playWhenReady && !hasError;
}

class _Music extends Music {
  _Music(this.metadata) : description = metadata.getDescription();

  _Music.fromDescription(this.description) : metadata = null;

  @override
  final MediaMetadata metadata;

  final MediaDescription description;

  @override
  int get id => int.tryParse(description.mediaId);

  @override
  String get title => description.title;

  @override
  String get subTitle => description.subtitle;

  @override
  String get url => description.mediaUri.toString();

  @override
  Album get album => null;

  @override
  List<Artist> get artist => const [];

  @override
  int get mvId => 0;
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
