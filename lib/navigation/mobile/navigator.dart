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
import 'settings/page_setting.dart';
import 'user/login_page.dart';
import 'user/login_password_page.dart';
import 'user/page_user_detail.dart';
import 'widgets/bottom_sheet_page.dart';
import 'widgets/slide_up_page_route.dart';

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
    switch (target.runtimeType) {
      case NavigationTargetDiscover:
      case NavigationTargetLibrary:
      case NavigationTargetSearch:
        page = PageHome(selectedTab: target);
        break;
      case NavigationTargetSettings:
        page = const PageSettings();
        break;
      case NavigationTargetPlaylist:
        page = PlaylistDetailPage(
          (target as NavigationTargetPlaylist).playlistId,
        );
        break;
      case NavigationTargetPlaying:
        page = const PlayingPage();
        pageType = _PageType.slideUp;
        break;
      case NavigationTargetFmPlaying:
        page = const PagePlayingFm();
        pageType = _PageType.slideUp;
        break;
      case NavigationTargetUser:
        page = UserDetailPage(userId: (target as NavigationTargetUser).userId);
        break;
      case NavigationTargetLogin:
        page = const LoginPage();
        break;
      case NavigationTargetLoginPassword:
        page = LoginPasswordPage(
          phoneNumber: (target as NavigationTargetLoginPassword).phoneNumber,
        );
        break;
      case NavigationTargetArtistDetail:
        page = ArtistDetailPage(
          artistId: (target as NavigationTargetArtistDetail).artistId,
        );
        break;
      case NavigationTargetAlbumDetail:
        page = AlbumDetailPage(
          albumId: (target as NavigationTargetAlbumDetail).albumId,
        );
        break;
      case NavigationTargetPlayingList:
        page = const PlayingListDialog();
        pageType = _PageType.bottomSheet;
        break;
      case NavigationTargetDailyRecommend:
        page = const DailyPlaylistPage();
        break;
      case NavigationTargetLeaderboard:
        page = const LeaderboardPage();
        break;
      case NavigationTargetPlaylistEdit:
        page = PlaylistEditPage(
          playlist: (target as NavigationTargetPlaylistEdit).playlist,
        );
        break;
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
