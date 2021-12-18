import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/material.dart';
import 'package:quiet/pages/artists/page_artist_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository.dart';

import '../../navigation/common/playlist/music_list.dart';
import 'page_playlist_detail_selection.dart';

class AlbumDetailPage extends ConsumerStatefulWidget {
  const AlbumDetailPage({Key? key, required this.albumId, this.album})
      : super(key: key);

  final int albumId;
  final Map? album;

  @override
  _AlbumDetailPageState createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends ConsumerState<AlbumDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Loader<AlbumDetail>(
          loadTask: () => neteaseRepository!.albumDetail(widget.albumId),
          builder: (context, result) {
            return _AlbumBody(
              album: result.album,
              musicList: result.tracks,
            );
          }),
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
        child: BoxWithBottomPlayerController(CustomScrollView(slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: kHeaderHeight,
            backgroundColor: Colors.transparent,
            pinned: true,
            elevation: 0,
            flexibleSpace: _AlbumDetailHeader(album: album),
            bottom: MusicListHeader(musicList.length),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => MusicTile(musicList[index]),
                  childCount: musicList.length)),
        ])));
  }
}

/// a detail header describe album information
class _AlbumDetailHeader extends ConsumerWidget {
  const _AlbumDetailHeader({Key? key, required this.album, this.musicList})
      : super(key: key);

  final Album album;
  final List<Music>? musicList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlexibleDetailBar(
        background: PlayListHeaderBackground(imageUrl: album.picUrl),
        content: _buildContent(context, ref),
        builder: (context, t) => AppBar(
              automaticallyImplyLeading: false,
              title: Text(t > 0.5 ? album.name : '专辑'),
              titleSpacing: 16,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: <Widget>[
                LandscapeWidgetSwitcher(
                  landscape: (context) => const CloseButton(),
                )
              ],
            ));
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    return DetailHeader(
        shareCount: album.shareCount,
        commentCount: album.commentCount,
        onCommentTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return CommentPage(
              threadId: CommentThreadId(album.id, CommentType.album),
              payload: null,
            );
          }));
        },
        onSelectionTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return PlaylistSelectionPage(list: musicList);
          }));
        },
        onShareTap: () {
          final content = context.strings.albumShareContent(
              album.artist.name,
              album.name,
              album.id.toString(),
              ref.read(userProvider)!.userId.toString());
          Clipboard.setData(ClipboardData(text: content));
          toast(context.strings.shareContentCopied);
        },
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          height: 150,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 32),
              QuietHero(
                tag: "album_image_${album.id}",
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                    child: Image(
                      fit: BoxFit.cover,
                      image: CachedImage(album.picUrl),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: DefaultTextStyle(
                style: Theme.of(context).primaryTextTheme.bodyText2!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 8),
                    Text(album.name, style: const TextStyle(fontSize: 17)),
                    const SizedBox(height: 10),
                    InkWell(
                        onTap: () {
                          launchArtistDetailPage(context, [album.artist]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: Text("歌手: ${album.artist.name}"),
                        )),
                    const SizedBox(height: 4),
                    Text("发行时间：${getFormattedTime(album.publishTime)}")
                  ],
                ),
              ))
            ],
          ),
        ));
  }
}
