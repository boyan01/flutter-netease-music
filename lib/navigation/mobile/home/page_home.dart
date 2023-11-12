import 'package:flutter/material.dart';

import '../../../extension.dart';
import '../../common/navigation_target.dart';
import 'main_page_discover.dart';
import 'main_page_my.dart';

class PageHome extends StatelessWidget {
  PageHome({super.key, required this.selectedTab})
      : assert(selectedTab.isMobileHomeTab());

  final NavigationTarget selectedTab;

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (selectedTab) {
      case NavigationTargetLibrary _:
        body = const MainPageMy();
        break;
      case NavigationTargetDiscover _:
        body = const MainPageDiscover();
        break;
      default:
        assert(false, 'unsupported tab: $selectedTab');
        body = const MainPageMy();
        break;
    }
    return Scaffold(
      backgroundColor: context.colorScheme.backgroundSecondary,
      body: body,
    );
  }
}
