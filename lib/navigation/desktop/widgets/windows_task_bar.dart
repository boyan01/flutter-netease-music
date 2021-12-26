import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

import '../../../repository.dart';

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
    ref.listen<MapEntry<Track?, bool>>(
        playerStateProvider
            .select((value) => MapEntry(value.playingTrack, value.isPlaying)),
        (previous, next) {
      if (next.key == null) {
        WindowsTaskbar.clearThumbnailToolbar();
      } else {
        WindowsTaskbar.setThumbnailToolbar([
          ThumbnailToolbarButton(
            ThumbnailToolbarAssetIcon(
                'assets/icons/baseline_skip_previous_white_24dp.ico'),
            context.strings.skipToPrevious,
            () {
              ref.read(playerProvider).skipToPrevious();
            },
          ),
          if (next.value)
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
