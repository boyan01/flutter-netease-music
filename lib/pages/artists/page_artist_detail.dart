import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiet/pages/artists/artist_header.dart';
import 'package:quiet/pages/playlist/dialog_selector.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/pages/playlist/page_playlist_detail_selection.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import 'artist.model.dart' as model;

export 'artists_selector.dart';

///歌手详情页
class ArtistDetailPage extends StatelessWidget {
  ///歌手ID
  final int artistId;

  const ArtistDetailPage({Key key, @required this.artistId})
      : assert(artistId != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Loader<Map>(
        loadTask: () => neteaseRepository.artistDetail(artistId),
        loadingBuilder: (context) {
          return Scaffold(
            appBar: AppBar(title: Text("歌手")),
            body: Loader.buildSimpleLoadingWidget(context),
          );
        },
        errorBuilder: (context, result) {
          return Scaffold(
            appBar: AppBar(title: Text("歌手")),
            body: Loader.buildSimpleFailedWidget(context, result),
          );
        },
        builder: (context, result) {
          final artist = model.Artist.fromJson(result["artist"]);
          List<Music> musicList = mapJsonListToMusicList(result["hotSongs"], artistKey: "ar", albumKey: "al");

          return Scaffold(
              body: BoxWithBottomPlayerController(
            DefaultTabController(
              length: 4,
              child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                        sliver: ArtistHeader(artist: artist),
                      ),
                    ];
                  },
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: kToolbarHeight + kTextTabBarHeight),
                      child: TabBarView(
                        children: [
                          _PageHotSongs(musicList: musicList, artistId: artistId),
                          _PageAlbums(artistId: artistId),
                          _PageMVs(artistId: artistId, mvCount: artist.mvSize),
                          _PageArtistIntroduction(artistId: artistId, artistName: artist.name),
                        ],
                      ),
                    ),
                  )),
            ),
          ));
        });
  }
}

///热门单曲
class _PageHotSongs extends StatefulWidget {
  const _PageHotSongs({Key key, @required this.musicList, @required this.artistId})
      : assert(musicList != null),
        super(key: key);

  final List<Music> musicList;

  final int artistId;

  @override
  _PageHotSongsState createState() {
    return new _PageHotSongsState();
  }
}

