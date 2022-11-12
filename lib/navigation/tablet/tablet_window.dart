import 'package:flutter/material.dart';

import '../common/navigator.dart';
import '../desktop/bottom_player_bar.dart';
import '../desktop/header_bar.dart';
import '../desktop/home_window.dart';
import '../desktop/navigation_side_bar.dart';

class TableWindow extends StatelessWidget {
  const TableWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Material(
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                const HeaderBar(),
                MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  removeTop: true,
                  child: const _ContentLayout(),
                ),
                SizedBox(height: 64 + bottomPadding),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomPlayerBar(
                bottomExtraPadding: bottomPadding,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentLayout extends StatelessWidget {
  const _ContentLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DesktopPlayingPageContainer(
        child: Row(
          children: const [
            SizedBox(width: 200, child: NavigationSideBar()),
            Expanded(
              child: ClipRect(
                child: AppNavigator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
