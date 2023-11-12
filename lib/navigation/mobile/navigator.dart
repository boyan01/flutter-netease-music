import 'package:flutter/material.dart';

import '../../providers/navigator_provider.dart';
import '../common/navigation_target.dart';
import 'artists/page_artist_detail.dart';
import 'home/page_home.dart';
import 'leaderboard/page_leaderboard.dart';
import 'player/page_fm_playing.dart';
import 'player/page_playing.dart';
import 'player/page_playing_list.dart';
import 'playlists/page_album_detail.dart';
import 'playlists/page_daily_playlist.dart';
import 'playlists/page_playlist_detail.dart';
import 'playlists/page_playlist_edit.dart';
import 'search/page_search.dart';
import 'search/page_search_music_result.dart';
import 'settings/page_setting.dart';
import 'user/login_page.dart';
import 'user/login_password_page.dart';
import 'user/page_user_detail.dart';
import 'widgets/bottom_sheet_page.dart';
import 'widgets/slide_up_page_route.dart';

// return false to prevent the route from being popped.
typedef AppWillPopCallback = bool Function();

enum _PageType {
  normal,
  slideUp,
  bottomSheet,
}

class MobileNavigatorController extends NavigatorController {
  MobileNavigatorController() {
    _pages.add(NavigationTargetLibrary());
    notifyListeners();
  }

  final _pages = <NavigationTarget>[];

  final List<AppWillPopCallback> _willPopCallbacks = [];

  @override
  void back() {
    for (final callback in _willPopCallbacks.reversed) {
      if (!callback()) {
        return;
      }
    }
    if (canBack) {
      _pages.removeLast();
      notifyListeners();
    }
  }

  void addScopedWillPopCallback(AppWillPopCallback callback) {
    _willPopCallbacks.add(callback);
  }

  void removeScopedWillPopCallback(AppWillPopCallback callback) {
    _willPopCallbacks.remove(callback);
  }

  @override
  bool get canBack => _pages.length > 1;

  @override
  bool get canForward => false;

  @override
  void forward() => throw UnimplementedError('Forward is not supported');

  @override
  NavigationTarget get current => _pages.last;

  @override
  void navigate(NavigationTarget target) {
    if (current.isTheSameTarget(target)) {
      debugPrint('Navigation: already on $target');
      return;
    }

    if (target is NavigationTargetSearch) {
      // Search page is a special page, it should be pushed on top of the current page.
      _pages.removeWhere(
        (e) => e is NavigationTargetSearch || e is NavigationTargetSearchResult,
      );
    }

    if (target.isMobileHomeTab()) {
      _pages.clear();
    }
    _pages.add(target);
    notifyListeners();
  }

  @override
  List<Page> get pages => _pages.map(_buildPage).toList(growable: false);

  Page<dynamic> _buildPage(NavigationTarget target) {
    final Widget page;
    var pageType = _PageType.normal;
    switch (target) {
      case NavigationTargetDiscover _:
      case NavigationTargetLibrary _:
        page = PageHome(selectedTab: target);
      case final NavigationTargetSearch target:
        page = PageSearch(initial: target.initial, key: ValueKey(target));
      case final NavigationTargetSearchResult target:
        page = PageMusicSearchResult(query: target.keyword);
      case NavigationTargetSettings _:
        page = const PageSettings();
      case final NavigationTargetPlaylist target:
        page = PlaylistDetailPage(target.playlistId);
      case final NavigationTargetPlaying _:
        page = const PlayingPage();
        pageType = _PageType.slideUp;
      case final NavigationTargetFmPlaying _:
        page = const PagePlayingFm();
        pageType = _PageType.slideUp;
      case final NavigationTargetUser target:
        page = UserDetailPage(userId: target.userId);
      case final NavigationTargetLogin _:
        page = const LoginPage();
      case final NavigationTargetLoginPassword target:
        page = LoginPasswordPage(phoneNumber: target.phoneNumber);
      case final NavigationTargetArtistDetail target:
        page = ArtistDetailPage(artistId: target.artistId);
      case final NavigationTargetAlbumDetail target:
        page = AlbumDetailPage(albumId: target.albumId);
      case final NavigationTargetPlayingList _:
        page = const PlayingListDialog();
        pageType = _PageType.bottomSheet;
      case final NavigationTargetDailyRecommend _:
        page = const DailyPlaylistPage();
      case final NavigationTargetLeaderboard _:
        page = const LeaderboardPage();
      case final NavigationTargetPlaylistEdit target:
        page = PlaylistEditPage(playlist: target.playlist);
      default:
        throw Exception('Unknown navigation type: $target');
    }
    switch (pageType) {
      case _PageType.normal:
        return MaterialPage<dynamic>(
          child: page,
          name: target.runtimeType.toString(),
        );
      case _PageType.slideUp:
        return SlideUpPage(
          child: page,
          name: target.runtimeType.toString(),
        );
      case _PageType.bottomSheet:
        return BottomSheetPage(
          child: page,
          name: target.runtimeType.toString(),
        );
    }
  }
}
