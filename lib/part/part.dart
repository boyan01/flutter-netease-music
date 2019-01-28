library part;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlay_support/overlay_support.dart';

export 'package:quiet/model/model.dart';

export 'part_player_service.dart';
export 'route.dart';
export 'part_music_list_provider.dart';
export 'part_player.dart';
export 'part_lyric.dart';
export 'part_cache.dart';
export 'loader.dart';
export 'part_utils.dart';
export 'dialogs.dart';
export 'tiles.dart';
export 'downloads.dart';
export 'package:quiet/part/material/dividers.dart';

export 'netease/netease.dart';
export 'netease/liked_song_list.dart';
export 'netease/login.dart';
export 'netease/counter.dart';

void notImplemented(BuildContext context) {
  showSimpleNotification(context, Text("页面未完成"),
      background: Color(0xFFd2dd37), foreground: Colors.black);
}
