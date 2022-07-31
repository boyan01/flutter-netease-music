import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../component/utils/scroll_controller.dart';
import '../../../extension.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../common/navigation_target.dart';
import '../widgets/context_menu.dart';
import '../widgets/highlight_clickable_text.dart';

final showPlayingListProvider =
    StateNotifierProvider<SimpleStateNotifier<bool>, bool>(
  (ref) {
    ref.listen<NavigationTarget>(
      navigatorProvider.select((value) => value.current),
      (previous, next) {
        ref.notifier.state = false;
      },
    ).autoRemove(ref);
    return SimpleStateNotifier(false);
  },
);

class PagePlayingList extends HookConsumerWidget {
  const PagePlayingList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = useFocusNode();
    useEffect(
      () {
        void onFocusChange() {
          if (!node.hasFocus) {
            // delay to avoid focus conflict with the playlist toggle button.
            Future.delayed(const Duration(milliseconds: 100), () {
              ref.read(showPlayingListProvider.notifier).state = false;
            });
          }
        }

        node.addListener(onFocusChange);
        return () {
          node.removeListener(onFocusChange);
        };
      },
      [node],
    );
    return Focus(
      autofocus: true,
      focusNode: node,
      child: Material(
        color: context.colorScheme.background,
        elevation: 4,
        child: Column(
          children: [
            const _PlayingListTitle(),
            const Divider(indent: 20, endIndent: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _PlayingList(
                    layoutHeight: constraints.maxHeight,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayingListTitle extends ConsumerWidget {
  const _PlayingListTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingList = ref.watch(playingListProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Text(
            context.strings.currentPlaying,
            style: context.textTheme.titleMedium.bold,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                context.strings.musicCountFormat(playingList.tracks.length),
                style: context.textTheme.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PlayingList extends HookConsumerWidget {
  const _PlayingList({
    super.key,
    required this.layoutHeight,
  });

  final double layoutHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingList = ref.watch(playingListProvider);

    final initialOffset = useMemoized<double>(() {
      final playing = ref.read(playerStateProvider).playingTrack;
      if (playing == null) {
        return 0;
      }
      final index = playingList.tracks.indexOf(playing);
      if (index < 0) {
        assert(false, 'playing track should be in the playing list');
        return 0;
      }

      final offset = index * _kTrackItemHeight;
      if (offset <= layoutHeight / 2) {
        return 0;
      }

      final totalHeight = playingList.tracks.length * _kTrackItemHeight;
      if (totalHeight - offset <= layoutHeight / 2) {
        return totalHeight - layoutHeight;
      }

      // ensure current track is in the middle of the list.
      return offset - layoutHeight / 2;
    });

    final controller = useAppScrollController(
      initialScrollOffset: initialOffset,
    );

    return ListView.builder(
      controller: controller,
      itemBuilder: (context, index) {
        final track = playingList.tracks[index];
        return _PlayingTrackItem(
          track: track,
          backgroundColor: index.isEven
              ? context.colorScheme.background
              : context.colorScheme.primary.withOpacity(0.04),
        );
      },
      itemCount: playingList.tracks.length,
    );
  }
}

const _kTrackItemHeight = 40.0;

class _PlayingTrackItem extends HookConsumerWidget {
  const _PlayingTrackItem({
    super.key,
    required this.track,
    required this.backgroundColor,
  });

  final Track track;

  final Color backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrentPlaying = ref.watch(
      playerStateProvider.select((value) => value.playingTrack == track),
    );
    final isPlaying = ref.watch(isPlayingProvider);
    final isSelected = useState(false);
    final isMounted = useIsMounted();
    return SizedBox(
      height: _kTrackItemHeight,
      child: Material(
        color:
            isSelected.value ? context.theme.highlightColor : backgroundColor,
        child: GestureDetector(
          onSecondaryTapUp: (details) async {
            isSelected.value = true;
            final entry = showOverlayAtPosition(
              globalPosition: details.globalPosition,
              builder: (context) => ContextMenuLayout(
                children: [
                  ContextMenuItem(
                    title: Text(context.strings.play),
                    icon: const Icon(FluentIcons.play_circle_24_regular),
                    enable: track.type != TrackType.noCopyright,
                    onTap: () {
                      ref.read(playerProvider).playFromMediaId(track.id);
                    },
                  ),
                ],
              ),
            );
            await entry.dismissed;
            if (!isMounted()) {
              return;
            }
            isSelected.value = false;
          },
          child: InkWell(
            onTap: () {
              if (track.type == TrackType.noCopyright) {
                toast(context.strings.trackNoCopyright);
                return;
              }
              ref.read(playerProvider).playFromMediaId(track.id);
            },
            child: Row(
              children: [
                const SizedBox(width: 4),
                if (isCurrentPlaying)
                  SizedBox.square(
                    dimension: 12,
                    child: Icon(
                      isPlaying
                          ? FluentIcons.pause_12_filled
                          : FluentIcons.play_12_filled,
                      color: context.colorScheme.primary,
                      size: 12,
                    ),
                  )
                else
                  const SizedBox(width: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    track.name,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: track.type == TrackType.noCopyright
                          ? context.theme.disabledColor
                          : isCurrentPlaying
                              ? context.colorScheme.primary
                              : null,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 100,
                  child: MouseHighlightText(
                    style: context.textTheme.caption?.copyWith(
                      color:
                          isCurrentPlaying ? context.colorScheme.primary : null,
                    ),
                    highlightStyle: context.textTheme.caption!.copyWith(
                      color: isCurrentPlaying
                          ? context.colorScheme.primary
                          : context.textTheme.bodyMedium!.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    children: track.artists
                        .map(
                          (artist) => MouseHighlightSpan.highlight(
                            text: artist.name,
                            onTap: () {
                              if (artist.id == 0) {
                                return;
                              }
                              ref.read(navigatorProvider.notifier).navigate(
                                    NavigationTargetArtistDetail(
                                      artist.id,
                                    ),
                                  );
                            },
                          ),
                        )
                        .separated(MouseHighlightSpan.normal(text: '/'))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 48,
                  child: Text(
                    track.duration.timeStamp,
                    style: context.textTheme.caption,
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
