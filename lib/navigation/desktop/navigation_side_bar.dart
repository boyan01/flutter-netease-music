import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component.dart';
import 'package:quiet/navigation/desktop/login/login_dialog.dart';
import 'package:quiet/navigation/desktop/widgets/navigation_tile.dart';
import 'package:quiet/pages/account/account.dart';

class NavigationSideBar extends StatelessWidget {
  const NavigationSideBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const _ProfileTile(),
          const SizedBox(height: 20),
          NavigationTile(
            icon: const Icon(Icons.compass_calibration_rounded),
            title: Text(context.strings.discover),
            isSelected: true,
            onTap: () {},
          ),
          NavigationTile(
            icon: const Icon(Icons.radio),
            title: Text(context.strings.personalFM),
            isSelected: false,
            onTap: () {},
          ),
          _ItemTitle(title: context.strings.library),
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
          NavigationTile(
            icon: const Icon(Icons.favorite_rounded),
            title: Text(context.strings.favoriteSongList),
            isSelected: false,
            onTap: () {},
          ),
          _ItemTitle(title: context.strings.playlist),
        ],
      ),
    );
  }
}

class _ItemTitle extends StatelessWidget {
  const _ItemTitle({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 28, bottom: 12),
      child: Text(title, style: context.theme.textTheme.subtitle1.bold),
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
