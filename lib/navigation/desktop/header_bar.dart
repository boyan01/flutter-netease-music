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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SizedBox(width: 180, child: _HeaderNavigationButtons()),
          Spacer(),
          _SearchBar(),
          SizedBox(width: 10),
          _SettingButton(),
          SizedBox(width: 20),
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
            borderRadius: BorderRadius.circular(4),
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
