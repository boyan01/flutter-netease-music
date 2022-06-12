import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/navigator_provider.dart';
import '../../common/navigation_target.dart';
import 'main_page_discover.dart';
import 'main_page_my.dart';
import 'tab_discover.dart';
import 'tab_search.dart';

class PageHome extends StatelessWidget {
  PageHome({super.key, required this.selectedTab})
      : assert(selectedTab.isMobileHomeTab());

  final NavigationTarget selectedTab;

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (selectedTab.runtimeType) {
      case NavigationTargetDiscover:
        body = const HomeTabDiscover();
        break;
      case NavigationTargetMy:
        body = const MainPageMy();
        break;
      case NavigationTargetLibrary:
        body = const MainPageDiscover();
        break;
      case NavigationTargetSearch:
        body = const HomeTabSearch();
        break;
      default:
        assert(false, 'unsupported tab: $selectedTab');
        body = const MainPageMy();
        break;
    }
    return Scaffold(appBar: const _AppBar(), body: body);
  }
}

class _AppBar extends ConsumerWidget with PreferredSizeWidget {
  const _AppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      actions: [
        IconButton(
          onPressed: () => ref
              .read(navigatorProvider.notifier)
              .navigate(NavigationTargetSettings()),
          icon: const Icon(Icons.settings),
          splashRadius: 24,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
