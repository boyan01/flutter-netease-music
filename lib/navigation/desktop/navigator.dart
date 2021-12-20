import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import './discover.dart';
import '../common/navigation_target.dart';
import 'page_playing.dart';
import 'page_setting.dart';
import 'playlist/page_playlist.dart';

MaterialPage<dynamic> _buildPage(NavigationTarget target) {
  final Widget page;
  if (target is NavigationTargetDiscover) {
    page = const DiscoverPage();
  } else if (target is NavigationTargetSettings) {
    page = const PageSetting();
  } else if (target is NavigationTargetPlaylist) {
    page = PagePlaylist(playlistId: target.playlistId);
  } else {
    throw Exception('Unknown navigation type: $target');
  }
  return MaterialPage<dynamic>(
    child: page,
    name: target.runtimeType.toString(),
    key: ValueKey(target),
  );
}

class DesktopNavigatorController with ChangeNotifier {
  DesktopNavigatorController() {
    _pages.add(_buildPage(NavigationTarget.discover()));
  }

  final _pages = <MaterialPage<dynamic>>[];

  final _popPages = <MaterialPage<dynamic>>[];

  bool get canBack => _pages.length > 1 || _showPlayingPage != null;

  bool get canForward => _popPages.isNotEmpty;

  NavigationTarget get current => _showPlayingPage != null
      ? _showPlayingPage!
      : (_pages.last.key! as ValueKey<NavigationTarget>).value;

  NavigationTargetPlaying? _showPlayingPage;

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
      child: const PagePlaying(),
    );
  }
}
