import 'package:flutter/material.dart';
import 'package:quiet/pages/artists/page_artist_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/pages/playlist/page_playlist_detail_selection.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

class AlbumDetailPage extends StatefulWidget {
  final int albumId;
  final Map album;

  const AlbumDetailPage({Key key, @required this.albumId, this.album})
      : assert(albumId != null),
        super(key: key);

  @override
  _AlbumDetailPageState createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Loader<Map>(
          loadTask: () => neteaseRepository.albumDetail(widget.albumId),
          resultVerify: neteaseRepository.responseVerify,
          builder: (context, result) {
            return _AlbumBody(
              album: result["album"],
              musicList: mapJsonListToMusicList(result["songs"],
                      artistKey: "ar", albumKey: "al") ??
                  [],
            );
          }),
    );
  }
}

class _AlbumBody extends StatefulWidget {
  final Map album;
  final List<Music> musicList;

  const _AlbumBody({Key key, @required this.album, @required this.musicList})
      : assert(album != null),
        assert(musicList != null),
        super(key: key);

  @override
  _AlbumBodyState createState() => _AlbumBodyState();
}

class _AlbumBodyState extends State<_AlbumBody> {
  ScrollController scrollController;

  ValueNotifier<double> appBarOpacity = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(() {
      var scrollHeight = scrollController.offset;
      double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
      double areaHeight = (HEIGHT_HEADER - appBarHeight);
      this.appBarOpacity.value = (scrollHeight / areaHeight).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MusicList(
      token: 'album_${widget.album['id']}',
      musics: widget.musicList,
      onMusicTap: MusicList.defaultOnTap,
      leadingBuilder: MusicList.indexedLeadingBuilder,
      trailingBuilder: MusicList.defaultTrailingBuilder,
      child: Stack(
        children: <Widget>[
          BoxWithBottomPlayerController(
            ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: widget.musicList.length + 2,
              itemBuilder: _buildList,
              controller: scrollController,
            ),
          ),
          Column(
            children: <Widget>[
              OpacityTitle(
                defaultName: "专辑",
                name: widget.album["name"],
                appBarOpacity: appBarOpacity,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, int index) {
    if (index == 0) {
      return _AlbumDetailHeader(
          album: widget.album, musicList: widget.musicList);
    }
    if (widget.musicList.isEmpty) {
      return Container(
        child: Text('暂无音乐'),
      );
    }
    if (index == 1) {
      return MusicListHeader(widget.musicList.length);
    }
    return MusicTile(widget.musicList[index - 2]);
  }
}

/// a detail header describe album information
class _AlbumDetailHeader extends StatelessWidget {
  final Map album;
  final List<Music> musicList;

  const _AlbumDetailHeader({Key key, @required this.album, this.musicList})
      : assert(album != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final artist = (album["artists"] as List)
        .cast<Map>()
        .map((m) =>
            Artist(name: m["name"], id: m["id"], imageUrl: m["img1v1Url"]))
        .toList(growable: false);

    return DetailHeader(
        shareCount: album["info"]["shareCount"],
        commentCount: album["info"]["commentCount"],
        onCommentTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return CommentPage(
                threadId: CommentThreadId(album["id"], CommentType.album));
          }));
        },
        onSelectionTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return PlaylistSelectionPage(list: musicList);
          }));
        },
        onShareTap: () => notImplemented(context),
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          height: 150,
          child: Row(
            children: <Widget>[
              SizedBox(width: 32),
              Hero(
                tag: "album_image_${album["id"]}",
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    child: Image(
                        fit: BoxFit.cover,
                        image: NeteaseImage(album["picUrl"])),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                  child: DefaultTextStyle(
                style: Theme.of(context).primaryTextTheme.body1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 8),
                    Text(album["name"], style: TextStyle(fontSize: 17)),
                    SizedBox(height: 10),
                    InkWell(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: Text(
                              "歌手: ${artist.map((a) => a.name).join('/')}"),
                        ),
                        onTap: () {
                          launchArtistDetailPage(context, artist);
                        }),
                    SizedBox(height: 4),
                    Text("发行时间：${getFormattedTime(album["publishTime"])}")
                  ],
                ),
              ))
            ],
          ),
        ));
  }
}
