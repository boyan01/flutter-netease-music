import 'package:flutter/material.dart';
import 'package:quiet/navigation/desktop/page_setting.dart';
import 'package:quiet/navigation/desktop/player/page_fm_playing.dart';
import 'package:quiet/navigation/desktop/playlist/page_playlist.dart';

import '../../providers/navigator_provider.dart';
import '../common/navigation_target.dart';
import 'discover.dart';
import 'playlist/page_album_detail.dart';

class DesktopNavigatorController extends NavigatorController {
  DesktopNavigatorController() {
    _pages.add(_buildPage(NavigationTarget.discover()));
    notifyListeners();
  }

  final _pages = <MaterialPage<dynamic>>[];

  final _popPages = <MaterialPage<dynamic>>[];

  @override
  bool get canBack => _pages.length > 1 || _showPlayingPage != null;

  @override
  bool get canForward => _popPages.isNotEmpty;

  @override
  NavigationTarget get current => _showPlayingPage != null
      ? _showPlayingPage!
      : (_pages.last.key! as ValueKey<NavigationTarget>).value;

  NavigationTargetPlaying? _showPlayingPage;

  @override
  void navigate(NavigationTarget target) {
    assert(_pages.isNotEmpty, 'Navigation stack is empty');
    if (current.isTheSameTarget(target)) {
      debugPrint('Navigation: already on $target');
      return;
    }
    if (target is NavigationTargetPlaying) {
      _showPlayingPage = target;
    } else {
      _showPlayingPage = null;
      if (!current.isTheSameTarget(target)) {
        _pages.add(_buildPage(target));
      }
    }
    _popPages.clear();
    notifyListeners();
  }

  @override
  void forward() {
    if (canForward) {
      _pages.add(_popPages.removeLast());
      notifyListeners();
    }
  }

  @override
  void back() {
    if (_showPlayingPage != null) {
      _showPlayingPage = null;
      notifyListeners();
      return;
    }
    if (canBack) {
      _popPages.add(_pages.removeLast());
      notifyListeners();
    }
  }

  @override
  List<Page> get pages => _pages;

  MaterialPage<dynamic> _buildPage(NavigationTarget target) {
    final Widget page;
    if (target is NavigationTargetDiscover) {
      page = const DiscoverPage();
    } else if (target is NavigationTargetSettings) {
      page = const PageSetting();
    } else if (target is NavigationTargetPlaylist) {
      page = PagePlaylist(playlistId: target.playlistId);
    } else if (target is NavigationTargetFmPlaying) {
      page = const PageFmPlaying();
    } else if (target is NavigationTargetAlbumDetail) {
      page = PageAlbumDetail(albumId: target.albumId);
    } else {
      throw Exception('Unknown navigation type: $target');
    }
    return MaterialPage<dynamic>(
      child: page,
      name: target.runtimeType.toString(),
      key: ValueKey(target),
    );
  }
}
