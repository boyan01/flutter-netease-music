import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/mobile/home/main_page_discover.dart';
import 'package:quiet/navigation/mobile/home/main_page_my.dart';

import '../../../providers/navigator_provider.dart';
import '../../common/navigation_target.dart';
import '../widgets/bottom_player_bar.dart';
import 'tab_discover.dart';

class PageHome extends StatelessWidget {
  PageHome({Key? key, required this.selectedTab})
      : assert(selectedTab.isMobileHomeTab()),
        super(key: key);

  final NavigationTarget selectedTab;

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (selectedTab.runtimeType) {
      case NavigationTargetDiscover:
        body = const HomeTabDiscover();
        break;
      case NavigationTargetMy:
        body = MainPageMy();
        break;
      case NavigationTargetLibrary:
        body = MainPageDiscover();
        break;
      default:
        body = Center(
          child: Text(
            selectedTab.runtimeType.toString(),
            style: Theme.of(context).textTheme.headline4,
          ),
        );
    }

    return Scaffold(
      appBar: const _AppBar(),
      body: body,
      bottomNavigationBar: _HomeBottomNavigationBar(selectedTab: selectedTab),
    );
  }
}

class _AppBar extends ConsumerWidget with PreferredSizeWidget {
  const _AppBar({
    Key? key,
  }) : super(key: key);

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

class _HomeBottomNavigationBar extends ConsumerWidget {
  const _HomeBottomNavigationBar({
    Key? key,
    required this.selectedTab,
  }) : super(key: key);

  final NavigationTarget selectedTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BottomPlayerBar(),
        BottomNavigationBar(
          currentIndex: kMobileHomeTabs.indexWhere(
            (element) => element == selectedTab.runtimeType,
          ),
          selectedItemColor: context.colorScheme.primary,
          unselectedItemColor: context.colorScheme.onBackground,
          onTap: (index) {
            final NavigationTarget target;
            switch (index) {
              case 0:
                target = NavigationTargetDiscover();
                break;
              case 1:
                target = NavigationTargetLibrary();
                break;
              case 2:
                target = NavigationTargetMy();
                break;
              case 3:
                target = NavigationTargetSearch();
                break;
              default:
                assert(false, 'unknown index: $index');
                target = NavigationTargetDiscover();
            }
            ref.read(navigatorProvider.notifier).navigate(target);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.compass_calibration_rounded),
              label: context.strings.discover,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.my_library_music),
              label: context.strings.library,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: context.strings.my,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              label: context.strings.search,
            ),
          ],
        ),
      ],
    );
  }
}
