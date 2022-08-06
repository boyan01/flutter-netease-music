import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../component/utils/scroll_controller.dart';
import '../../extension.dart';
import '../../providers/account_provider.dart';
import '../../providers/navigator_provider.dart';
import '../common/navigation_target.dart';
import 'playlist/user_playlists.dart';
import 'widgets/navigation_tile.dart';

class NavigationSideBar extends StatelessWidget {
  const NavigationSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surfaceWithElevation(1),
      shadowColor: Colors.transparent,
      elevation: 5,
      child: CustomScrollView(
        controller: AppScrollController(),
        slivers: const [
          _PresetItems(),
          SliverSidebarUserPlaylist(),
        ],
      ),
    );
  }
}

class _PresetItems extends ConsumerWidget {
  const _PresetItems({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(
      navigatorProvider.select((value) => value.current),
    );
    final navigator = ref.read(navigatorProvider.notifier);
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          NavigationTile(
            icon: const Icon(Icons.compass_calibration_rounded),
            title: Text(context.strings.discover),
            isSelected: currentPage is NavigationTargetDiscover,
            onTap: () => navigator.navigate(NavigationTargetDiscover()),
          ),
          if (ref.watch(isLoginProvider))
            NavigationTile(
              icon: const Icon(Icons.today),
              title: Text(context.strings.dailyRecommend),
              isSelected: currentPage is NavigationTargetDailyRecommend,
              onTap: () => navigator.navigate(NavigationTargetDailyRecommend()),
            ),
          NavigationTile(
            icon: const Icon(Icons.radio),
            title: Text(context.strings.personalFM),
            isSelected: currentPage is NavigationTargetFmPlaying,
            onTap: () => navigator.navigate(NavigationTargetFmPlaying()),
          ),
          NavigationTitle(title: context.strings.library),
          NavigationTile(
            icon: const Icon(Icons.history_rounded),
            title: Text(context.strings.latestPlayHistory),
            isSelected: currentPage is NavigationTargetPlayHistory,
            onTap: () => navigator.navigate(NavigationTargetPlayHistory()),
          ),
          NavigationTile(
            icon: const Icon(Icons.cloud_upload_rounded),
            title: Text(context.strings.cloudMusic),
            isSelected: false,
            onTap: () => navigator.navigate(NavigationTargetCloudMusic()),
          ),
        ],
      ),
    );
  }
}
