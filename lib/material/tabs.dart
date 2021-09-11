import 'package:flutter/material.dart';
import 'package:quiet/component/global/settings.dart';

class PrimaryTabIndicator extends UnderlineTabIndicator {
  PrimaryTabIndicator({Color color = Colors.white})
      : super(
            insets: const EdgeInsets.only(bottom: 4),
            borderSide: BorderSide(color: color, width: 2.0));
}

///网易云音乐风格的TabBar
class RoundedTabBar extends StatelessWidget implements PreferredSizeWidget {
  const RoundedTabBar({Key? key, required this.tabs}) : super(key: key);
  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: TabBar(
            indicator:
                PrimaryTabIndicator(color: context.colorScheme.secondary),
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Theme.of(context).textTheme.bodyText1!.color,
            tabs: tabs),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
