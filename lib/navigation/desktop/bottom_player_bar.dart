import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/desktop/navigator.dart';

import '../common/player_progress.dart';

class BottomPlayerBar extends StatelessWidget {
  const BottomPlayerBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Expanded(child: _PlayingItemWidget()),
          SizedBox(width: 20),
          SizedBox(width: 400, child: _CenterControllerWidget()),
          SizedBox(width: 20),
          Expanded(child: _PlayerControlWidget()),
        ],
      ),
    );
  }
}

class _PlayingItemWidget extends StatelessWidget {
  const _PlayingItemWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final track = context.playingTrack;
    if (track == null) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () {
        final controller = context.read<DesktopNavigatorController>();
        if (controller.current is NavigationTargetPlaying) {
          controller.back();
        } else {
          controller.navigate(NavigationTargetPlaying());
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image(
              image: CachedImage(track.imageUrl!),
              width: 56,
              height: 56,
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                track.name,
                style: context.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                track.displaySubtitle,
                style: context.textTheme.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CenterControllerWidget extends StatelessWidget {
  const _CenterControllerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          height: 32,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                splashRadius: 24,
                padding: EdgeInsets.zero,
                onPressed: () => context.player.skipToPrevious(),
                icon: const Icon(Icons.skip_previous, size: 24),
              ),
              const SizedBox(width: 20),
              if (context.isPlaying)
                IconButton(
                  splashRadius: 32,
                  padding: EdgeInsets.zero,
                  onPressed: () => context.player.pause(),
                  icon: const Icon(Icons.pause, size: 32),
                )
              else
                IconButton(
                  splashRadius: 32,
                  padding: EdgeInsets.zero,
                  onPressed: () => context.player.play(),
                  icon: const Icon(Icons.play_arrow, size: 32),
                ),
              const SizedBox(width: 20),
              IconButton(
                splashRadius: 24,
                padding: EdgeInsets.zero,
                onPressed: () => context.player.skipToNext(),
                icon: const Icon(Icons.skip_next, size: 24),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 32,
          child: DurationProgressBar(),
        ),
      ],
    );
  }
}

class _PlayerControlWidget extends StatelessWidget {
  const _PlayerControlWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        IconButton(
          splashRadius: 24,
          padding: EdgeInsets.zero,
          onPressed: () {
            // TODO: implement
            toast(context.strings.todo);
          },
          icon: const Icon(
            Icons.volume_up,
            size: 24,
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          splashRadius: 24,
          padding: EdgeInsets.zero,
          onPressed: () {
            // TODO: implement
            toast(context.strings.todo);
          },
          icon: const Icon(
            Icons.playlist_play,
            size: 24,
          ),
        ),
        const SizedBox(width: 36),
      ],
    );
  }
}
