import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../extension.dart';
import '../../../providers/player_provider.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

import '../../../media/tracks/tracks_player.dart';

class WindowsTaskBar extends StatelessWidget {
  const WindowsTaskBar({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.windows) {
      return child;
    }
    return _WindowsTaskBar(child: child);
  }
}

class _WindowsTaskBar extends ConsumerWidget {
  const _WindowsTaskBar({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<TracksPlayerState>(playerStateProvider, (previous, next) {
      if (next.playingTrack == null) {
        WindowsTaskbar.resetThumbnailToolbar();
      } else {
        WindowsTaskbar.setThumbnailToolbar([
          ThumbnailToolbarButton(
            ThumbnailToolbarAssetIcon(
                'assets/icons/baseline_skip_previous_white_24dp.ico'),
            context.strings.skipToPrevious,
            () {
              ref.read(playerProvider).skipToPrevious();
            },
            mode: next.playingList.isFM
                ? ThumbnailToolbarButtonMode.disabled
                : 0x0,
          ),
          if (next.isPlaying)
            ThumbnailToolbarButton(
              ThumbnailToolbarAssetIcon(
                  'assets/icons/baseline_pause_white_24dp.ico'),
              context.strings.pause,
              () {
                ref.read(playerProvider).pause();
              },
            )
          else
            ThumbnailToolbarButton(
              ThumbnailToolbarAssetIcon(
                  'assets/icons/baseline_play_arrow_white_24dp.ico'),
              context.strings.play,
              () {
                ref.read(playerProvider).play();
              },
            ),
          ThumbnailToolbarButton(
            ThumbnailToolbarAssetIcon(
                'assets/icons/baseline_skip_next_white_24dp.ico'),
            context.strings.skipToNext,
            () {
              ref.read(playerProvider).skipToNext();
            },
          ),
        ]);
      }
    });
    return child;
  }
}
