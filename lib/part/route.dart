import 'package:flutter/material.dart';
import 'package:quiet/pages/page_daily_playlist.dart';
import 'package:quiet/pages/page_leaderboard.dart';
import 'package:quiet/pages/page_login.dart';
import 'package:quiet/pages/page_main.dart';
import 'package:quiet/pages/page_playing.dart';

export 'package:quiet/pages/page_login.dart';
export 'package:quiet/pages/page_main.dart';
export 'package:quiet/pages/page_playlist_detail.dart';
export 'package:quiet/pages/page_playing.dart';
export 'package:quiet/pages/page_leaderboard.dart';
export 'package:quiet/pages/page_daily_playlist.dart';

const ROUTE_MAIN = "/";

const ROUTE_LOGIN = "/login";

const ROUTE_PLAYLIST_DETAIL = "/playlist/detail";

const ROUTE_PAYING = "/playing";

const ROUTE_LEADERBOARD = "/leaderboard";

const ROUTE_DAILY = "/daily";

///app routers
final Map<String, WidgetBuilder> routes = {
  ROUTE_MAIN: (context) => MainPage(),
  ROUTE_LOGIN: (context) => LoginPage(),
  ROUTE_PAYING: (context) => PlayingPage(),
  ROUTE_LEADERBOARD: (context) => LeaderboardPage(),
  ROUTE_DAILY: (context) => DailyPlaylistPage(),
};
