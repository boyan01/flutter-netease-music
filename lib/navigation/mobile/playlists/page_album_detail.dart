import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/providers/album_detail_provider.dart';
import 'package:quiet/repository.dart';

import '../../common/playlist/music_list.dart';
import 'page_playlist_detail.dart';
import 'playlist_flexible_app_bar.dart';

class AlbumDetailPage extends ConsumerWidget {
  const AlbumDetailPage({Key? key, required this.albumId, this.album})
      : super(key: key);

  final int albumId;
  final Map? album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(albumDetailProvider(albumId));
    return snapshot.when(
      data: (data) => Scaffold(
        body: _AlbumBody(
          album: data.album,
          musicList: data.tracks,
        ),
      ),
      error: (error, stacktrace) => Scaffold(
        appBar: AppBar(title: Text(context.strings.album)),
        body: Center(
          child: Text(context.formattedError(error)),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(context.strings.album),
        ),
        body: const Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class _AlbumBody extends StatelessWidget {
  const _AlbumBody({Key? key, required this.album, required this.musicList})
      : super(key: key);

  final Album album;
  final List<Music> musicList;

  @override
  Widget build(BuildContext context) {
    return MusicTileConfiguration(
        token: 'album_${album.id}',
        musics: musicList,
        onMusicTap: MusicTileConfiguration.defaultOnTap,
        leadingBuilder: MusicTileConfiguration.indexedLeadingBuilder,
        trailingBuilder: MusicTileConfiguration.defaultTrailingBuilder,
        child: CustomScrollView(slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: kHeaderHeight,
            backgroundColor: Colors.transparent,
            pinned: true,
            elevation: 0,
            flexibleSpace: AlbumFlexibleAppBar(album: album),
            bottom: MusicListHeader(musicList.length),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => MusicTile(musicList[index]),
                  childCount: musicList.length)),
        ]));
  }
}
