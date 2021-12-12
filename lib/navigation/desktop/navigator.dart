import 'package:flutter/material.dart';

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

class DesktopNavigator extends StatefulWidget {
  const DesktopNavigator({
    Key? key,
  }) : super(key: key);

  @override
  State<DesktopNavigator> createState() => _DesktopNavigatorState();

  static void push(BuildContext context, NavigationType type) {
    context.findAncestorStateOfType<_DesktopNavigatorState>()!._push(type);
  }
}

class _DesktopNavigatorState extends State<DesktopNavigator> {
  final pages = <MaterialPage<dynamic>>[];

  @override
  void initState() {
    super.initState();
    pages.add(_buildPage(NavigationType.discover()));
  }

  void _push(NavigationType type) {
    setState(() {
      pages.add(_buildPage(type));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: List.of(pages),
      onPopPage: (route, result) {
        if (route.isFirst) {
          return false;
        }
        setState(() {
          pages.removeLast();
        });
        return true;
      },
    );
  }
}
