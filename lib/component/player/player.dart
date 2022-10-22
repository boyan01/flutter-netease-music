import 'package:flutter/material.dart';
import 'package:music_player/music_player.dart';

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
      return '单曲循环';
    } else if (this == PlayMode.shuffle) {
      return '随机播放';
    } else {
      return '列表循环';
    }
  }
}
