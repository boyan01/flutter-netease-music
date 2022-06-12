import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../extension.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/playlist_detail_provider.dart';
import '../../../repository.dart';

import '../../../providers/settings_provider.dart';
import '../../common/playlist/music_list.dart';
import '../widgets/track_title.dart';
import 'playlist_flexible_app_bar.dart';

const double kHeaderHeight = 280 + kToolbarHeight;

/// page display a Playlist
///
/// Playlist : a list of musics by user collected
class PlaylistDetailPage extends ConsumerWidget {
  const PlaylistDetailPage(
    this.playlistId, {
    Key? key,
  }) : super(key: key);

  final int playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(
      playlistDetailProvider(playlistId).logErrorOnDebug(),
    );
    return Scaffold(
      body: detail.when(
        data: (detail) => CustomScrollView(
          slivers: <Widget>[
            _Appbar(playlist: detail),
            _MusicList(detail),
          ],
        ),
        error: (error, stacktrace) => Center(
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

class _Appbar extends StatelessWidget {
  const _Appbar({Key? key, required this.playlist}) : super(key: key);

  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context) => SliverAppBar(
        elevation: 0,
        pinned: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        expandedHeight: kHeaderHeight,
        bottom: MusicListHeader(playlist.tracks.length),
        flexibleSpace: PlaylistFlexibleAppBar(playlist: playlist),
      );
}

///body display the list of song item and a header of playlist
class _MusicList extends ConsumerWidget {
  const _MusicList(this.playlist);

  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackTileContainer.playlist(
      playlist: playlist,
      player: ref.read(playerProvider),
      skipAccompaniment: ref.watch(
        settingStateProvider.select((value) => value.skipAccompaniment),
      ),
      child: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => TrackTile(
            track: playlist.tracks[index],
            index: index + 1,
          ),
          childCount: playlist.tracks.length,
        ),
      ),
    );
  }
}
