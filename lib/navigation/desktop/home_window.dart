import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/navigator_provider.dart';
import '../common/navigation_target.dart';
import '../common/navigator.dart';
import 'bottom_player_bar.dart';
import 'header_bar.dart';
import 'navigation_side_bar.dart';
import 'player/page_playing.dart';
import 'player/page_playing_list.dart';
import 'widgets/windows_task_bar.dart';

class HomeWindow extends StatelessWidget {
  const HomeWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return const WindowsTaskBar(child: _WindowLayout());
  }
}

class _WindowLayout extends StatelessWidget {
  const _WindowLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: _OverflowBox(
        child: Material(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: const [
                  HeaderBar(),
                  _ContentLayout(),
                  SizedBox(height: 64),
                ],
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: BottomPlayerBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentLayout extends StatelessWidget {
  const _ContentLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DesktopPlayingPageContainer(
        child: Row(
          children: const [
            SizedBox(width: 200, child: NavigationSideBar()),
            Expanded(
              child: ClipRect(
                child: AppNavigator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverflowBox extends StatelessWidget {
  const _OverflowBox({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = math.max<double>(constraints.maxHeight, 640);
        final maxWidth = math.max<double>(constraints.maxWidth, 800);
        return OverflowBox(
          minHeight: 640,
          maxHeight: maxHeight,
          minWidth: 800,
          maxWidth: maxWidth,
          child: child,
        );
      },
    );
  }
}

class DesktopPlayingPageContainer extends ConsumerWidget {
  const DesktopPlayingPageContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingPage = ref.watch(
      navigatorProvider
          .select((value) => value.current is NavigationTargetPlaying),
    );
    final showPlayingList = ref.watch(showPlayingListProvider);
    return Stack(
      children: [
        child,
        ClipRect(child: _SlideAnimatedPlayingPage(visible: playingPage)),
        _SlideAnimatedPlayingListOverlay(visible: showPlayingList),
      ],
    );
  }
}

class _SlideAnimatedPlayingListOverlay extends HookConsumerWidget {
  const _SlideAnimatedPlayingListOverlay({
    super.key,
    required this.visible,
  });

  final bool visible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: visible ? 1.0 : 0.0,
    );
    useEffect(
      () {
        if (visible) {
          controller.forward();
        } else {
          controller.reverse();
        }
      },
      [visible],
    );

    final animation = useMemoized(
      () {
        final tween = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        );
        return tween.animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeInOut,
          ),
        );
      },
      [controller],
    );
    final offset = useAnimation(animation);

    if (controller.isDismissed) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () =>
                ref.read(showPlayingListProvider.notifier).state = false,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
        ),
        ClipRect(
          child: SizedBox(
            width: 400,
            child: FractionalTranslation(
              translation: offset,
              child: const PagePlayingList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideAnimatedPlayingPage extends HookWidget {
  const _SlideAnimatedPlayingPage({
    super.key,
    required this.visible,
  });

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: visible ? 1.0 : 0.0,
    );
    useEffect(
      () {
        if (visible) {
          controller.forward();
        } else {
          controller.reverse();
        }
      },
      [visible],
    );

    final animation = useMemoized(
      () {
        final tween = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        );
        return tween.animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeInOut,
          ),
        );
      },
      [controller],
    );
    final offset = useAnimation(animation);

    if (controller.isDismissed) {
      return const SizedBox.shrink();
    }
    return FractionalTranslation(
      translation: offset,
      child: const PagePlaying(),
    );
  }
}