class _PageHotSongsState extends State<_PageHotSongs> with AutomaticKeepAliveClientMixin {
  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: () {
        PlaylistSelectorDialog.addSongs(context, widget.musicList.map((m) => m.id).toList());
      },
      child: Container(
        height: 48,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  SizedBox(width: 8),
                  Icon(Icons.add_box),
                  SizedBox(width: 8),
                  Expanded(child: Text("收藏热门${widget.musicList.length}单曲")),
                  FlatButton(
                      child: Text("多选"),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return PlaylistSelectionPage(list: widget.musicList);
                        }));
                      })
                ],
              ),
            ),
            Divider(height: 0)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.musicList.isEmpty) {
      return Container(
        child: Center(child: Text("该歌手无热门曲目")),
      );
    }
    return MusicTileConfiguration(
      musics: widget.musicList,
      token: 'artist_${widget.artistId}_hot',
      leadingBuilder: MusicTileConfiguration.indexedLeadingBuilder,
      trailingBuilder: MusicTileConfiguration.defaultTrailingBuilder,
      onMusicTap: MusicTileConfiguration.defaultOnTap,
      child: ListView.builder(
          itemCount: widget.musicList.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildHeader(context);
            } else {
              return MusicTile(widget.musicList[index - 1]);
            }
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _PageAlbums extends StatefulWidget {
  final int artistId;

  const _PageAlbums({Key key, @required this.artistId}) : super(key: key);

  @override
  _PageAlbumsState createState() {
    return new _PageAlbumsState();
  }
}

class _PageAlbumsState extends State<_PageAlbums> with AutomaticKeepAliveClientMixin {
  Future<Result<List<Map>>> _delegate(offset) async {
    final result = await neteaseRepository.artistAlbums(widget.artistId, offset: offset);
    return ValueResult((result.asValue.value["hotAlbums"] as List).cast());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AutoLoadMoreList<Map>(
      loadMore: _delegate,
      builder: (context, album) {
        return AlbumTile(album: album);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _PageMVs extends StatefulWidget {
  final int artistId;

  final int mvCount;

  const _PageMVs({Key key, @required this.artistId, @required this.mvCount}) : super(key: key);

  @override
  _PageMVsState createState() {
    return new _PageMVsState();
  }
}

class _PageMVsState extends State<_PageMVs> with AutomaticKeepAliveClientMixin {
  Future<Result<List<Map>>> _loadMv(int offset) async {
    final result = await neteaseRepository.artistMvs(widget.artistId, offset: offset);
    return ValueResult((result.asValue.value["mvs"] as List).cast());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AutoLoadMoreList<Map>(
        loadMore: _loadMv,
        builder: (context, mv) {
          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/mv', arguments: mv['id']);
            },
            child: Container(
              height: 72,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 8),
                  Container(
                    height: 72,
                    width: 72 * 1.6,
                    padding: EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Image(
                        image: CachedImage(mv["imgurl16v9"]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Spacer(),
                      Text(mv["name"], maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4),
                      Text(mv["publishTime"], style: Theme.of(context).textTheme.caption),
                      Spacer(),
                      Divider(height: 0)
                    ],
                  ))
                ],
              ),
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class _PageArtistIntroduction extends StatefulWidget {
  final int artistId;

  final String artistName;

  const _PageArtistIntroduction({Key key, @required this.artistId, @required this.artistName}) : super(key: key);

  @override
  _PageArtistIntroductionState createState() {
    return new _PageArtistIntroductionState();
  }
}

class _PageArtistIntroductionState extends State<_PageArtistIntroduction> with AutomaticKeepAliveClientMixin {
  List<Widget> _buildIntroduction(BuildContext context, Map result) {
    Widget title = Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child:
            Text(("${widget.artistName}简介"), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, shadows: [])));

    Widget briefDesc = Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        result["briefDesc"],
        style: TextStyle(color: Theme.of(context).textTheme.caption.color),
      ),
    );
    Widget button = InkWell(
      onTap: () {
        notImplemented(context);
      },
      child: Container(
        height: 36,
        child: Center(
          child: Text("完整歌手介绍"),
        ),
      ),
    );
    return [title, briefDesc, button];
  }

  List<Widget> _buildTopic(BuildContext context, Map result) {
    final List<Map> data = (result["topicData"] as List)?.cast();
    if (data == null || data.length == 0) {
      return [];
    }
    Widget title = Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(("相关专题文章"), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, shadows: [])));
    List<Widget> list = data.map<Widget>((topic) {
      String subtitle = "by ${topic["creator"]["nickname"]} 阅读 ${topic["readCount"]}";
      return InkWell(
        onTap: () {
          debugPrint("on tap : ${topic["url"]}");
        },
        child: Container(
          height: 72,
          child: Row(
            children: <Widget>[
              SizedBox(width: 8),
              Container(
                height: 72,
                width: 72 * 1.6,
                padding: EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Image(
                    image: CachedImage(topic["rectanglePicUrl"]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(),
                  Text(topic["mainTitle"], maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.caption),
                  Spacer(),
                  Divider(height: 0)
                ],
              ))
            ],
          ),
        ),
      );
    }).toList();
    list.insert(0, title);

    if (result["count"] > data.length) {
      list.add(InkWell(
        onTap: () {
          notImplemented(context);
        },
        child: Container(
          height: 56,
          child: Center(
            child: Text("全部专栏文章"),
          ),
        ),
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Loader<Map>(
      loadTask: () => neteaseRepository.artistDesc(widget.artistId),
      builder: (context, result) {
        final widgets = <Widget>[];
        widgets.addAll(_buildIntroduction(context, result));
        widgets.addAll(_buildTopic(context, result));
        return ListView(
          children: widgets,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
