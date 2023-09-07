import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../common/buttons.dart';
import '../../common/image.dart';
import '../../common/navigation_target.dart';
import '_playlists.dart';
import '_preset_grid.dart';
import '_profile.dart';

///the first page display in page_main
class MainPageMy extends ConsumerStatefulWidget {
  const MainPageMy({super.key});

  @override
  ConsumerState<MainPageMy> createState() => _MainPageMyState();
}

class _MainPageMyState extends ConsumerState<MainPageMy>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userId = ref.watch(userProvider)?.userId;
    if (userId == null) {
      return const _NotLogin();
    }
    return const _UserLibraryBody();
  }

  @override
  bool get wantKeepAlive => true;
}

class _UserLibraryBody extends HookWidget {
  const _UserLibraryBody({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final headerHeight = const <double>[
      UserProfileSection.height + 16,
      70 + 16, // PresetGridSection
      76,
      8,
    ].reduce((a, b) => a + b);
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            _AppBar(controller: scrollController),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const UserProfileSection(),
                  const SizedBox(height: 16),
                  const PresetGridSection(),
                  const SizedBox(height: 16),
                  const MainFavoritePlayListWidget(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: MyPlayListsHeaderDelegate(),
            ),
            UserPlayListSection(
              scrollController: scrollController,
              firstItemOffset: headerHeight,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotLogin extends ConsumerWidget {
  const _NotLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          leading: AppIconButton(
            color: context.colorScheme.textPrimary,
            onPressed: () => ref
                .read(navigatorProvider.notifier)
                .navigate(NavigationTargetSettings()),
            icon: FluentIcons.settings_20_regular,
          ),
          actions: [
            AppIconButton(
              color: context.colorScheme.textPrimary,
              onPressed: () => ref
                  .read(navigatorProvider.notifier)
                  .navigate(NavigationTargetSearch()),
              icon: FluentIcons.search_20_regular,
            ),
          ],
          elevation: 0,
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Text(
              context.strings.playlistLoginDescription,
              style: context.textTheme.bodyLarge,
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => ref
              .read(navigatorProvider.notifier)
              .navigate(NavigationTargetLogin()),
          child: Text(context.strings.login),
        ),
        const Spacer(),
      ],
    );
  }
}

class _AppBar extends HookConsumerWidget {
  const _AppBar({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollOffset = useListenable(controller).position.pixels;
    const maxOffset = 32;
    final t = scrollOffset.clamp(0.0, maxOffset) / maxOffset;
    final background = context.colorScheme.background.withOpacity(t);

    final Widget userInfo;
    final user = ref.watch(userProvider);
    if (user == null) {
      userInfo = const SizedBox.shrink();
    } else {
      userInfo = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: AppImage(
              url: user.avatarUrl,
              width: 28,
              height: 28,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            user.nickname,
            style: context.textTheme.bodyLarge,
          ),
        ],
      );
    }

    return SliverAppBar(
      leading: AppIconButton(
        color: context.colorScheme.textPrimary,
        onPressed: () => ref
            .read(navigatorProvider.notifier)
            .navigate(NavigationTargetSettings()),
        icon: FluentIcons.settings_20_regular,
      ),
      centerTitle: true,
      title: AnimatedCrossFade(
        firstChild: const Row(),
        secondChild: userInfo,
        duration: const Duration(milliseconds: 200),
        crossFadeState:
            t > 0.9 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      ),
      backgroundColor: background,
      actions: [
        AppIconButton(
          color: context.colorScheme.textPrimary,
          onPressed: () => ref
              .read(navigatorProvider.notifier)
              .navigate(NavigationTargetSearch()),
          icon: FluentIcons.search_20_regular,
        ),
      ],
      pinned: true,
      elevation: 0,
    );
  }
}
