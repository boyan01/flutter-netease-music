// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:music_player/music_player.dart';

export 'package:quiet/component/player/bottom_player_bar.dart';

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

extension PlayQueueExt on PlayQueue {
  /// 是否处于私人FM 播放模式
  bool get isPlayingFm => queueId == kFmPlayQueueId;
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
