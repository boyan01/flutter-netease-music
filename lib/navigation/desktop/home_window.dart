import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/navigation/desktop/player/page_playing.dart';
import 'package:quiet/navigation/desktop/widgets/hotkeys.dart';

import '../../providers/navigator_provider.dart';
import '../common/navigation_target.dart';
import '../common/navigator.dart';
import 'bottom_player_bar.dart';
import 'header_bar.dart';
import 'navigation_side_bar.dart';

class HomeWindow extends StatelessWidget {
  const HomeWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GlobalHotkeys(child: _WindowLayout());
  }
}

class _WindowLayout extends StatelessWidget {
  const _WindowLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: _OverflowBox(
        child: Material(
          child: Column(
            children: const [
              HeaderBar(),
              _ContentLayout(),
              BottomPlayerBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentLayout extends StatelessWidget {
  const _ContentLayout({Key? key}) : super(key: key);

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
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxHeight = math.max(constraints.maxHeight, 640.0);
      final maxWidth = math.max(constraints.maxWidth, 800.0);
      return OverflowBox(
        minHeight: 640,
        maxHeight: maxHeight,
        minWidth: 800,
        maxWidth: maxWidth,
        child: child,
      );
    });
  }
}

class DesktopPlayingPageContainer extends ConsumerWidget {
  const DesktopPlayingPageContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingPage = ref.watch(navigatorProvider
        .select((value) => value.current is NavigationTargetPlaying));
    return Stack(
      children: [
        child,
        ClipRect(child: _SlideAnimatedPlayingPage(visible: playingPage)),
      ],
    );
  }
}

class _SlideAnimatedPlayingPage extends HookWidget {
  const _SlideAnimatedPlayingPage({
    Key? key,
    required this.visible,
  }) : super(key: key);

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: visible ? 1.0 : 0.0,
    );
    useEffect(() {
      if (visible) {
        controller.forward();
      } else {
        controller.reverse();
      }
    }, [visible]);

    final animation = useMemoized(() {
      final tween = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      );
      return tween.animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }, [controller]);
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
