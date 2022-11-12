import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../extension.dart';
import '../../providers/account_provider.dart';
import '../../providers/navigator_provider.dart';
import '../../repository/cached_image.dart';
import '../../utils/callback_window_listener.dart';
import '../common/navigation_target.dart';
import 'login/login_dialog.dart';
import 'popup/user_info_popup.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      elevation: 10,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: defaultTargetPlatform == TargetPlatform.macOS ? 20 : 0,
          ),
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: 180, child: _HeaderNavigationButtons()),
                const Expanded(child: MoveWindow.expand()),
                const _SearchBar(),
                const SizedBox(width: 20, child: MoveWindow.expand()),
                const _ProfileWidget(),
                const SizedBox(width: 10, child: MoveWindow.expand()),
                const _SettingButton(),
                const SizedBox(width: 20, child: MoveWindow.expand()),
                if (defaultTargetPlatform == TargetPlatform.windows)
                  const _WindowCaptionButtonGroup(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderNavigationButtons extends ConsumerWidget {
  const _HeaderNavigationButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorState = ref.watch(navigatorProvider);
    final navigator = ref.read(navigatorProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Expanded(child: MoveWindow.expand()),
        IconButton(
          splashRadius: 20,
          mouseCursor: navigatorState.canBack
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          iconSize: 24,
          onPressed: navigatorState.canBack ? navigator.back : null,
          icon: const Icon(Icons.navigate_before),
        ),
        IconButton(
          splashRadius: 20,
          mouseCursor: navigatorState.canForward
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onPressed: navigatorState.canForward ? navigator.forward : null,
          iconSize: 24,
          icon: const Icon(Icons.navigate_next),
        ),
      ],
    );
  }
}

class _SearchBar extends HookConsumerWidget {
  const _SearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textEditingController = useTextEditingController();
    return SizedBox(
      height: 24,
      width: 128,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: context.colorScheme.textPrimary.withOpacity(0.5),
          ),
          color: context.colorScheme.surface,
        ),
        child: Row(
          children: [
            const SizedBox(width: 10, child: MoveWindow.expand()),
            const Icon(Icons.search, size: 16),
            const SizedBox(width: 4, child: MoveWindow.expand()),
            Expanded(
              child: TextField(
                cursorHeight: 12,
                controller: textEditingController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration.collapsed(
                  hintText: context.strings.search,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: context.textTheme.bodySmall!.color,
                  ),
                ),
                onSubmitted: (value) => ref
                    .read(navigatorProvider.notifier)
                    .navigate(NavigationTargetSearchMusicResult(value.trim())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileWidget extends HookConsumerWidget {
  const _ProfileWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    final Widget child;

    final link = useMemoized(LayerLink.new);

    if (user == null) {
      child = Row(
        children: [
          const Icon(FluentIcons.person_16_regular, size: 16),
          const SizedBox(width: 10),
          Text(
            context.strings.login,
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: 14,
            ),
          ),
        ],
      );
    } else {
      child = Row(
        children: [
          ClipOval(
            child: Image(
              image: CachedImage(user.avatarUrl),
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              user.nickname,
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    return CompositedTransformTarget(
      link: link,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (user == null) {
            showLoginDialog(context: context);
          } else {
            showUserInfoPopup(link: link);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: child,
        ),
      ),
    );
  }
}

class _SettingButton extends ConsumerWidget {
  const _SettingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      navigatorProvider
          .select((value) => value.current is NavigationTargetSettings),
    );
    return IconButton(
      icon: const Icon(Icons.settings),
      iconSize: 20,
      splashRadius: 20,
      color: selected ? context.colorScheme.primary : null,
      onPressed: () => ref
          .read(navigatorProvider.notifier)
          .navigate(NavigationTargetSettings()),
    );
  }
}

class _WindowCaptionButtonGroup extends HookWidget {
  const _WindowCaptionButtonGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final isMaximized = useState(false);
    useMemoized(() async {
      isMaximized.value = await WindowManager.instance.isMaximized();
    });
    useEffect(
      () {
        final listener = CallbackWindowListener(
          onWindowMaximized: () {
            isMaximized.value = true;
          },
          onWindowRestored: () {
            isMaximized.value = false;
          },
          onWindowMoveCallback: () {
            isMaximized.value = false;
          },
        );
        WindowManager.instance.addListener(listener);
        return () => WindowManager.instance.removeListener(listener);
      },
      [WindowManager.instance],
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WindowButton(
          icon: const Icon(FluentIcons.subtract_20_regular),
          onTap: WindowManager.instance.minimize,
        ),
        _WindowButton(
          icon: isMaximized.value
              ? const Icon(FluentIcons.square_multiple_20_regular)
              : const Icon(FluentIcons.maximize_20_regular),
          onTap: () {
            if (isMaximized.value) {
              WindowManager.instance.restore();
            } else {
              WindowManager.instance.maximize();
            }
            isMaximized.value = !isMaximized.value;
          },
        ),
        _WindowButton(
          icon: const Icon(FluentIcons.dismiss_20_regular),
          onTap: () {
            exit(0);
          },
        ),
      ],
    );
  }
}

class _WindowButton extends StatelessWidget {
  const _WindowButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final Widget icon;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      radius: 20,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox.square(
          dimension: 20,
          child: IconTheme.merge(
            data: const IconThemeData(size: 20),
            child: icon,
          ),
        ),
      ),
    );
  }
}

class MoveWindow extends StatelessWidget {
  const MoveWindow({
    super.key,
    required this.child,
    this.enableDoubleClickInteraction = true,
  });

  const MoveWindow.expand({super.key})
      : child = const SizedBox.expand(),
        enableDoubleClickInteraction = true;

  final Widget child;

  final bool enableDoubleClickInteraction;

  @override
  Widget build(BuildContext context) {
    final needMoveWindow = const [
      TargetPlatform.windows,
      TargetPlatform.macOS,
    ].contains(defaultTargetPlatform);
    if (!needMoveWindow) {
      return child;
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        WindowManager.instance.startDragging();
      },
      onDoubleTap: !enableDoubleClickInteraction
          ? null
          : () async {
              if (await WindowManager.instance.isMaximized()) {
                await WindowManager.instance.restore();
              } else {
                await WindowManager.instance.maximize();
              }
            },
      child: child,
    );
  }
}
