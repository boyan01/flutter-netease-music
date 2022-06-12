import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../component/utils/scroll_controller.dart';
import '../../../extension.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/search_provider.dart';
import '../../../repository.dart';
import '../../common/playlist/music_list.dart';
import '../widgets/track_tile_normal.dart';
import 'page_search.dart';

class PageMusicSearchResult extends ConsumerWidget {
  const PageMusicSearchResult({Key? key, required this.query})
      : super(key: key);

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResult = ref.watch(searchMusicProvider(query));
    return searchResult.value.when(
      data: (data) => SearchResultScaffold(
        query: query,
        queryResultDescription: context.strings.searchMusicResultCount(
          searchResult.totalItemCount,
        ),
        body: _TrackList(tracks: data),
      ),
      error: (error, stacktrace) => SearchResultScaffold(
        query: query,
        queryResultDescription: '',
        body: Center(
          child: Text(context.formattedError(error)),
        ),
      ),
      loading: () => SearchResultScaffold(
        query: query,
        queryResultDescription: '',
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _TrackList extends HookConsumerWidget {
  const _TrackList({
    Key? key,
    required this.tracks,
  }) : super(key: key);
  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAppScrollController();
    return TrackTileContainer.simpleList(
      tracks: tracks,
      player: ref.read(playerProvider),
      child: TrackTableContainer(
        child: Column(
          children: [
            const TrackTableHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: tracks.length,
                controller: controller,
                itemBuilder: (context, index) => TrackTile(
                  track: tracks[index],
                  index: index + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
