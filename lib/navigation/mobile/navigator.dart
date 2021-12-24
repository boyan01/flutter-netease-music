import 'package:flutter/material.dart';
import 'package:quiet/navigation/mobile/home/page_home.dart';
import 'package:quiet/navigation/mobile/player/page_playing.dart';
import 'package:quiet/navigation/mobile/settings/page_setting.dart';
import 'package:quiet/navigation/mobile/widgets/slide_up_page_route.dart';

import '../../providers/navigator_provider.dart';
import '../common/navigation_target.dart';
import 'player/page_fm_playing.dart';
import 'playlists/page_playlist_detail.dart';
import 'user/page_user_detail.dart';

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
      _pages.map((e) => _buildPage(e)).toList(growable: false);

  Page<dynamic> _buildPage(NavigationTarget target) {
    final Widget page;
    bool slideUp = false;
    switch (target.runtimeType) {
      case NavigationTargetDiscover:
      case NavigationTargetMy:
      case NavigationTargetLibrary:
      case NavigationTargetSearch:
        page = PageHome(selectedTab: target);
        break;
      case NavigationTargetSettings:
        page = PageSettings();
        break;
      case NavigationTargetPlaylist:
        page = PlaylistDetailPage(
          (target as NavigationTargetPlaylist).playlistId,
        );
        break;
      case NavigationTargetPlaying:
        page = PlayingPage();
        slideUp = true;
        break;
      case NavigationTargetFmPlaying:
        page = PagePlayingFm();
        slideUp = true;
        break;
      case NavigationTargetUser:
        page = UserDetailPage(userId: (target as NavigationTargetUser).userId);
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
