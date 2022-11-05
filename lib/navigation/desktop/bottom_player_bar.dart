import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../extension.dart';
import '../../providers/navigator_provider.dart';
import '../../providers/player_provider.dart';
import '../../repository.dart';
import '../common/buttons.dart';
import '../common/like_button.dart';
import '../common/navigation_target.dart';
import '../common/player/player_progress.dart';
import '../common/player/state.dart';
import '../common/shape.dart';
import 'player/page_playing_list.dart';
import 'widgets/hover_overlay.dart';
import 'widgets/slider.dart';

class BottomPlayerBar extends StatelessWidget {
  const BottomPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Material(
              elevation: 10,
              child: Row(
                children: const [
                  Expanded(child: _PlayingItemWidget()),
                  SizedBox(width: 20),
                  _CenterControllerWidget(),
                  SizedBox(width: 20),
                  Expanded(child: _PlayerControlWidget()),
                ],
              ),
            ),
          ),
          const Align(alignment: Alignment.topCenter, child: _ProgressBar()),
        ],
      ),
    );
  }
}

class _PlayingItemWidget extends ConsumerWidget {
  const _PlayingItemWidget({super.key});

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
                  style: context.textTheme.bodySmall,
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
  const _CenterControllerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingFm = ref.watch(
      playerStateProvider.select((value) => value.playingList.isFM),
    );
    final hasTrack = ref.watch(playingTrackProvider) != null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIconButton(
              onPressed: () {
                ref.read(playerProvider).skipToPrevious();
              },
              enable: hasTrack && !playingFm,
              icon: FluentIcons.previous_16_filled,
            ),
            const SizedBox(width: 20),
            if (ref.watch(isPlayingProvider))
              AppIconButton(
                enable: hasTrack,
                onPressed: () => ref.read(playerProvider).pause(),
                icon: FluentIcons.pause_16_filled,
              )
            else
              AppIconButton(
                enable: hasTrack,
                onPressed: () => ref.read(playerProvider).play(),
                icon: FluentIcons.play_20_filled,
              ),
            const SizedBox(width: 20),
            AppIconButton(
              enable: hasTrack,
              onPressed: () => ref.read(playerProvider).skipToNext(),
              padding: EdgeInsets.zero,
              icon: FluentIcons.next_20_filled,
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayerControlWidget extends ConsumerWidget {
  const _PlayerControlWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFmPlaying = ref.watch(
      playerStateProvider.select((value) => value.playingList.isFM),
    );
    return Row(
      children: [
        const Spacer(),
        LikeButton.current(context),
        const SizedBox(width: 10),
        if (!isFmPlaying)
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: PlayerRepeatModeIconButton(),
          ),
        const _PlayingListButton(),
        const SizedBox(width: 10),
        const _VolumeControl(),
        const SizedBox(width: 20),
      ],
    );
  }
}

class _PlayingListButton extends ConsumerWidget {
  const _PlayingListButton({super.key});

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
      enable: hasTrack && !playingFm,
      onPressed: () {
        final state = ref.read(showPlayingListProvider.notifier).state;
        ref.read(showPlayingListProvider.notifier).state = !state;
      },
      icon: playingFm ? Icons.radio : FluentIcons.list_16_regular,
    );
  }
}

class _VolumeControl extends HookConsumerWidget {
  const _VolumeControl({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(
      playerStateProvider.select((value) => value.volume),
    );
    final enable = ref.watch(playingTrackProvider) != null;

    final isMuted = volume <= 0.0001;
    final volumeBeforeMute = useRef<double>(0.5);

    final IconData icon;
    if (isMuted) {
      icon = FluentIcons.speaker_off_16_regular;
    } else if (volume <= 0.2) {
      icon = FluentIcons.speaker_0_16_regular;
    } else if (volume <= 0.5) {
      icon = FluentIcons.speaker_1_16_regular;
    } else {
      icon = FluentIcons.speaker_2_16_regular;
    }

    Widget child = AppIconButton(
      enable: enable,
      onPressed: () {
        final player = ref.read(playerProvider);
        if (isMuted) {
          player.setVolume(volumeBeforeMute.value);
        } else {
          volumeBeforeMute.value = player.volume;
          player.setVolume(0);
        }
      },
      icon: icon,
    );
    if (enable) {
      child = HoverOverlay(
        targetAnchor: Alignment.topCenter,
        followerAnchor: Alignment.bottomCenter,
        overlayBuilder: (context, progress) {
          return Opacity(
            opacity: progress,
            child: const _OverlayVolumeSlider(),
          );
        },
        child: child,
      );
    }
    return child;
  }
}

class _OverlayVolumeSlider extends ConsumerWidget {
  const _OverlayVolumeSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(
      playerStateProvider.select((value) => value.volume),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: context.colorScheme.background,
        elevation: 10,
        shape: const BorderWithArrow.bottom(radius: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: RotatedBox(
            quarterTurns: 3,
            child: SizedBox(
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
                  max: 100,
                  onChanged: (value) {
                    ref.read(playerProvider).setVolume(value / 100);
                  },
                  onChangeEnd: (value) {
                    ref.read(playerProvider).setVolume(value / 100);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingTrack = ref.watch(playingTrackProvider);
    if (playingTrack == null) {
      return const SizedBox.shrink();
    }
    return const SizedBox(
      height: 20,
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
    );
  }
}
