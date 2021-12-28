import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/component/utils/scroll_controller.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/providers/daily_playlist_provider.dart';
import 'package:quiet/repository.dart';

import '../../../providers/player_provider.dart';
import '../widgets/playlist_collapsed_title.dart';
import '../widgets/track_tile_normal.dart';

class PageDailyPlaylist extends ConsumerWidget {
  const PageDailyPlaylist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(dailyPlaylistProvider);
    return Material(
      color: context.colorScheme.background,
      child: snapshot.when(
        data: (data) => _DailyPlaylistBody(
          date: data.date,
          tracks: data.tracks,
        ),
        error: (error, stackTrace) => Center(
          child: Text(context.formattedError(error)),
        ),
        loading: () => const Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class _DailyPlaylistBody extends ConsumerWidget {
  const _DailyPlaylistBody({
    Key? key,
    required this.tracks,
    required this.date,
  }) : super(key: key);

  final List<Track> tracks;

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackTableContainer(
      child: TrackTileContainer.daily(
        dateTime: date,
        tracks: tracks,
        player: ref.read(playerProvider),
        child: CustomScrollView(
          controller: AppScrollController(),
          slivers: [
            _DailyHeader(date: date),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => TrackTile(
                  index: index + 1,
                  track: tracks[index],
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

class _DailyHeader extends StatelessWidget {
  const _DailyHeader({Key? key, required this.date}) : super(key: key);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: 200,
      collapsedHeight: 56,
      flexibleSpace: Material(
        color: context.colorScheme.background,
        child: FlexibleDetailBar(
          background: const SizedBox(),
          content: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 20),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: date.day.toString().padLeft(2, '0'),
                          style: const TextStyle(fontSize: 60),
                        ),
                        const TextSpan(
                          text: ' / ',
                          style: TextStyle(fontSize: 14),
                        ),
                        TextSpan(
                          text: date.month.toString().padLeft(2, '0'),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ]),
                      style: context.textTheme.headline5.bold?.copyWith(
                        color: context.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.strings.dailyRecommend,
                            style: context.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.strings.dailyRecommendDescription,
                            style: context.textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          builder: (context, t) {
            if (t <= 0.5) {
              return const SizedBox();
            }
            return PlaylistCollapsedTitle(text: context.strings.dailyRecommend);
          },
        ),
      ),
      bottom: const TrackTableHeader(),
    );
  }
}
