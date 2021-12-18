import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import './discover.dart';
import 'playlist/playlist_page.dart';

abstract class NavigationType {
  NavigationType();

  factory NavigationType.discover() => _Discover();

  factory NavigationType.settings() => _Settings();

  factory NavigationType.playlist({required int playlistId}) =>
      _Playlist(playlistId);
}

class _Discover extends NavigationType {}

class _Settings extends NavigationType {}

class _Playlist extends NavigationType {
  _Playlist(this.playlistId);

  final int playlistId;
}

MaterialPage<dynamic> _buildPage(NavigationType type) {
  final Widget page;
  if (type is _Discover) {
    page = const DiscoverPage();
  } else if (type is _Settings) {
    page = const Text('Settings');
  } else if (type is _Playlist) {
    page = PlaylistPage(playlistId: type.playlistId);
  } else {
    throw Exception('Unknown navigation type: $type');
  }
  return MaterialPage<dynamic>(
    child: page,
    name: type.runtimeType.toString(),
    key: ValueKey(type),
  );
}

class DesktopNavigatorController with ChangeNotifier {
  DesktopNavigatorController() {
    navigate(NavigationType.discover());
  }

  final _pages = <MaterialPage<dynamic>>[];

  final _popPages = <MaterialPage<dynamic>>[];

  bool get canBack => _pages.length > 1;

  bool get canForward => _popPages.isNotEmpty;

  void navigate(NavigationType type) {
    _pages.add(_buildPage(type));
    _popPages.clear();
    notifyListeners();
  }

  void forward() {
    if (canForward) {
      _pages.add(_popPages.removeLast());
      notifyListeners();
    }
  }

  void back() {
    if (canBack) {
      _popPages.add(_pages.removeLast());
      notifyListeners();
    }
  }
}

class DesktopNavigator extends HookWidget {
  const DesktopNavigator({Key? key, required this.controller})
      : super(key: key);

  final DesktopNavigatorController controller;

  @override
  Widget build(BuildContext context) {
    useListenable(controller);
    return Navigator(
      pages: List.of(controller._pages),
      onPopPage: (route, result) {
        if (route.isFirst) {
          return false;
        }
        controller.back();
        return true;
      },
    );
  }
}
