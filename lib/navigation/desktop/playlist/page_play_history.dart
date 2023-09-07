import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/play_history_provider.dart';
import '../../../repository/data/track.dart';
import '../../common/material/flexible_app_bar.dart';
import '../../common/playlist/track_list_container.dart';
import '../widgets/playlist_collapsed_title.dart';
import '../widgets/track_tile_normal.dart';

class PagePlayHistory extends ConsumerWidget {
  const PagePlayHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(playHistoryProvider);
    return Material(
      color: context.colorScheme.background,
      child: tracks.isEmpty
          ? const _EmptyPlayHistory()
          : _PlayHistoryList(tracks: tracks),
    );
  }
}

class _EmptyPlayHistory extends StatelessWidget {
  const _EmptyPlayHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ExpandedHeader(),
        Expanded(
          child: Center(
            child: Text(
              context.strings.noPlayHistory,
              style: context.textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayHistoryList extends HookConsumerWidget {
  const _PlayHistoryList({
    super.key,
    required this.tracks,
  });

  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final absorberHandle = useMemoized(SliverOverlapAbsorberHandle.new);
    return TrackTableContainer(
      child: TrackTileContainer.simpleList(
        tracks: tracks,
        onDelete: (ref, track) async =>
            ref.read(playHistoryProvider.notifier).remove(track),
        child: CustomScrollView(
          slivers: [
            SliverOverlapAbsorber(handle: absorberHandle),
            const _PlayHistoryHeader(),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => TrackTile(
                  track: tracks[index],
                  index: index + 1,
                ),
                childCount: tracks.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayHistoryHeader extends StatelessWidget {
  const _PlayHistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: 132,
      collapsedHeight: 56,
      flexibleSpace: Material(
        color: context.colorScheme.background,
        child: FlexibleDetailBar(
          content: const _ExpandedHeader(),
          builder: (context, t) {
            if (t < 0.5) {
              return const SizedBox();
            }
            return PlaylistCollapsedTitle(
              text: context.strings.latestPlayHistory,
            );
          },
          background: const SizedBox(),
        ),
      ),
      bottom: const TrackTableHeader(),
    );
  }
}

class _ExpandedHeader extends ConsumerWidget {
  const _ExpandedHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(playHistoryProvider).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.strings.latestPlayHistory,
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(width: 20),
              Text(
                context.strings.musicCountFormat(count),
                style: context.textTheme.bodySmall,
              ),
              const Spacer(),
              if (count > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextButton.icon(
                    icon: const Icon(FluentIcons.delete_20_regular),
                    label: Text(context.strings.clearPlayHistory),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    onPressed: () =>
                        ref.read(playHistoryProvider.notifier).clear(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
