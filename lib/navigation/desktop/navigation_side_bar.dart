import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/desktop/login/login_dialog.dart';
import 'package:quiet/navigation/desktop/playlist/user_playlists.dart';
import 'package:quiet/navigation/desktop/widgets/navigation_tile.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/repository.dart';

import '../../component/utils/scroll_controller.dart';
import '../common/navigation_target.dart';
import 'navigator.dart';

class NavigationSideBar extends StatelessWidget {
  const NavigationSideBar({Key? key}) : super(key: key);

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

class _PresetItems extends StatelessWidget {
  const _PresetItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigator = context.watch<DesktopNavigatorController>();
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
            isSelected: navigator.current is NavigationTargetDiscover,
            onTap: () => navigator.navigate(NavigationTargetDiscover()),
          ),
          NavigationTile(
            icon: const Icon(Icons.radio),
            title: Text(context.strings.personalFM),
            isSelected: false,
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
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends HookConsumerWidget {
  const _ProfileTile({Key? key}) : super(key: key);

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
              crossAxisAlignment: CrossAxisAlignment.center,
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
            )),
      ),
    );
  }
}
