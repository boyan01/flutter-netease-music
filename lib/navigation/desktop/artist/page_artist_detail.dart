import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../../extension.dart';
import '../../common/navigation_target.dart';
import '../../common/playlist/music_list.dart';
import '../widgets/track_tile_normal.dart';
import '../../../providers/navigator_provider.dart';
import '../../../repository.dart';

import '../../../component/utils/scroll_controller.dart';
import '../../../providers/artist_provider.dart';
import '../../../providers/player_provider.dart';
import '../../common/buttons.dart';
import '../widgets/highlight_clickable_text.dart';

class PageArtistDetail extends ConsumerWidget {
  const PageArtistDetail({Key? key, required this.artistId}) : super(key: key);

  final int artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(artistProvider(artistId).logErrorOnDebug());
    return Material(
      color: context.colorScheme.background,
      child: snapshot.when(
        data: (data) => _ArtistDetailScaffold(artist: data),
        error: (e, _) => Center(child: Text(context.formattedError(e))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ArtistDetailScaffold extends HookWidget {
  const _ArtistDetailScaffold({
    Key? key,
    required this.artist,
  }) : super(key: key);

  final ArtistDetail artist;

  @override
  Widget build(BuildContext context) {
    final controller = useAppScrollController();
    return ListView(
      controller: controller,
      children: [
        _ArtistDetailHeader(artist: artist.artist),
        const SizedBox(height: 32),
        _TopSongs(
          tracks: artist.hotSongs,
          artist: artist.artist,
        ),
        const SizedBox(height: 20),
        _ArtistAlbums(artistId: artist.artist.id),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ArtistDetailHeader extends StatelessWidget {
  const _ArtistDetailHeader({
    Key? key,
    required this.artist,
  }) : super(key: key);

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: CachedImage(artist.picUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    artist.name,
                    style: context.textTheme.headline6,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      PlaylistIconTextButton(
                        icon: const Icon(Icons.add),
                        text: Text(context.strings.subscribe),
                        onTap: () {
                          // TODO add subscribe
                          toast(context.strings.todo);
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                          context.strings.playlistTrackCount(artist.musicSize)),
                      const SizedBox(width: 8),
                      Text(context.strings.artistAlbumCount(artist.albumSize)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopSongs extends ConsumerWidget {
  const _TopSongs({
    Key? key,
    required this.tracks,
    required this.artist,
  }) : super(key: key);

  final List<Track> tracks;

  final Artist artist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackTileContainer.trackList(
      tracks: tracks,
      player: ref.read(playerProvider),
      id: 'artist-${artist.id}-top-songs',
      child: _CoverTrackListWidget(
        canCollapse: true,
        title: Text(context.strings.topSongs),
        cover: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: context.colorScheme.primary,
          ),
          child: Center(
            child: Text.rich(
              const TextSpan(children: [
                TextSpan(text: 'TOP\n'),
                TextSpan(text: '50', style: TextStyle(fontSize: 50)),
              ]),
              style: context.primaryTextTheme.headlineLarge.bold,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        onAddAllTap: () {
          // TODO add all
          toast(context.strings.todo);
        },
        tracks: tracks,
      ),
    );
  }
}

class _ArtistAlbums extends ConsumerWidget {
  const _ArtistAlbums({
    Key? key,
    required this.artistId,
  }) : super(key: key);

  final int artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = ref.watch(artistAlbumsProvider(artistId).logErrorOnDebug());
    return artist.when(
      data: (data) {
        if (data.isEmpty) {
          return const SizedBox();
        }
        return Column(
          children: [
            for (final album in data)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: _AlbumItemWidget(album: album),
              ),
          ],
        );
      },
      error: (error, _) => const SizedBox(),
      loading: () => const SizedBox(
        height: 56,
        child: Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class _AlbumItemWidget extends ConsumerWidget {
  const _AlbumItemWidget({
    Key? key,
    required this.album,
  }) : super(key: key);

  final AlbumDetail album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackTileContainer.album(
      album: album.album,
      tracks: album.tracks,
      player: ref.read(playerProvider),
      child: _CoverTrackListWidget(
        canCollapse: false,
        title: HighlightClickableText(
          text: album.album.name,
          onTap: () {
            ref
                .read(navigatorProvider.notifier)
                .navigate(NavigationTargetAlbumDetail(album.album.id));
          },
        ),
        cover: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image(
            image: CachedImage(album.album.picUrl),
            fit: BoxFit.cover,
          ),
        ),
        tracks: album.tracks,
        onAddAllTap: () {
          // TODO add all
          toast(context.strings.todo);
        },
      ),
    );
  }
}

class _CoverTrackListWidget extends StatelessWidget {
  const _CoverTrackListWidget({
    Key? key,
    required this.cover,
    required this.tracks,
    required this.onAddAllTap,
    required this.title,
    required this.canCollapse,
  }) : super(key: key);

  final Widget cover;
  final List<Track> tracks;

  final VoidCallback onAddAllTap;

  final Widget title;
  final bool canCollapse;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 20),
        SizedBox.square(
          dimension: 180,
          child: cover,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(width: 20),
                  DefaultTextStyle.merge(
                    style: context.textTheme.headline6,
                    child: title,
                  ),
                  const SizedBox(width: 20),
                  AppIconButton(
                    icon: Icons.play_circle_outline_rounded,
                    tooltip: context.strings.playAll,
                    onPressed: () {
                      TrackTileContainer.playTrack(context, null);
                    },
                  ),
                  AppIconButton(
                    icon: Icons.playlist_add_rounded,
                    tooltip: context.strings.addToPlaylist,
                    onPressed: onAddAllTap,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _TrackList(tracks: tracks, canCollapse: canCollapse),
            ],
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}

const _maxInitialCount = 10;

class _TrackList extends HookWidget {
  const _TrackList({
    Key? key,
    required this.tracks,
    required bool canCollapse,
  })  : canCollapse = canCollapse && tracks.length > _maxInitialCount,
        super(key: key);

  final List<Track> tracks;

  final bool canCollapse;

  @override
  Widget build(BuildContext context) {
    final collapsed = useState(canCollapse);
    return TrackTableContainer(
      child: Column(
        children: [
          for (var i = 0;
              i < (collapsed.value ? _maxInitialCount : tracks.length);
              i += 1)
            TrackTile(track: tracks[i], index: i + 1),
          if (collapsed.value && canCollapse)
            InkWell(
              onTap: () {
                collapsed.value = false;
              },
              child: SizedBox(
                height: 36,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 42),
                    child: Text(
                      context.strings.showAllHotSongs,
                      style: context.textTheme.caption,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
