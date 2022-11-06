import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/search_provider.dart';
import '../../../repository.dart';
import '../../../utils/system/scroll_controller.dart';
import '../../common/playlist/track_list_container.dart';
import '../widgets/track_tile_normal.dart';
import 'page_search.dart';

class PageMusicSearchResult extends ConsumerWidget {
  const PageMusicSearchResult({super.key, required this.query});

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
    super.key,
    required this.tracks,
  });
  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAppScrollController();
    return TrackTileContainer.simpleList(
      tracks: tracks,
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
