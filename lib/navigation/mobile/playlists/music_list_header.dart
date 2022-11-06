import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../common/navigation_target.dart';
import '../../common/playlist/track_list_container.dart';

/// The header view of MusicList
class MusicListHeader extends ConsumerWidget implements PreferredSizeWidget {
  const MusicListHeader(this.count, {this.tail, super.key});

  final int count;

  final Widget? tail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: context.colorScheme.background,
      child: InkWell(
        onTap: () {
          final player = ref.read(playerProvider);
          final controller = TrackTileContainer.controller(context);
          if (player.trackList.id == controller.playlistId) {
            ref
                .read(navigatorProvider.notifier)
                .navigate(NavigationTargetPlaying());
            if (!player.isPlaying) {
              player.play();
            }
          } else {
            controller.play(null);
          }
        },
        child: SizedBox.fromSize(
          size: preferredSize,
          child: Row(
            children: [
              const SizedBox(width: 16),
              SizedBox.square(
                dimension: 24,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      FluentIcons.play_circle_20_filled,
                      color: context.colorScheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.strings.playAll,
                style: context.textTheme.titleSmall,
              ),
              const SizedBox(width: 6),
              Text(
                '(${context.strings.musicCountFormat(count)})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (tail != null) tail!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
