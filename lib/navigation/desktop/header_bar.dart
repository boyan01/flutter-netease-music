import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/desktop/navigator.dart';
import 'package:window_manager/window_manager.dart';

import 'widgets/caption_icons.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.only(
          top: defaultTargetPlatform == TargetPlatform.macOS ? 20 : 4,
          bottom: 4,
        ),
        child: SizedBox(
          height: 42,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 180, child: _HeaderNavigationButtons()),
              const Expanded(child: _MoveWindow.expand()),
              const _SearchBar(),
              const SizedBox(width: 10, child: _MoveWindow.expand()),
              const _SettingButton(),
              const SizedBox(width: 20, child: _MoveWindow.expand()),
              if (defaultTargetPlatform == TargetPlatform.windows)
                const _WindowCaptionButtonGroup(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderNavigationButtons extends StatelessWidget {
  const _HeaderNavigationButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DesktopNavigatorController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Expanded(child: _MoveWindow.expand()),
        IconButton(
          splashRadius: 20,
          mouseCursor: controller.canBack
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          iconSize: 24,
          onPressed: controller.canBack ? controller.back : null,
          icon: const Icon(Icons.navigate_before),
        ),
        IconButton(
          splashRadius: 20,
          mouseCursor: controller.canForward
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onPressed: controller.canForward ? controller.forward : null,
          iconSize: 24,
          icon: const Icon(Icons.navigate_next),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 180,
      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(
              color: context.colorScheme.onBackground.withOpacity(0.5),
              width: 1,
            ),
          ),
          prefixIconColor: context.colorScheme.onBackground,
          hintText: context.strings.search,
          prefixIcon: const Icon(Icons.search, size: 20),
          hintStyle: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.caption!.color,
          ),
        ),
      ),
    );
  }
}

class _SettingButton extends StatelessWidget {
  const _SettingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DesktopNavigatorController>();
    final selected = controller.current is NavigationTargetSettings;
    return IconButton(
      icon: const Icon(Icons.settings),
      iconSize: 20,
      splashRadius: 20,
      color: selected ? context.colorScheme.primary : null,
      onPressed: () => controller.navigate(NavigationTargetSettings()),
    );
  }
}

class _WindowCaptionButtonGroup extends HookWidget {
  const _WindowCaptionButtonGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMaximized = useState(false);
    useMemoized(() async {
      isMaximized.value = await WindowManager.instance.isMaximized();
    });
    useEffect(() {
      final listener = _CallbackWindowListener(onWindowMaximized: () {
        isMaximized.value = true;
      }, onWindowRestored: () {
        isMaximized.value = false;
      }, onWindowMoved: () {
        isMaximized.value = false;
      });
      WindowManager.instance.addListener(listener);
      return () => WindowManager.instance.removeListener(listener);
    }, [WindowManager.instance]);
    return Row(children: [
      _WindowButton(
        icon: MinimizeIcon(color: context.iconTheme.color!),
        onTap: () {
          WindowManager.instance.minimize();
        },
      ),
      _WindowButton(
        icon: isMaximized.value
            ? RestoreIcon(color: context.iconTheme.color!)
            : MaximizeIcon(color: context.iconTheme.color!),
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
        icon: CloseIcon(color: context.iconTheme.color!),
        onTap: () {
          exit(0);
        },
      ),
    ]);
  }
}

class _WindowButton extends StatelessWidget {
  const _WindowButton({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  final Widget icon;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      iconSize: 24,
      splashRadius: 20,
      onPressed: onTap,
    );
  }
}

class _MoveWindow extends StatelessWidget {
  const _MoveWindow({Key? key, required this.child}) : super(key: key);

  const _MoveWindow.expand() : child = const SizedBox.expand();

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.windows) {
      return child;
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        WindowManager.instance.startDragging();
      },
      onDoubleTap: () async {
        if (await WindowManager.instance.isMaximized()) {
          WindowManager.instance.restore();
        } else {
          WindowManager.instance.maximize();
        }
      },
      child: child,
    );
  }
}

class _CallbackWindowListener extends WindowListener {
  _CallbackWindowListener({
    this.onWindowMinimized,
    this.onWindowMaximized,
    this.onWindowRestored,
    this.onWindowResized,
    this.onWindowMoved,
  });

  final VoidCallback? onWindowMinimized;
  final VoidCallback? onWindowMaximized;
  final VoidCallback? onWindowRestored;
  final VoidCallback? onWindowResized;
  final VoidCallback? onWindowMoved;

  @override
  void onWindowMaximize() {
    onWindowMaximized?.call();
  }

  @override
  void onWindowMinimize() {
    onWindowMinimized?.call();
  }

  @override
  void onWindowRestore() {
    onWindowRestored?.call();
  }

  @override
  void onWindowResize() {
    onWindowResized?.call();
  }

  @override
  void onWindowMove() {
    onWindowMoved?.call();
  }
}
