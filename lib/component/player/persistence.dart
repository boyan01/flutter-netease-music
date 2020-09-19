part of 'player.dart';

const _key_play_queue = "quiet_player_queue";
const _key_current_playing = "quiet_current_playing";
const _key_play_mode = "quiet_play_mode";

extension _PlayerPersistenceExtensions on Box<Map> {
  void savePlayQueue(PlayQueue queue) {
    put(_key_play_queue, queue.toMap());
  }

  PlayQueue restorePlayQueue() {
    final map = get(_key_play_queue);
    if (map == null) {
      return null;
    } else {
      return PlayQueue.fromMap(map);
    }
  }

  void saveCurrentMetadata(MusicMetadata metadata) {
    put(_key_current_playing, metadata.toMap());
  }

  MusicMetadata restoreMetadata() {
    final map = get(_key_current_playing);
    if (map == null) {
      return null;
    } else {
      return MusicMetadata.fromMap(map);
    }
  }

  void savePlayMode(PlayMode mode) {
    put(_key_play_mode, {"mode": mode.index});
  }

  PlayMode restorePlayMode() {
    final map = get(_key_play_mode);
    if (map == null) {
      return PlayMode.sequence;
    } else {
      int mode = map["mode"] ?? PlayMode.sequence.index;
      return PlayMode(mode);
    }
  }
}
