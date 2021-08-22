import 'package:flutter/material.dart';
import 'package:quiet/pages/collection/page_collections.dart';
import 'package:quiet/pages/leaderboard/page_leaderboard.dart';
import 'package:quiet/pages/main/page_main.dart';
import 'package:quiet/pages/page_my_dj.dart';
import 'package:quiet/pages/player/page_fm_playing.dart';
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

const pagePlaylistDetail = "/playlist/detail";

/// Route name of [PlayingPage].
const pagePlaying = "/playing";

/// 私人FM
const pageFmPlaying = "/playing_fm";

const pageLeaderboard = "/leaderboard";

/// Route name of [DailyPlaylistPage]
const pageDaily = "/daily";

const pageMyDj = '/mydj';

const pageMyCollection = '/my_collection';

const pageSetting = '/setting';

const pageSettingTheme = '/setting/theme';

const pageWelcome = 'welcome';

/// Search page route name
const pageSearch = "search";

///app routers
final Map<String, WidgetBuilder> routes = {
  pageMain: (context) => MainPage(),
  pageLogin: (context) => const LoginNavigator(),
  pagePlaying: (context) => PlayingPage(),
  pageLeaderboard: (context) => LeaderboardPage(),
  pageDaily: (context) => DailyPlaylistPage(),
  pageMyDj: (context) => MyDjPage(),
  pageMyCollection: (context) => MyCollectionPage(),
  pageSetting: (context) => SettingPage(),
  pageSettingTheme: (context) => SettingThemePage(),
  pageWelcome: (context) => PageWelcome(),
  pageFmPlaying: (context) => PagePlayingFm(),
};

Route<dynamic>? routeFactory(RouteSettings settings) {
  WidgetBuilder? builder;
  switch (settings.name) {
    case "/mv":
      builder = (context) => MusicVideoPlayerPage(settings.arguments! as int);
      break;
  }

  if (builder != null) {
    return MaterialPageRoute(builder: builder, settings: settings);
  }

  assert(false, 'ERROR: can not generate Route for ${settings.name}');
  return null;
}
