import 'package:flutter/material.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/pages/artists/artist_header.dart';
import 'package:quiet/pages/playlist/dialog_selector.dart';
import 'package:quiet/pages/playlist/page_playlist_detail_selection.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository.dart';

export 'artists_selector.dart';

///歌手详情页
class ArtistDetailPage extends StatelessWidget {
  const ArtistDetailPage({Key? key, required this.artistId}) : super(key: key);

  ///歌手ID
  final int artistId;

  @override
  Widget build(BuildContext context) {
    return Loader<ArtistDetail>(
      loadTask: () => neteaseRepository!.artistDetail(artistId),
      loadingBuilder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text("歌手")),
          body: Loader.buildSimpleLoadingWidget(context),
        );
      },
      errorBuilder: (context, result) {
        return Scaffold(
          appBar: AppBar(title: const Text("歌手")),
          body: Loader.buildSimpleFailedWidget(context, result),
        );
      },
      builder: (context, result) => Scaffold(
        body: BoxWithBottomPlayerController(
          DefaultTabController(
            length: 4,
            child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                        sliver: ArtistHeader(artist: result.artist),
                      ),
                    ],
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: kToolbarHeight + kTextTabBarHeight),
                    child: TabBarView(
                      children: [
                        _PageHotSongs(
                          musicList: result.hotSongs,
                          artistId: artistId,
                        ),
                        _PageAlbums(artistId: artistId),
                        _PageMVs(
                          artistId: artistId,
                          mvCount: result.artist.mvSize,
                        ),
                        _PageArtistIntroduction(
                          artistId: artistId,
                          artistName: result.artist.name,
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}

///热门单曲
class _PageHotSongs extends StatefulWidget {
  const _PageHotSongs(
      {Key? key, required this.musicList, required this.artistId})
      : super(key: key);

  final List<Music> musicList;

  final int artistId;

  @override
  _PageHotSongsState createState() {
    return _PageHotSongsState();
  }
}

class _PageHotSongsState extends State<_PageHotSongs>
    with AutomaticKeepAliveClientMixin {
  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: () {
        PlaylistSelectorDialog.addSongs(
            context, widget.musicList.map((m) => m.id).toList());
      },
      child: SizedBox(
        height: 48,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 8),
                  const Icon(Icons.add_box),
                  const SizedBox(width: 8),
                  Expanded(child: Text("收藏热门${widget.musicList.length}单曲")),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return PlaylistSelectionPage(list: widget.musicList);
                        }),
                      );
                    },
                    child: const Text("多选"),
                  )
                ],
              ),
            ),
            const Divider(height: 0)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.musicList.isEmpty) {
      return const Center(child: Text("该歌手无热门曲目"));
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
  const _PageAlbums({Key? key, required this.artistId}) : super(key: key);
  final int artistId;

  @override
  _PageAlbumsState createState() => _PageAlbumsState();
}

class _PageAlbumsState extends State<_PageAlbums>
    with AutomaticKeepAliveClientMixin {
  Future<Result<List<Map>>> _delegate(offset) async {
    final result =
        await neteaseRepository!.artistAlbums(widget.artistId, offset: offset);
    return ValueResult((result.asValue!.value["hotAlbums"] as List).cast());
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
  const _PageMVs({Key? key, required this.artistId, required this.mvCount})
      : super(key: key);

  final int artistId;

  final int? mvCount;

  @override
  _PageMVsState createState() {
    return _PageMVsState();
  }
}

class _PageMVsState extends State<_PageMVs> with AutomaticKeepAliveClientMixin {
  Future<Result<List<Map>>> _loadMv(int offset) async {
    final result =
        await neteaseRepository!.artistMvs(widget.artistId, offset: offset);
    return ValueResult((result.asValue!.value["mvs"] as List).cast());
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
            child: SizedBox(
              height: 72,
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 8),
                  Container(
                    height: 72,
                    width: 72 * 1.6,
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Image(
                        image: CachedImage(mv["imgurl16v9"]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Spacer(),
                      Text(mv["name"],
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(mv["publishTime"],
                          style: Theme.of(context).textTheme.caption),
                      const Spacer(),
                      const Divider(height: 0)
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
  const _PageArtistIntroduction(
      {Key? key, required this.artistId, required this.artistName})
      : super(key: key);
  final int artistId;

  final String? artistName;

  @override
  _PageArtistIntroductionState createState() {
    return _PageArtistIntroductionState();
  }
}

class _PageArtistIntroductionState extends State<_PageArtistIntroduction>
    with AutomaticKeepAliveClientMixin {
  List<Widget> _buildIntroduction(BuildContext context, Map result) {
    final Widget title = Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text("${widget.artistName}简介",
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, shadows: [])));

    final Widget briefDesc = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        result["briefDesc"],
        style: TextStyle(color: Theme.of(context).textTheme.caption!.color),
      ),
    );
    final Widget button = InkWell(
      onTap: () {
        notImplemented(context);
      },
      child: const SizedBox(
        height: 36,
        child: Center(
          child: Text("完整歌手介绍"),
        ),
      ),
    );
    return [title, briefDesc, button];
  }

  List<Widget> _buildTopic(BuildContext context, Map result) {
    final List<Map>? data = (result["topicData"] as List?)?.cast();
    if (data == null || data.isEmpty) {
      return [];
    }
    const Widget title = Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text("相关专题文章",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, shadows: [])));
    final List<Widget> list = data.map<Widget>((topic) {
      final String subtitle =
          "by ${topic["creator"]["nickname"]} 阅读 ${topic["readCount"]}";
      return InkWell(
        onTap: () {
          debugPrint("on tap : ${topic["url"]}");
        },
        child: SizedBox(
          height: 72,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 8),
              Container(
                height: 72,
                width: 72 * 1.6,
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Image(
                    image: CachedImage(topic["rectanglePicUrl"]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Spacer(),
                  Text(topic["mainTitle"],
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.caption),
                  const Spacer(),
                  const Divider(height: 0)
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
        child: const SizedBox(
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
      loadTask: () => neteaseRepository!.artistDesc(widget.artistId),
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
