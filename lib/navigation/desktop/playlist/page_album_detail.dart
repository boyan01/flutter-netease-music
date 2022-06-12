import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../component/utils/scroll_controller.dart';
import '../../../extension.dart';
import '../../../material/flexible_app_bar.dart';
import '../../../providers/album_detail_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../common/navigation_target.dart';
import '../../common/playlist/music_list.dart';
import '../widgets/highlight_clickable_text.dart';
import '../widgets/playlist_collapsed_title.dart';
import '../widgets/track_tile_normal.dart';

class PageAlbumDetail extends ConsumerWidget {
  const PageAlbumDetail({
    super.key,
    required this.albumId,
  });

  final int albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(albumDetailProvider(albumId).logErrorOnDebug());
    return Material(
      color: context.colorScheme.background,
      child: snapshot.when(
        data: (data) => _AlbumDetailBody(
          album: data.album,
          tracks: data.tracks,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.formattedError(e))),
      ),
    );
  }
}

class _AlbumDetailBody extends ConsumerWidget {
  const _AlbumDetailBody({
    super.key,
    required this.album,
    required this.tracks,
  });

  final Album album;
  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackTableContainer(
      child: TrackTileContainer.album(
        album: album,
        tracks: tracks,
        player: ref.read(playerProvider),
        child: CustomScrollView(
          controller: AppScrollController(),
          slivers: [
            _AlbumSliverBar(album: album),
            _AlbumListView(album: album, tracks: tracks),
          ],
        ),
      ),
    );
  }
}

class _AlbumSliverBar extends StatelessWidget {
  const _AlbumSliverBar({super.key, required this.album});

  final Album album;

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
          content: _AlbumDetailHeader(album: album),
          background: const SizedBox(),
          builder: (context, t) {
            if (t <= 0.5) {
              return const SizedBox();
            }
            return PlaylistCollapsedTitle(text: album.name);
          },
        ),
      ),
      bottom: const TrackTableHeader(),
    );
  }
}

class _AlbumDetailHeader extends StatelessWidget {
  const _AlbumDetailHeader({super.key, required this.album});

  final Album album;

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
                image: CachedImage(album.picUrl),
                width: 160,
                height: 160,
                fit: BoxFit.cover,
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
                album.name,
                style: context.textTheme.headline6,
              ),
              const SizedBox(height: 10),
              const _HeaderActionButtons(),
              const Spacer(),
              HighlightClickableText(
                text: album.artist.name,
                style: context.textTheme.caption,
                highlightStyle: context.textTheme.caption!.copyWith(
                  color: context.textTheme.bodyMedium!.color,
                ),
                onTap: () {
                  toast(context.strings.todo);
                },
              ),
              Text(
                DateFormat.yMMMMd().format(album.publishTime),
                style: context.textTheme.bodyMedium,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
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

class _AlbumListView extends StatelessWidget {
  const _AlbumListView({
    super.key,
    required this.album,
    required this.tracks,
  });
  final Album album;
  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => TrackTile(
          index: index + 1,
          track: tracks[index],
        ),
        childCount: tracks.length,
      ),
    );
  }
}
