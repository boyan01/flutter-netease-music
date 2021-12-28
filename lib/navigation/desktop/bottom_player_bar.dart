import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/repository.dart';

import '../../providers/navigator_provider.dart';
import '../common/buttons.dart';
import '../common/navigation_target.dart';
import '../common/player_progress.dart';
import 'player/page_playing_list.dart';
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
        final controller = ref.read(navigatorProvider.notifier);

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
    final hasTrack = ref.watch(playingTrackProvider) != null;
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
              AppIconButton(
                size: 24,
                onPressed: () {
                  ref.read(playerProvider).skipToPrevious();
                },
                enable: hasTrack && !playingFm,
                icon: Icons.skip_previous,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 20),
              if (ref.watch(isPlayingProvider))
                AppIconButton(
                  size: 30,
                  enable: hasTrack,
                  onPressed: () => ref.read(playerProvider).pause(),
                  icon: Icons.pause,
                  padding: EdgeInsets.zero,
                )
              else
                AppIconButton(
                  size: 32,
                  enable: hasTrack,
                  onPressed: () => ref.read(playerProvider).play(),
                  icon: Icons.play_arrow,
                  padding: EdgeInsets.zero,
                ),
              const SizedBox(width: 20),
              AppIconButton(
                size: 24,
                enable: hasTrack,
                onPressed: () => ref.read(playerProvider).skipToNext(),
                padding: EdgeInsets.zero,
                icon: Icons.skip_next,
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
    final hasTrack = ref.watch(playingTrackProvider) != null;
    return AppIconButton(
      tooltip: playingFm
          ? context.strings.personalFmPlaying
          : context.strings.playingList,
      size: 24,
      enable: hasTrack && !playingFm,
      onPressed: () {
        final state = ref.read(showPlayingListProvider.notifier).state;
        ref.read(showPlayingListProvider.notifier).state = !state;
      },
      icon: playingFm ? Icons.radio : Icons.playlist_play,
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
    final enable = ref.watch(playingTrackProvider) != null;
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
              value: (volume * 100).clamp(0.0, 100.0),
              max: 100.0,
              onChanged: enable
                  ? (value) {
                      ref.read(playerProvider).setVolume(value / 100);
                    }
                  : null,
              onChangeEnd: enable
                  ? (value) {
                      ref.read(playerProvider).setVolume(value / 100);
                    }
                  : null,
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
