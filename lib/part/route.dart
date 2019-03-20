import 'package:flutter/material.dart';
import 'package:quiet/pages/collection/page_collections.dart';
import 'package:quiet/pages/main/page_main.dart';
import 'package:quiet/pages/page_downloads.dart';
import 'package:quiet/pages/page_leaderboard.dart';
import 'package:quiet/pages/page_login.dart';
import 'package:quiet/pages/page_my_dj.dart';
import 'package:quiet/pages/page_playing.dart';
import 'package:quiet/pages/playlist/page_daily_playlist.dart';
import 'package:quiet/pages/setting/page_setting.dart';

export 'package:quiet/pages/collection/page_collections.dart';
export 'package:quiet/pages/main/page_main.dart';
export 'package:quiet/pages/page_fullscreen_mv_player.dart';
export 'package:quiet/pages/page_leaderboard.dart';
export 'package:quiet/pages/page_login.dart';
export 'package:quiet/pages/page_mv_detail.dart';
export 'package:quiet/pages/page_playing.dart';
export 'package:quiet/pages/playlist/page_album_detail.dart';
export 'package:quiet/pages/playlist/page_daily_playlist.dart';
export 'package:quiet/pages/playlist/page_playlist_detail.dart';
export 'package:quiet/pages/setting/page_setting.dart';

const ROUTE_MAIN = "/";

const ROUTE_LOGIN = "/login";

const ROUTE_PLAYLIST_DETAIL = "/playlist/detail";

const ROUTE_PAYING = "/playing";

const ROUTE_LEADERBOARD = "/leaderboard";

const ROUTE_DAILY = "/daily";

const ROUTE_DOWNLOADS = "/downloads";

const ROUTE_MY_DJ = '/mydj';

const ROUTE_MY_COLLECTION = '/my_collection';

const ROUTE_SETTING = '/setting';

///app routers
final Map<String, WidgetBuilder> routes = {
  ROUTE_MAIN: (context) => MainPage(),
  ROUTE_LOGIN: (context) => LoginPage(),
  ROUTE_PAYING: (context) => PlayingPage(),
  ROUTE_LEADERBOARD: (context) => LeaderboardPage(),
  ROUTE_DAILY: (context) => DailyPlaylistPage(),
  ROUTE_DOWNLOADS: (context) => DownloadPage(),
  ROUTE_MY_DJ: (context) => MyDjPage(),
  ROUTE_MY_COLLECTION: (context) => MyCollectionPage(),
  ROUTE_SETTING: (context) => SettingPage(),
};
