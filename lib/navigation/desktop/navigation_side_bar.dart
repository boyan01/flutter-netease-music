import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../component/utils/scroll_controller.dart';
import '../../extension.dart';
import '../../providers/account_provider.dart';
import '../../providers/navigator_provider.dart';
import '../../repository.dart';
import '../common/navigation_target.dart';
import 'login/login_dialog.dart';
import 'playlist/user_playlists.dart';
import 'widgets/navigation_tile.dart';

class NavigationSideBar extends StatelessWidget {
  const NavigationSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surface,
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
          const SizedBox(height: 20),
          const _ProfileTile(),
          const SizedBox(height: 20),
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
            isSelected: false,
            onTap: () {},
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

class _ProfileTile extends HookConsumerWidget {
  const _ProfileTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return NavigationTile(
        icon: const Icon(Icons.person_outline_rounded),
        title: Text(context.strings.login),
        isSelected: false,
        onTap: () {
          showLoginDialog(context: context);
        },
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          toast(context.strings.todo);
        },
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              const SizedBox(width: 4),
              ClipOval(
                child: Image(
                  image: CachedImage(user.avatarUrl),
                  width: 32,
                  height: 32,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  user.nickname,
                  style: context.theme.textTheme.bodyText2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
