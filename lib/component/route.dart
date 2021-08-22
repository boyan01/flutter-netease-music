import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/component.dart';
import 'package:quiet/material.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/pages/account/page_user_detail.dart';
import 'package:quiet/pages/collection/page_collections.dart';
import 'package:quiet/pages/leaderboard/page_leaderboard.dart';
import 'package:quiet/pages/main/main_page_discover.dart';
import 'package:quiet/pages/main/my/main_page_my.dart';
import 'package:quiet/pages/main/page_main.dart';
import 'package:quiet/pages/page_my_dj.dart';
import 'package:quiet/pages/player/page_fm_playing.dart';
import 'package:quiet/pages/player/page_playing.dart';
import 'package:quiet/pages/playlist/page_daily_playlist.dart';
import 'package:quiet/pages/search/page_search.dart';
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

const pageMain = '/';

const pageMainMyMusic = '/my_playlist';
const pageMainCloud = '/discover_cloud';

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

const pageProfile = "/profile";
const pageProfileMy = "/profile/my";

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

Route<dynamic> onLandscapeBuildPrimaryRoute(RouteSettings settings) {
  Widget? widget;
  switch (settings.name) {
    case pageMainMyMusic:
      widget = Scaffold(
        body: MainPageMy(),
        primary: false,
        resizeToAvoidBottomInset: false,
      );
      break;
    case pageMainCloud:
      widget = Scaffold(
        body: MainPageDiscover(),
        primary: false,
        resizeToAvoidBottomInset: false,
      );
      break;
    case pageSearch:
      return SearchPageRoute(null);
    case pageFmPlaying:
      widget = Builder(builder: (context) {
        return Center(
          child: Text(context.strings.todo),
        );
      });
      break;
    case pageSetting:
      widget = SettingPage();
      break;
    case pageProfileMy:
      widget = Consumer(builder: (context, ref, _) {
        return UserDetailPage(
          userId: ref.read(userProvider).userId,
        );
      });
  }
  // assert(widget != null, "can not generate route for $settings");
  return MaterialPageRoute(
    settings: settings,
    builder: (context) => LandscapePrimaryRoutePage(
      child: widget ?? Container(),
    ),
  );
}

const _landscapeTopRoutes = {
  pageMain,
  pagePlaying,
  pageSetting,
  pageLogin,
};

const _landscapePrimaryRoutes = {
  pageFmPlaying,
  pageSearch,
  pageMainCloud,
  pageMainMyMusic,
  pageProfileMy,
};

extension RouterContext on BuildContext {
  Future<T?> push<T>(String name, {dynamic arguments}) async {
    if (!isLandscape || _landscapeTopRoutes.contains(name)) {
      return Navigator.of(this).pushNamed<T>(name, arguments: arguments);
    }
    if (_landscapePrimaryRoutes.contains(name)) {
      return landscapePrimaryNavigator!.pushNamed(name, arguments: arguments);
    }
    return landscapeSecondaryNavigator!.pushNamed(name, arguments: arguments);
  }
}
