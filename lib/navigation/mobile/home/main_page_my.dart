import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../utils/system/scroll_controller.dart';
import '../../common/buttons.dart';
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

class _UserLibraryBody extends HookConsumerWidget {
  const _UserLibraryBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useAppScrollController();
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
            SliverAppBar(
              leading: AppIconButton(
                onPressed: () => ref
                    .read(navigatorProvider.notifier)
                    .navigate(NavigationTargetSettings()),
                icon: FluentIcons.settings_20_regular,
              ),
              actions: [
                AppIconButton(
                  onPressed: () => ref
                      .read(navigatorProvider.notifier)
                      .navigate(NavigationTargetSearch()),
                  icon: FluentIcons.search_20_regular,
                )
              ],
              pinned: true,
              elevation: 0,
            ),
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
          leading: AppIconButton(
            onPressed: () => ref
                .read(navigatorProvider.notifier)
                .navigate(NavigationTargetSettings()),
            icon: FluentIcons.settings_20_regular,
          ),
          actions: [
            AppIconButton(
              onPressed: () => ref
                  .read(navigatorProvider.notifier)
                  .navigate(NavigationTargetSearch()),
              icon: FluentIcons.search_20_regular,
            )
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
