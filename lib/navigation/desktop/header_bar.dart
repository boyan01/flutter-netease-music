import 'package:flutter/material.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/desktop/navigator.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: const [
          SizedBox(
            width: 180,
            child: _HeaderNavigationButtons(),
          )
        ],
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
