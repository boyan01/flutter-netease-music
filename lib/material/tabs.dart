import 'package:flutter/material.dart';
import '../extension.dart';

class PrimaryTabIndicator extends UnderlineTabIndicator {
  PrimaryTabIndicator({Color color = Colors.white})
      : super(
          insets: const EdgeInsets.only(bottom: 4),
          borderSide: BorderSide(color: color, width: 2),
        );
}

///网易云音乐风格的TabBar
class RoundedTabBar extends StatelessWidget implements PreferredSizeWidget {
  const RoundedTabBar({super.key, required this.tabs});
  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: TabBar(
          indicator: PrimaryTabIndicator(color: context.colorScheme.secondary),
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Theme.of(context).textTheme.bodyText1!.color,
          tabs: tabs,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
