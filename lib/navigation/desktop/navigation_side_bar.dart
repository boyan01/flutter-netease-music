import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quiet/component.dart';
import 'package:quiet/navigation/desktop/widgets/navigation_tile.dart';

class NavigationSideBar extends StatelessWidget {
  const NavigationSideBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          NavigationTile(
            icon: const Icon(Icons.compass_calibration_rounded),
            title: Text(context.strings.discover),
            isSelected: true,
            onTap: () {},
          ),
          NavigationTile(
            icon: const Icon(Icons.radio),
            title: Text(context.strings.personalFM),
            isSelected: false,
            onTap: () {},
          ),
          _ItemTitle(title: context.strings.library),
          NavigationTile(
            icon: const Icon(Icons.history_rounded),
            title: Text(context.strings.latestPlayHistory),
            isSelected: false,
            onTap: () {},
          ),
          NavigationTile(
            icon: const Icon(Icons.cloud_upload_rounded),
            title: Text(context.strings.cloudMusic),
            isSelected: false,
            onTap: () {},
          ),
          NavigationTile(
            icon: const Icon(Icons.favorite_rounded),
            title: Text(context.strings.favoriteSongList),
            isSelected: false,
            onTap: () {},
          ),
          _ItemTitle(title: context.strings.playlist),
        ],
      ),
    );
  }
}

class _ItemTitle extends StatelessWidget {
  const _ItemTitle({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 28, bottom: 12),
      child: Text(title, style: context.theme.textTheme.subtitle1.bold),
    );
  }
}
