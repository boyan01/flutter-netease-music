import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/providers/playlist_detail_provider.dart';
import 'package:quiet/repository.dart';

import '../../../component/utils/scroll_controller.dart';
import '../../common/playlist/music_list.dart';
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

class _PlaylistDetailBody extends StatelessWidget {
  const _PlaylistDetailBody({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context) {
    return TrackTableContainer(
      child: CustomScrollView(
        controller: AppScrollController(),
        slivers: [
          _PlaylistSliverBar(playlist: playlist),
          _PlaylistListView(playlist: playlist),
        ],
      ),
    );
  }
}

class _PlaylistSliverBar extends StatelessWidget {
  const _PlaylistSliverBar({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: 200,
      collapsedHeight: 56,
      flexibleSpace: FlexibleDetailBar(
        content: _PlaylistDetailHeader(playlist: playlist),
        background: Container(color: context.colorScheme.background),
        builder: (context, t) {
          return AppBar(
            title: t > 0.5 ? Text(playlist.name) : null,
            automaticallyImplyLeading: false,
            titleTextStyle: context.textTheme.headline6,
            elevation: 0,
            titleSpacing: 20,
            centerTitle: false,
            backgroundColor: Colors.transparent,
          );
        },
      ),
      bottom: const TrackTableHeader(),
    );
  }
}

class _PlaylistDetailHeader extends StatelessWidget {
  const _PlaylistDetailHeader({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  final PlaylistDetail playlist;

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
              Text(
                playlist.description,
                style: context.textTheme.bodyMedium,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              const Spacer(),
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

class _PlaylistListView extends ConsumerWidget {
  const _PlaylistListView({
    Key? key,
    required this.playlist,
  }) : super(key: key);
  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackTileContainer.playlist(
      playlist: playlist,
      player: ref.read(playerProvider),
      child: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => TrackTile(
            index: index + 1,
            track: playlist.tracks[index],
          ),
          childCount: playlist.tracks.length,
        ),
      ),
    );
  }
}
