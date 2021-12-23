import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:quiet/navigation/common/navigation_target.dart';

import '../navigation/desktop/discover.dart';
import '../navigation/desktop/page_setting.dart';
import '../navigation/desktop/player/page_fm_playing.dart';
import '../navigation/desktop/playlist/page_playlist.dart';

final navigatorProvider =
    StateNotifierProvider<NavigatorController, NavigatorState>(
  (ref) {
    final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
    if (isDesktop) {
      return DesktopNavigatorController();
    } else {
      return MobileNavigatorController();
    }
  },
);

class NavigatorState with EquatableMixin {
  const NavigatorState({
    required this.pages,
    required this.canBack,
    required this.canForward,
    required this.current,
  });

  final List<Page> pages;

  final bool canBack;

  final bool canForward;

  final NavigationTarget current;

  @override
  List<Object?> get props => [pages, canBack, canForward, current];
}

@sealed
abstract class NavigatorController extends StateNotifier<NavigatorState> {
  NavigatorController()
      : super(NavigatorState(
          pages: const [],
          canBack: false,
          canForward: false,
          // no meaning, just for init
          current: NavigationTargetDiscover(),
        ));

  List<Page> get pages;

  bool get canBack;

  bool get canForward;

  NavigationTarget get current;

  void navigate(NavigationTarget target);

  void back();

  void forward();

  @protected
  void notifyListeners() {
    state = NavigatorState(
      pages: pages,
      canBack: canBack,
      canForward: canForward,
      current: current,
    );
  }
}

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

class MobileNavigatorController extends NavigatorController {
  MobileNavigatorController() {
    _pages.add(_buildPage(NavigationTarget.discover()));
    notifyListeners();
  }

  final _pages = <MaterialPage<dynamic>>[];

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
  NavigationTarget get current =>
      (_pages.last.key! as ValueKey<NavigationTarget>).value;

  @override
  void navigate(NavigationTarget target) {
    if (current.isTheSameTarget(target)) {
      debugPrint('Navigation: already on $target');
      return;
    }
    _pages.add(_buildPage(target));
    notifyListeners();
  }

  @override
  List<Page> get pages => _pages;

  MaterialPage<dynamic> _buildPage(NavigationTarget target) {
    // TODO: implement _buildPage
    throw UnimplementedError();
  }
}
