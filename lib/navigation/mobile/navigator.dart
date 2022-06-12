import 'package:flutter/material.dart';

import '../../providers/navigator_provider.dart';
import '../common/login/login_sub_navigation.dart';
import '../common/navigation_target.dart';
import 'artists/page_artist_detail.dart';
import 'home/page_home.dart';
import 'player/page_fm_playing.dart';
import 'player/page_playing.dart';
import 'playlists/page_album_detail.dart';
import 'playlists/page_playlist_detail.dart';
import 'settings/page_setting.dart';
import 'user/page_user_detail.dart';
import 'widgets/slide_up_page_route.dart';

class MobileNavigatorController extends NavigatorController {
  MobileNavigatorController() {
    _pages.add(NavigationTargetMy());
    notifyListeners();
  }

  final _pages = <NavigationTarget>[];

  @override
  void back() {
    if (canBack) {
      _pages.removeLast();
      notifyListeners();
    }
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
  List<Page> get pages =>
      _pages.map(_buildPage).toList(growable: false);

  Page<dynamic> _buildPage(NavigationTarget target) {
    final Widget page;
    var slideUp = false;
    switch (target.runtimeType) {
      case NavigationTargetDiscover:
      case NavigationTargetMy:
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
        slideUp = true;
        break;
      case NavigationTargetFmPlaying:
        page = const PagePlayingFm();
        slideUp = true;
        break;
      case NavigationTargetUser:
        page = UserDetailPage(userId: (target as NavigationTargetUser).userId);
        break;
      case NavigationTargetLogin:
        page = const LoginNavigator();
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
      default:
        throw Exception('Unknown navigation type: $target');
    }
    if (slideUp) {
      return SlideUpPage(
        child: page,
        name: target.runtimeType.toString(),
      );
    }
    return MaterialPage<dynamic>(
      child: page,
      name: target.runtimeType.toString(),
    );
  }
}
