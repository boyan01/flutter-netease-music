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
                        child:
                            DesktopNavigator(controller: navigatorController),
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
    );
  }
}
