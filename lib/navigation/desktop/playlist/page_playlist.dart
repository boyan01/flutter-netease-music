import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../extension.dart';
import '../../../providers/key_value/account_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/playlist_detail_provider.dart';
import '../../../repository.dart';
import '../../../utils/hooks.dart';
import '../../../utils/track_list_filter.dart';
import '../../common/image.dart';
import '../../common/material/flexible_app_bar.dart';
import '../../common/navigation_target.dart';
import '../../common/playlist/track_list_container.dart';
import '../widgets/playlist_collapsed_title.dart';
import '../widgets/track_tile_normal.dart';

class PagePlaylist extends HookConsumerWidget {
  const PagePlaylist({
    super.key,
    required this.playlistId,
  });

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
    super.key,
    required this.playlist,
  });

  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterStreamController = useStreamController<String>();
    final filterStream = useMemoized(
      () => filterStreamController.stream,
      [filterStreamController],
    );
    final absorberHandle = useMemoized(SliverOverlapAbsorberHandle.new);
    return TrackTableContainer(
      child: TrackTileContainer.playlist(
        playlist: playlist,
        userId: ref.read(userIdProvider),
        child: CustomScrollView(
          slivers: [
            SliverOverlapAbsorber(handle: absorberHandle),
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
    super.key,
    required this.playlist,
    required this.playlistFilterController,
  });

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
    super.key,
    required this.playlist,
    required this.playlistFilterController,
  });

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
              child: AppImage(
                url: playlist.coverUrl,
                width: 160,
                height: 160,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                playlist.name,
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    playlist.creator.nickname,
                    style: context.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.strings.createdDate(
                      DateFormat.yMMMMd().format(playlist.createTime),
                    ),
                    style: context.textTheme.bodySmall,
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
                    style: context.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.strings.playlistPlayCount(playlist.playCount),
                    style: context.textTheme.bodySmall,
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
  const _HeaderActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            final controller = TrackTileContainer.controller(context);
            final state = ref.read(playerStateProvider);
            if (state.playingList.id == controller.playlistId &&
                state.isPlaying) {
              ref
                  .read(navigatorProvider.notifier)
                  .navigate(NavigationTargetPlaying());
            } else {
              controller.play(null);
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
              children: [
                const Icon(Icons.playlist_add_rounded, size: 16),
                const SizedBox(width: 4),
                Text(
                  context.strings.subscribe,
                  style: context.textTheme.bodyMedium,
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
              children: [
                const Icon(Icons.share, size: 16),
                const SizedBox(width: 4),
                Text(
                  context.strings.share,
                  style: context.textTheme.bodyMedium,
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
    super.key,
    required this.playlist,
    required this.filter,
  });

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
    super.key,
    required this.playlistFilterController,
  });

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
          color: Theme.of(context).textTheme.bodySmall!.color,
        ),
        onChanged: playlistFilterController.add,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(
              color: context.colorScheme.textPrimary.withOpacity(0.5),
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
      ),
    );
  }
}
