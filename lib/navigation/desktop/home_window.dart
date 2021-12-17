import 'package:flutter/material.dart';

import 'bottom_player_bar.dart';
import 'navigation_side_bar.dart';
import 'navigator.dart';

class HomeWindow extends StatelessWidget {
  const HomeWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: const [
                SizedBox(width: 180, child: NavigationSideBar()),
                Expanded(child: ClipRect(child: DesktopNavigator())),
              ],
            ),
          ),
          const BottomPlayerBar(),
        ],
      ),
    );
  }
}
