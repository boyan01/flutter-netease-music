import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import './discover.dart';
import 'playing_page.dart';
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

class NavigationTargetPlaying extends NavigationType {}

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
    _pages.add(_buildPage(NavigationType.discover()));
  }

  final _pages = <MaterialPage<dynamic>>[];

  final _popPages = <MaterialPage<dynamic>>[];

  bool get canBack => _pages.length > 1 || _showPlayingPage != null;

  bool get canForward => _popPages.isNotEmpty;

  NavigationType get current => _showPlayingPage != null
      ? _showPlayingPage!
      : (_pages.last.key! as ValueKey<NavigationType>).value;

  NavigationTargetPlaying? _showPlayingPage;

  void navigate(NavigationType type) {
    assert(_pages.isNotEmpty, 'Navigation stack is empty');
    if (current == type) {
      debugPrint('Navigation: already on $type');
      return;
    }
    if (type is NavigationTargetPlaying) {
      _showPlayingPage = type;
    } else {
      _showPlayingPage = null;
      if (current != type) {
        _pages.add(_buildPage(type));
        _popPages.clear();
      }
    }
    notifyListeners();
  }

  void forward() {
    if (canForward) {
      _pages.add(_popPages.removeLast());
      notifyListeners();
    }
  }

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

class DesktopPlayingPageContainer extends HookWidget {
  const DesktopPlayingPageContainer({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  final DesktopNavigatorController controller;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final playingPage =
        useListenable(controller).current is NavigationTargetPlaying;
    return Stack(
      children: [
        child,
        ClipRect(child: _SlideAnimatedPlayingPage(visible: playingPage)),
      ],
    );
  }
}

class _SlideAnimatedPlayingPage extends HookWidget {
  const _SlideAnimatedPlayingPage({
    Key? key,
    required this.visible,
  }) : super(key: key);

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: visible ? 1.0 : 0.0,
    );
    useEffect(() {
      if (visible) {
        controller.forward();
      } else {
        controller.reverse();
      }
    }, [visible]);

    final animation = useMemoized(() {
      final tween = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      );
      return tween.animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }, [controller]);
    final offset = useAnimation(animation);

    if (controller.isDismissed) {
      return const SizedBox.shrink();
    }
    return FractionalTranslation(
      translation: offset,
      child: const PlayingPage(),
    );
  }
}
