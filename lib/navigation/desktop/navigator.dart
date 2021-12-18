import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import './discover.dart';
import 'playlist/playlist_page.dart';

abstract class NavigationType with EquatableMixin {
  NavigationType();

  factory NavigationType.discover() => NavigationTargetDiscover();

  factory NavigationType.settings() => NavigationTargetSettings();

  factory NavigationType.playlist({required int playlistId}) =>
      NavigationTargetPlaylist(playlistId);

  @override
  List<Object?> get props => const [];
}

class NavigationTargetDiscover extends NavigationType {}

class NavigationTargetSettings extends NavigationType {}

class NavigationTargetPlaylist extends NavigationType {
  NavigationTargetPlaylist(this.playlistId);

  final int playlistId;

  @override
  List<Object?> get props => [playlistId];
}

class _PageKey extends ValueKey<NavigationType> {
  const _PageKey(NavigationType value) : super(value);

  @override
  bool operator ==(Object other) {
    return identical(this, other);
  }

  @override
  int get hashCode => super.hashCode;
}

MaterialPage<dynamic> _buildPage(NavigationType type) {
  final Widget page;
  if (type is NavigationTargetDiscover) {
    page = const DiscoverPage();
  } else if (type is NavigationTargetSettings) {
    page = const Text('Settings');
  } else if (type is NavigationTargetPlaylist) {
    page = PlaylistPage(playlistId: type.playlistId);
  } else {
    throw Exception('Unknown navigation type: $type');
  }
  return MaterialPage<dynamic>(
    child: page,
    name: type.runtimeType.toString(),
    key: _PageKey(type),
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

  NavigationType get current =>
      (_pages.last.key! as ValueKey<NavigationType>).value;

  void navigate(NavigationType type) {
    if (_pages.isNotEmpty && current == type) {
      debugPrint('Navigation: already on $type');
      return;
    }
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
