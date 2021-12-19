import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material/player/progress_track_container.dart';
import 'package:quiet/navigation/desktop/navigator.dart';

import '../../component/utils/time.dart';
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
                  splashRadius: 30,
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

class _ProgressBar extends HookWidget {
  const _ProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userTrackingValue = useState<double?>(null);
    final playingTrack = context.playingTrack;
    if (playingTrack == null || context.player.duration == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 10,
      child: FractionalTranslation(
        translation: const Offset(0, -0.5),
        child: SliderTheme(
          data: const SliderThemeData(
            trackHeight: 2,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 6,
              elevation: 0,
            ),
            trackShape: UnboundedRoundSliderTrackShape(),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: 10,
            ),
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: ProgressTrackingContainer(
            builder: (context) {
              final position =
                  context.player.position?.inMilliseconds.toDouble() ?? 0.0;
              final duration =
                  context.player.duration?.inMilliseconds.toDouble() ?? 0.0;
              return Slider(
                max: duration,
                value: (userTrackingValue.value ?? position).clamp(
                  0.0,
                  duration,
                ),
                onChangeStart: (value) => userTrackingValue.value = value,
                onChanged: (value) => userTrackingValue.value = value,
                semanticFormatterCallback: (value) =>
                    getTimeStamp(value.round()),
                onChangeEnd: (value) {
                  userTrackingValue.value = null;
                  context.player
                    ..seekTo(Duration(milliseconds: value.round()))
                    ..play();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
