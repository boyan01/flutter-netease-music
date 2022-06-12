import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../component/utils/scroll_controller.dart';
import '../../extension.dart';
import '../../media/tracks/track_list.dart';
import '../../providers/navigator_provider.dart';
import '../../providers/personalized_playlist_provider.dart';
import '../../providers/play_records_provider.dart';
import '../../providers/player_provider.dart';
import '../common/navigation_target.dart';
import '../common/recommended_playlist_tile.dart';
import 'widgets/track_tile_short.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Expanded(child: Center(child: Text('Discover'))),
                SizedBox(
                  height: 240,
                  child: _Playlists(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 400, child: _PlayRecord()),
        ],
      ),
    );
  }
}

class _Playlists extends ConsumerWidget {
  const _Playlists({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(homePlaylistProvider);
    Widget builder(Widget child) {
      return Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 20),
        child: _Box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(title: context.strings.recommendPlayLists),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    return playlists.when(
      data: (playlists) => builder(
        ListView.builder(
          itemCount: playlists.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return RecommendedPlaylistTile(
              playlist: playlist,
              width: 120,
              onTap: () => ref
                  .read(navigatorProvider.notifier)
                  .navigate(NavigationTarget.playlist(playlistId: playlist.id)),
            );
          },
        ),
      ),
      loading: () => builder(const Center(child: CircularProgressIndicator())),
      error: (error, stacktrace) => builder(
        Center(child: Text(context.formattedError(error))),
      ),
    );
  }
}

class _PlayRecord extends ConsumerWidget {
  const _PlayRecord({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(allPlayRecordsProvider);
    Widget builder(Widget child) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: _Box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(title: context.strings.latestPlayHistory),
              const SizedBox(height: 20),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    return records.when(
      data: (data) => builder(
        ListView.builder(
          itemCount: data.length,
          controller: AppScrollController(),
          itemBuilder: (context, index) {
            final record = data[index];
            return TrackShortTile(
              index: index,
              track: record.song,
              onTap: () {
                final trackList = TrackList.playlist(
                  id: 'play_records',
                  tracks: data.map((e) => e.song).toList(),
                );
                ref.read(playerProvider)
                  ..setTrackList(trackList)
                  ..playFromMediaId(record.song.id);
              },
            );
          },
        ),
      ),
      error: (error, stacktrace) => builder(
        Center(child: Text(context.formattedError(error))),
      ),
      loading: () => builder(const Center(child: CircularProgressIndicator())),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.subtitle1.bold,
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.colorScheme.onBackground.withOpacity(0.05),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
