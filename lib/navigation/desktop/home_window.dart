import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart' as provider;

import 'bottom_player_bar.dart';
import 'header_bar.dart';
import 'navigation_side_bar.dart';
import 'navigator.dart';

class HomeWindow extends HookWidget {
  const HomeWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigatorController = useMemoized(() => DesktopNavigatorController());
    return provider.ChangeNotifierProvider(
      create: (_) => navigatorController,
      child: ClipRect(
        child: _OverflowBox(
          child: Material(
            child: Column(
              children: [
                const HeaderBar(),
                Expanded(
                  child: DesktopPlayingPageContainer(
                    controller: navigatorController,
                    child: Row(
                      children: [
                        const SizedBox(width: 200, child: NavigationSideBar()),
                        Expanded(
                          child: ClipRect(
                            child: DesktopNavigator(
                                controller: navigatorController),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const BottomPlayerBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverflowBox extends StatelessWidget {
  const _OverflowBox({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxHeight = math.max(constraints.maxHeight, 720.0);
      final maxWidth = math.max(constraints.maxWidth, 960.0);
      return OverflowBox(
        minHeight: 720,
        maxHeight: maxHeight,
        minWidth: 960,
        maxWidth: maxWidth,
        child: child,
      );
    });
  }
}
