import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/lyric_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../common/buttons.dart';
import '../../common/like_button.dart';
import '../../common/material/player.dart';
import '../../common/navigation_target.dart';
import '../../common/player/progress_track_container.dart';
import '../player/page_playing_list.dart';

const kBottomPlayerBarHeight = 60.0;

class AnimatedAppBottomBar extends HookConsumerWidget {
  const AnimatedAppBottomBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute =
        ref.watch(navigatorProvider.select((value) => value.current));
    final lastHomeTarget = useRef<NavigationTarget?>(null);

    final NavigationTarget currentTab;

    final bool hideNavigationBar;
    if (!kMobileHomeTabs.contains(currentRoute.runtimeType)) {
      currentTab = lastHomeTarget.value ?? NavigationTargetLibrary();
      hideNavigationBar = true;
    } else {
      currentTab = currentRoute;
      hideNavigationBar = false;
    }
    lastHomeTarget.value = currentTab;

    assert(kMobileHomeTabs.contains(currentTab.runtimeType));

    const navigationBarHeight = kBottomNavigationBarHeight + 2;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final music = ref.watch(playingTrackProvider);

    const kNoPlayerBarPages = {
      NavigationTargetPlaying,
      NavigationTargetFmPlaying,
      NavigationTargetSettings,
      NavigationTargetLogin,
      NavigationTargetLoginPassword,
    };
    const playerBarHeight = kBottomPlayerBarHeight;
    final hidePlayerBar =
        music == null || kNoPlayerBarPages.contains(currentRoute.runtimeType);

    final double height;
    final double navigationBarBottom;
    final double playerBarBottom;
    if (hidePlayerBar && hideNavigationBar) {
      height = 0;
      navigationBarBottom = -playerBarHeight - navigationBarHeight;
      playerBarBottom = -playerBarHeight;
    } else if (hidePlayerBar) {
      height = navigationBarHeight + bottomPadding;
      navigationBarBottom = bottomPadding;
      playerBarBottom = -playerBarHeight;
    } else if (hideNavigationBar) {
      height = playerBarHeight + bottomPadding;
      navigationBarBottom = -navigationBarHeight;
      playerBarBottom = bottomPadding;
    } else {
      navigationBarBottom = bottomPadding;
      playerBarBottom = navigationBarHeight + bottomPadding;
      height = playerBarHeight + navigationBarHeight + bottomPadding;
    }

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          top: 0,
          left: 0,
          right: 0,
          bottom: height,
          curve: Curves.easeInOut,
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: !hidePlayerBar || !hideNavigationBar,
            child: child,
          ),
        ),
        AnimatedPositioned(
          height: playerBarHeight,
          left: 0,
          right: 0,
          duration: const Duration(milliseconds: 300),
          bottom: playerBarBottom,
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: hidePlayerBar ? 0 : 1,
            curve: Curves.easeIn,
            child: const _MobileBottomPlayerBar(),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          bottom: navigationBarBottom,
          left: 0,
          right: 0,
          height: navigationBarHeight,
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: hideNavigationBar ? 0 : 1,
            curve: Curves.easeIn,
            child: ClipRect(
              child: MediaQuery.removePadding(
                removeBottom: true,
                context: context,
                child: HomeBottomNavigationBar(currentTab: currentTab),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          bottom: 0,
          left: 0,
          right: 0,
          curve: Curves.easeInOut,
          height: hidePlayerBar && hideNavigationBar ? 0 : bottomPadding,
          child: const Material(elevation: 8),
        ),
      ],
    );
  }
}

class _MobileBottomPlayerBar extends ConsumerWidget {
  const _MobileBottomPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(playingTrackProvider);
    final queue = ref.watch(playingListProvider);
    if (music == null) {
      return const SizedBox(height: kBottomPlayerBarHeight);
    }
    return Material(
      elevation: 8,
      child: InkWell(
        onTap: () => ref.read(navigatorProvider.notifier).navigate(
              queue.isFM
                  ? NavigationTargetFmPlaying()
                  : NavigationTargetPlaying(),
            ),
        child: SizedBox(
          height: kBottomPlayerBarHeight,
          child: Row(
            children: [
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: Image(
                  fit: BoxFit.cover,
                  image: CachedImage(music.imageUrl!),
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        music.name,
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      DefaultTextStyle(
                        maxLines: 1,
                        style: context.textTheme.bodySmall!,
                        child: _SubTitleOrLyric(music.displaySubtitle),
                      ),
                    ],
                  ),
                ),
              ),
              _PauseButton(),
              if (queue.isFM)
                LikeButton(
                  music: music,
                  likedColor: context.colorScheme.primary,
                )
              else
                AppIconButton(
                  tooltip: context.strings.playingList,
                  icon: FluentIcons.list_24_regular,
                  onPressed: () => showMobilePlayingBottomSheet(context),
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubTitleOrLyric extends ConsumerWidget {
  const _SubTitleOrLyric(this.subtitle, {super.key});

  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(playingTrackProvider);
    final playingLyric = ref.watch(lyricProvider(music!.id)).valueOrNull;
    if (playingLyric == null) {
      return Text(subtitle);
    }
    return ProgressTrackingContainer(
      builder: (context) {
        final position = ref.read(playerStateProvider.notifier).position;
        final line = playingLyric
            .getLineByTimeStamp(position?.inMilliseconds ?? 0, 0)
            ?.line;
        return Text(line == null || line.isEmpty ? subtitle : line);
      },
    );
  }
}

class _PauseButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayingIndicator(
      playing: AppIconButton(
        icon: FluentIcons.pause_circle_24_regular,
        onPressed: () {
          ref.read(playerStateProvider.notifier).pause();
        },
      ),
      pausing: AppIconButton(
        icon: FluentIcons.play_circle_24_regular,
        onPressed: () {
          ref.read(playerStateProvider.notifier).play();
        },
      ),
      buffering: Container(
        height: 24,
        width: 24,
        //to fit  IconButton min width 48
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(4),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class HomeBottomNavigationBar extends ConsumerWidget {
  const HomeBottomNavigationBar({
    super.key,
    required this.currentTab,
  });

  final NavigationTarget currentTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      currentIndex: kMobileHomeTabs.indexWhere(
        (element) => element == currentTab.runtimeType,
      ),
      selectedItemColor: context.colorScheme.primary,
      unselectedItemColor: context.colorScheme.textPrimary,
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
          icon: const Icon(Icons.search),
          label: context.strings.search,
        ),
      ],
    );
  }
}
