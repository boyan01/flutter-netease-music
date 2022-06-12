part of 'player.dart';

const _keyPlayQueue = 'quiet_player_queue';
const _keyCurrentPlaying = 'quiet_current_playing';
const _keyPlayMode = 'quiet_play_mode';

extension PlayerPersistenceExtensions on Box<Map> {
  void savePlayQueue(PlayQueue queue) {
    put(_keyPlayQueue, queue.toMap());
  }

  PlayQueue? restorePlayQueue() {
    final map = get(_keyPlayQueue);
    if (map == null) {
      return null;
    } else {
      return PlayQueue.fromMap(map);
    }
  }

  void saveCurrentMetadata(MusicMetadata metadata) {
    put(_keyCurrentPlaying, metadata.toMap());
  }

  MusicMetadata? restoreMetadata() {
    final map = get(_keyCurrentPlaying);
    if (map == null) {
      return null;
    } else {
      return MusicMetadata.fromMap(map);
    }
  }

  void savePlayMode(PlayMode mode) {
    put(_keyPlayMode, {'mode': mode.index});
  }

  PlayMode restorePlayMode() {
    final map = get(_keyPlayMode);
    if (map == null) {
      return PlayMode.sequence;
    } else {
      final mode = map['mode'] as int? ?? PlayMode.sequence.index;
      return PlayMode(mode);
    }
  }
}
