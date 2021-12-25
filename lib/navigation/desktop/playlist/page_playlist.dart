import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/providers/playlist_detail_provider.dart';
import 'package:quiet/providers/settings_provider.dart';
import 'package:quiet/repository.dart';
import 'package:quiet/utils/track_list_filter.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../component/hooks.dart';
import '../../../component/utils/scroll_controller.dart';
import '../../../providers/navigator_provider.dart';
import '../../common/navigation_target.dart';
import '../../common/playlist/music_list.dart';
import '../widgets/playlist_collapsed_title.dart';
import '../widgets/track_tile_normal.dart';

class PagePlaylist extends HookConsumerWidget {
  const PagePlaylist({
    Key? key,
    required this.playlistId,
  }) : super(key: key);

  final int playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistDetail = ref.watch(playlistDetailProvider(playlistId));
    return Material(
      color: context.colorScheme.background,
      child: playlistDetail.when(
        data: (playlist) => _PlaylistDetailBody(playlist: playlist),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(
          child: Text(context.formattedError(e)),
        ),
      ),
    );
  }
}

class _PlaylistDetailBody extends HookConsumerWidget {
  const _PlaylistDetailBody({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterStreamController = useStreamController<String>();
    final filterStream = useMemoized(
        () => filterStreamController.stream, [filterStreamController]);
    return TrackTableContainer(
      child: TrackTileContainer.playlist(
        playlist: playlist,
        player: ref.read(playerProvider),
        skipAccompaniment: ref.watch(
          settingStateProvider.select((value) => value.skipAccompaniment),
        ),
        child: CustomScrollView(
          controller: AppScrollController(),
          slivers: [
            _PlaylistSliverBar(
              playlist: playlist,
              playlistFilterController: filterStreamController,
            ),
            _PlaylistListView(playlist: playlist, filter: filterStream),
          ],
        ),
      ),
    );
  }
}

class _PlaylistSliverBar extends StatelessWidget {
  const _PlaylistSliverBar({
    Key? key,
    required this.playlist,
    required this.playlistFilterController,
  }) : super(key: key);

  final PlaylistDetail playlist;

  final StreamController<String> playlistFilterController;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: 260,
      collapsedHeight: 56,
      flexibleSpace: Material(
        color: context.colorScheme.background,
        child: FlexibleDetailBar(
          content: _PlaylistDetailHeader(
            playlist: playlist,
            playlistFilterController: playlistFilterController,
          ),
          background: const SizedBox(),
          builder: (context, t) {
            if (t <= 0.5) {
              return const SizedBox();
            }
            return PlaylistCollapsedTitle(text: playlist.name);
          },
        ),
      ),
      bottom: const TrackTableHeader(),
    );
  }
}

class _PlaylistDetailHeader extends StatelessWidget {
  const _PlaylistDetailHeader({
    Key? key,
    required this.playlist,
    required this.playlistFilterController,
  }) : super(key: key);

  final PlaylistDetail playlist;

  final StreamController<String> playlistFilterController;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image(
                image: CachedImage(playlist.coverUrl),
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 20),
              Text(
                playlist.name,
                style: context.textTheme.headline6,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(playlist.creator.nickname,
                      style: context.textTheme.caption),
                  const SizedBox(width: 8),
                  Text(
                    context.strings.createdDate(
                      DateFormat.yMMMMd().format(playlist.createTime),
                    ),
                    style: context.textTheme.caption,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const _HeaderActionButtons(),
              const Spacer(),
              Text(
                playlist.description,
                style: context.textTheme.bodyMedium,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    context.strings.playlistTrackCount(playlist.trackCount),
                    style: context.textTheme.caption,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.strings.playlistPlayCount(playlist.playCount),
                    style: context.textTheme.caption,
                  ),
                  const Spacer(),
                  _PlaylistSearchBox(
                    playlistFilterController: playlistFilterController,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderActionButtons extends ConsumerWidget {
  const _HeaderActionButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            final id = TrackTileContainer.getPlaylistId(context);
            final state = ref.read(playerStateProvider);
            if (state.playingList.id == id && state.isPlaying) {
              ref
                  .read(navigatorProvider.notifier)
                  .navigate(NavigationTargetPlaying());
            } else {
              TrackTileContainer.playTrack(context, null);
            }
          },
          label: Text(context.strings.playAll),
          icon: const Icon(Icons.play_arrow_rounded, size: 16),
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(const Size(100, 32)),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
            toast(context.strings.todo);
          },
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.playlist_add_rounded, size: 16),
                const SizedBox(width: 4),
                Text(
                  context.strings.subscribe,
                  style: context.textTheme.bodyText2,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
            toast(context.strings.todo);
          },
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.share, size: 16),
                const SizedBox(width: 4),
                Text(
                  context.strings.share,
                  style: context.textTheme.bodyText2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaylistListView extends HookWidget {
  const _PlaylistListView({
    Key? key,
    required this.playlist,
    required this.filter,
  }) : super(key: key);
  final PlaylistDetail playlist;
  final Stream<String> filter;

  @override
  Widget build(BuildContext context) {
    final keyWord = useMemoizedStream(
      () => filter.debounce(const Duration(milliseconds: 300)),
      keys: [filter],
    ).data;
    final trackList = useFilteredTracks(playlist.tracks, keyWord ?? '');
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => TrackTile(
          index: index + 1,
          track: trackList[index],
        ),
        childCount: trackList.length,
      ),
    );
  }
}

class _PlaylistSearchBox extends StatelessWidget {
  const _PlaylistSearchBox({
    Key? key,
    required this.playlistFilterController,
  }) : super(key: key);

  final StreamController<String> playlistFilterController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 24,
      child: TextField(
        cursorHeight: 10,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.caption!.color,
        ),
        onChanged: playlistFilterController.add,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(
              color: context.colorScheme.onBackground.withOpacity(0.5),
              width: 1,
            ),
          ),
          hintText: context.strings.searchPlaylistSongs,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 8, right: 4, top: 4, bottom: 4),
            child: Icon(Icons.search, size: 16),
          ),
          prefixIconConstraints:
              const BoxConstraints.tightFor(width: 28, height: 24),
        ),
        maxLines: 1,
      ),
    );
  }
}
