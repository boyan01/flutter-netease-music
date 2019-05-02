library part;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlay_support/overlay_support.dart';

export 'package:quiet/component/cache/cache.dart';
export 'package:quiet/material/dividers.dart';
export 'package:quiet/model/model.dart';
export 'package:quiet/pages/account/account.dart';
export 'package:scoped_model/scoped_model.dart';

export 'dialogs.dart';
export 'loader.dart';
export 'netease/counter.dart';
export 'netease/liked_song_list.dart';
export 'netease/netease.dart';
export 'player/player.dart';
export 'route.dart';
export 'theme/theme.dart';
export 'tiles.dart';

void notImplemented(BuildContext context) {
  showSimpleNotification(context, Text("页面未完成"),
      background: Color(0xFFd2dd37), foreground: Colors.black);
}
