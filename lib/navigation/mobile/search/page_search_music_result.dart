import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/search_provider.dart';
import '../../../repository/data/track.dart';
import '../../common/navigation_target.dart';
import '../../common/playlist/track_list_container.dart';
import '../widgets/track_tile.dart';
import 'search_bar.dart';

class PageMusicSearchResult extends ConsumerWidget {
  const PageMusicSearchResult({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResult = ref.watch(searchMusicProvider(query));
    return Scaffold(
      appBar: SearchBar(
        enable: false,
        placeholder: query,
        onSearchBarTap: () {
          ref
              .read(navigatorProvider.notifier)
              .navigate(NavigationTargetSearch(initial: query));
        },
      ),
      body: searchResult.value.when(
        data: (data) => _SearchResultScaffold(
          query: query,
          body: _TrackList(tracks: data),
        ),
        error: (error, stacktrace) => _SearchResultScaffold(
          query: query,
          body: Center(
            child: Text(context.formattedError(error)),
          ),
        ),
        loading: () => _SearchResultScaffold(
          query: query,
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class _SearchResultScaffold extends HookConsumerWidget {
  const _SearchResultScaffold({
    super.key,
    required this.query,
    required this.body,
  });

  final String query;
  final Widget body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return body;
  }
}

class _TrackList extends ConsumerWidget {
  const _TrackList({super.key, required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackTileContainer.simpleList(
      tracks: tracks,
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => TrackTile(
                track: tracks[index],
                index: index + 1,
              ),
              childCount: tracks.length,
            ),
          )
        ],
      ),
    );
  }
}
