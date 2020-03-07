import 'package:flutter/material.dart';
import 'package:quiet/pages/collection/page_collections.dart';
import 'package:quiet/pages/leaderboard/page_leaderboard.dart';
import 'package:quiet/pages/main/page_main.dart';
import 'package:quiet/pages/page_my_dj.dart';
import 'package:quiet/pages/player/page_playing.dart';
import 'package:quiet/pages/playlist/page_daily_playlist.dart';
import 'package:quiet/pages/setting/page_setting.dart';
import 'package:quiet/pages/video/page_music_video_player.dart';
import 'package:quiet/pages/welcome/login_sub_navigation.dart';
import 'package:quiet/pages/welcome/page_welcome.dart';

export 'package:quiet/pages/collection/page_collections.dart';
export 'package:quiet/pages/leaderboard/page_leaderboard.dart';
export 'package:quiet/pages/main/page_main.dart';
export 'package:quiet/pages/player/page_playing.dart';
export 'package:quiet/pages/playlist/page_album_detail.dart';
export 'package:quiet/pages/playlist/page_daily_playlist.dart';
export 'package:quiet/pages/playlist/page_playlist_detail.dart';
export 'package:quiet/pages/setting/page_setting.dart';
export 'package:quiet/pages/video/page_music_video_player.dart';

const pageMain = Navigator.defaultRouteName;

///popup with [true] if login succeed
const pageLogin = "/login";

const ROUTE_PLAYLIST_DETAIL = "/playlist/detail";

const ROUTE_PAYING = "/playing";

const pageLeaderboard = "/leaderboard";

/// route name of [DailyPlaylistPage]
const pageDaily = "/daily";

const pageMyDj = '/mydj';

const ROUTE_MY_COLLECTION = '/my_collection';

const ROUTE_SETTING = '/setting';

const ROUTE_SETTING_THEME = '/setting/theme';

const pageWelcome = 'welcome';

/// Search page route name
const pageSearch = "search";

///app routers
final Map<String, WidgetBuilder> routes = {
  pageMain: (context) => MainPage(),
  pageLogin: (context) => LoginNavigator(),
  ROUTE_PAYING: (context) => PlayingPage(),
  pageLeaderboard: (context) => LeaderboardPage(),
  pageDaily: (context) => DailyPlaylistPage(),
  pageMyDj: (context) => MyDjPage(),
  ROUTE_MY_COLLECTION: (context) => MyCollectionPage(),
  ROUTE_SETTING: (context) => SettingPage(),
  ROUTE_SETTING_THEME: (context) => SettingThemePage(),
  pageWelcome: (context) => PageWelcome(),
};

Route<dynamic> routeFactory(RouteSettings settings) {
  WidgetBuilder builder;
  switch (settings.name) {
    case "/mv":
      builder = (context) => MusicVideoPlayerPage(settings.arguments);
      break;
  }

  if (builder != null) return MaterialPageRoute(builder: builder, settings: settings);

  assert(false, 'ERROR: can not generate Route for ${settings.name}');
  return null;
}
