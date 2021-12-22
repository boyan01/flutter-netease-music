import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/desktop/navigator.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/repository.dart';

import '../common/navigation_target.dart';
import '../common/player_progress.dart';
import 'widgets/slider.dart';

class BottomPlayerBar extends StatelessWidget {
  const BottomPlayerBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      child: SizedBox(
        height: 64,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Expanded(child: _PlayingItemWidget()),
                SizedBox(width: 20),
                _CenterControllerWidget(),
                SizedBox(width: 20),
                Expanded(child: _PlayerControlWidget()),
              ],
            ),
            const Align(alignment: Alignment.topCenter, child: _ProgressBar()),
          ],
        ),
      ),
    );
  }
}

class _PlayingItemWidget extends ConsumerWidget {
  const _PlayingItemWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(playingTrackProvider);
    if (track == null) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () {
        final player = ref.read(playerProvider);
        final controller = context.read<DesktopNavigatorController>();

        if (player.trackList.isFM) {
          if (controller.current is! NavigationTargetFmPlaying) {
            controller.navigate(NavigationTargetFmPlaying());
          }
        } else {
          if (controller.current is NavigationTargetPlaying) {
            controller.back();
          } else {
            controller.navigate(NavigationTargetPlaying());
          }
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(width: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image(
              image: CachedImage(track.imageUrl!),
              width: 48,
              height: 48,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  track.name,
                  style: context.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  track.displaySubtitle,
                  style: context.textTheme.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterControllerWidget extends ConsumerWidget {
  const _CenterControllerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingFm = ref.watch(
      playerStateProvider.select((value) => value.playingList.isFM),
    );
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
                mouseCursor: playingFm
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.click,
                onPressed: playingFm
                    ? null
                    : () {
                        ref.read(playerProvider).skipToPrevious();
                      },
                icon: const Icon(Icons.skip_previous, size: 24),
              ),
              const SizedBox(width: 20),
              if (ref.watch(isPlayingProvider))
                IconButton(
                  splashRadius: 30,
                  padding: EdgeInsets.zero,
                  onPressed: () => ref.read(playerProvider).pause(),
                  icon: const Icon(Icons.pause, size: 32),
                )
              else
                IconButton(
                  splashRadius: 32,
                  padding: EdgeInsets.zero,
                  onPressed: () => ref.read(playerProvider).play(),
                  icon: const Icon(Icons.play_arrow, size: 32),
                ),
              const SizedBox(width: 20),
              IconButton(
                splashRadius: 24,
                padding: EdgeInsets.zero,
                onPressed: () => ref.read(playerProvider).skipToNext(),
                icon: const Icon(Icons.skip_next, size: 24),
              ),
            ],
          ),
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
      children: const [
        Spacer(),
        _VolumeControl(),
        SizedBox(width: 10),
        _PlayingListButton(),
        SizedBox(width: 36),
      ],
    );
  }
}

class _PlayingListButton extends ConsumerWidget {
  const _PlayingListButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingFm = ref.watch(
      playerStateProvider.select((value) => value.playingList.isFM),
    );
    return IconButton(
      tooltip: playingFm
          ? context.strings.personalFmPlaying
          : context.strings.playingList,
      splashRadius: 24,
      padding: EdgeInsets.zero,
      mouseCursor:
          !playingFm ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onPressed: playingFm
          ? null
          : () {
              // TODO: implement
              toast(context.strings.todo);
            },
      icon: Icon(
        playingFm ? Icons.radio : Icons.playlist_play,
        size: 24,
      ),
    );
  }
}

class _VolumeControl extends ConsumerWidget {
  const _VolumeControl({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(
      playerStateProvider.select((value) => value.volume),
    );
    final enable = ref.watch(
      playerStateProvider.select((value) => value.playingTrack != null),
    );
    return Row(
      children: [
        if (volume <= 0.01)
          const Icon(Icons.volume_mute, size: 24)
        else if (volume < 0.5)
          const Icon(Icons.volume_down, size: 24)
        else
          const Icon(Icons.volume_up, size: 24),
        SizedBox(
          width: 120,
          child: SliderTheme(
            data: const SliderThemeData(
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 6,
                elevation: 0,
              ),
              trackHeight: 4,
              trackShape: RoundedRectSliderTrackShape(),
              overlayShape: RoundSliderOverlayShape(
                overlayRadius: 10,
              ),
            ),
            child: Slider(
              value: volume * 100,
              max: enable ? 100 : 0,
              onChanged: (value) {
                ref.read(playerProvider).setVolume(value / 100);
              },
              onChangeEnd: (value) {
                ref.read(playerProvider).setVolume(value / 100);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingTrack = ref.watch(playingTrackProvider);
    if (playingTrack == null) {
      return const SizedBox.shrink();
    }
    return const SizedBox(
      height: 10,
      child: FractionalTranslation(
        translation: Offset(0, -0.5),
        child: SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 6,
              elevation: 0,
            ),
            trackShape: UnboundedRectangularSliderTrackShape(),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: 10,
            ),
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: PlayerProgressSlider(),
        ),
      ),
    );
  }
}
