import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiet/pages/page_playlist_detail_selection.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

///歌手详情页
class ArtistDetailPage extends StatefulWidget {
  ///歌手ID
  final int artistId;

  const ArtistDetailPage({Key key, @required this.artistId})
      : assert(artistId != null),
        super(key: key);

  @override
  ArtistDetailPageState createState() {
    return new ArtistDetailPageState();
  }
}

class ArtistDetailPageState extends State<ArtistDetailPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Loader(
        loadTask: () => neteaseRepository.artistDetail(widget.artistId),
        resultVerify: neteaseRepository.responseVerify,
        builder: (context, result) {
          Map artist = result["artist"];
          List<Music> musicList = mapJsonListToMusicList(result["hotSongs"],
              artistKey: "ar", albumKey: "al");

          return Scaffold(
              body: DefaultTabController(
            length: 4,
            child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                      child: SliverAppBar(
                        pinned: true,
                        expandedHeight: 256,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text('${artist["name"]}'),
                          background: Container(
                            foregroundDecoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                  Colors.black87,
                                  Colors.transparent,
                                  Colors.transparent,
                                ])),
                            child: Image(
                              fit: BoxFit.cover,
                              image: NeteaseImage(artist["img1v1Url"]),
                            ),
                          ),
                        ),
                        forceElevated: innerBoxIsScrolled,
                        bottom: TabBar(tabs: [
                          Tab(text: "热门单曲"),
                          Tab(text: "专辑${artist["albumSize"]}"),
                          Tab(text: "视频${artist["mvSize"]}"),
                          Tab(text: "艺人信息"),
                        ]),
                        actions: <Widget>[
                          IconButton(
                              icon: Icon(Icons.share,
                                  color:
                                      Theme.of(context).primaryIconTheme.color),
                              onPressed: null)
                        ],
                      ),
                    ),
                  ];
                },
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: kToolbarHeight + kTextTabBarHeight),
                    child: TabBarView(
                      children: [
                        _PageHotSongs(musicList: musicList),
                        _PageAlbums(artistId: widget.artistId),
                        _PageMVs(artistId: widget.artistId),
                        _PageArtistIntroduction(
                            artistId: widget.artistId,
                            artistName: artist["name"]),
                      ],
                    ),
                  ),
                )),
          ));
        });
  }
}

///热门单曲
class _PageHotSongs extends StatefulWidget {
  const _PageHotSongs({Key key, @required this.musicList})
      : assert(musicList != null),
        super(key: key);

  final List<Music> musicList;

  @override
  _PageHotSongsState createState() {
    return new _PageHotSongsState();
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
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
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
    if (widget.musicList.isEmpty) {
      return Container(
        child: Center(child: Text("该歌手无热门曲目")),
      );
    }
    return ListView.builder(
        itemCount: widget.musicList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader(context);
          } else {
            return SongTile(widget.musicList[index - 1], index);
          }
        });
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

class _PageAlbumsState extends State<_PageAlbums>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Loader<Map>(
        loadTask: () => neteaseRepository.artistAlbums(widget.artistId),
        resultVerify: neteaseRepository.responseVerify,
        builder: (context, result) {
          List<Map> albums = (result["hotAlbums"] as List).cast();
          return ListView.builder(
              itemCount: albums.length,
              itemBuilder: (context, index) {
                return AlbumTile(album: albums[index]);
              });
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class _PageMVs extends StatefulWidget {
  final int artistId;

  const _PageMVs({Key key, @required this.artistId}) : super(key: key);

  @override
  _PageMVsState createState() {
    return new _PageMVsState();
  }
}

class _PageMVsState extends State<_PageMVs> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Loader<Map>(
      loadTask: () => neteaseRepository.artistMvs(widget.artistId),
      resultVerify: neteaseRepository.responseVerify,
      builder: (context, result) {
        final List<Map> mvs = (result["mvs"] as List).cast();
        return ListView.builder(
            itemCount: mvs.length,
            itemBuilder: (context, index) {
              final mv = mvs[index];
              return InkWell(
                onTap: () {
                  debugPrint("on tap : ${mv["id"]}");
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
                            image: NeteaseImage(mv["imgurl16v9"]),
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
                          Text(mv["name"],
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4),
                          Text(mv["publishTime"],
                              style: Theme.of(context).textTheme.caption),
                          Spacer(),
                          Divider(height: 0)
                        ],
                      ))
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _PageArtistIntroduction extends StatefulWidget {
  final int artistId;

  final String artistName;

  const _PageArtistIntroduction(
      {Key key, @required this.artistId, @required this.artistName})
      : super(key: key);

  @override
  _PageArtistIntroductionState createState() {
    return new _PageArtistIntroductionState();
  }
}

class _PageArtistIntroductionState extends State<_PageArtistIntroduction>
    with AutomaticKeepAliveClientMixin {
  List<Widget> _buildIntroduction(BuildContext context, Map result) {
    Widget title = Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(("${widget.artistName}简介"),
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, shadows: [])));

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
    final List<Map> data = (result["topicData"] as List).cast();
    if (data.length == 0) {
      return [];
    }
    Widget title = Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(("相关专题文章"),
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, shadows: [])));
    List<Widget> list = data.map<Widget>((topic) {
      String subtitle =
          "by ${topic["creator"]["nickname"]} 阅读 ${topic["readCount"]}";
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
                    image: NeteaseImage(topic["rectanglePicUrl"]),
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
                  Text(topic["mainTitle"],
                      maxLines: 1, overflow: TextOverflow.ellipsis),
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
    return Loader<Map>(
      loadTask: () => neteaseRepository.artistDesc(widget.artistId),
      resultVerify: neteaseRepository.responseVerify,
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

class FlexibleSpaceBar extends StatefulWidget {
  /// Creates a flexible space bar.
  ///
  /// Most commonly used in the [AppBar.flexibleSpace] field.
  const FlexibleSpaceBar(
      {Key key,
      this.title,
      this.background,
      this.centerTitle,
      this.collapseMode = CollapseMode.parallax})
      : assert(collapseMode != null),
        super(key: key);

  /// The primary contents of the flexible space bar when expanded.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Shown behind the [title] when expanded.
  ///
  /// Typically an [Image] widget with [Image.fit] set to [BoxFit.cover].
  final Widget background;

  /// Whether the title should be centered.
  ///
  /// Defaults to being adapted to the current [TargetPlatform].
  final bool centerTitle;

  /// Collapse effect while scrolling.
  ///
  /// Defaults to [CollapseMode.parallax].
  final CollapseMode collapseMode;

  /// Wraps a widget that contains an [AppBar] to convey sizing information down
  /// to the [FlexibleSpaceBar].
  ///
  /// Used by [Scaffold] and [SliverAppBar].
  ///
  /// `toolbarOpacity` affects how transparent the text within the toolbar
  /// appears. `minExtent` sets the minimum height of the resulting
  /// [FlexibleSpaceBar] when fully collapsed. `maxExtent` sets the maximum
  /// height of the resulting [FlexibleSpaceBar] when fully expanded.
  /// `currentExtent` sets the scale of the [FlexibleSpaceBar.background] and
  /// [FlexibleSpaceBar.title] widgets of [FlexibleSpaceBar] upon
  /// initialization.
  ///
  /// See also:
  ///
  ///   * [FlexibleSpaceBarSettings] which creates a settings object that can be
  ///     used to specify these settings to a [FlexibleSpaceBar].
  static Widget createSettings({
    double toolbarOpacity,
    double minExtent,
    double maxExtent,
    @required double currentExtent,
    @required Widget child,
  }) {
    assert(currentExtent != null);
    return FlexibleSpaceBarSettings(
      toolbarOpacity: toolbarOpacity ?? 1.0,
      minExtent: minExtent ?? currentExtent,
      maxExtent: maxExtent ?? currentExtent,
      currentExtent: currentExtent,
      child: child,
    );
  }

  @override
  _FlexibleSpaceBarState createState() => _FlexibleSpaceBarState();
}

class _FlexibleSpaceBarState extends State<FlexibleSpaceBar> {
  bool _getEffectiveCenterTitle(ThemeData theme) {
    if (widget.centerTitle != null) return widget.centerTitle;
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return false;
      case TargetPlatform.iOS:
        return true;
    }
    return null;
  }

  Alignment _getTitleAlignment(bool effectiveCenterTitle) {
    if (effectiveCenterTitle) return Alignment.bottomCenter;
    final TextDirection textDirection = Directionality.of(context);
    assert(textDirection != null);
    switch (textDirection) {
      case TextDirection.rtl:
        return Alignment.bottomRight;
      case TextDirection.ltr:
        return Alignment.bottomLeft;
    }
    return null;
  }

  double _getCollapsePadding(double t, FlexibleSpaceBarSettings settings) {
    switch (widget.collapseMode) {
      case CollapseMode.pin:
        return -(settings.maxExtent - settings.currentExtent);
      case CollapseMode.none:
        return 0.0;
      case CollapseMode.parallax:
        final double deltaExtent = settings.maxExtent - settings.minExtent;
        return -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final FlexibleSpaceBarSettings settings =
        context.inheritFromWidgetOfExactType(FlexibleSpaceBarSettings);
    assert(settings != null,
        'A FlexibleSpaceBar must be wrapped in the widget returned by FlexibleSpaceBar.createSettings().');

    final List<Widget> children = <Widget>[];

    final double deltaExtent = settings.maxExtent - settings.minExtent;

    // 0.0 -> Expanded
    // 1.0 -> Collapsed to toolbar
    final double t =
        (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
            .clamp(0.0, 1.0);

    // background image
    if (widget.background != null) {
      final double fadeStart =
          math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
      const double fadeEnd = 1.0;
      assert(fadeStart <= fadeEnd);
      final double opacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);
      if (opacity > 0.0) {
        children.add(Positioned(
            top: _getCollapsePadding(t, settings),
            left: 0.0,
            right: 0.0,
            height: settings.maxExtent,
            child: Opacity(opacity: opacity, child: widget.background)));
      }
    }

    if (widget.title != null) {
      Widget title;
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          title = widget.title;
          break;
        case TargetPlatform.fuchsia:
        case TargetPlatform.android:
          title = Semantics(
            namesRoute: true,
            child: widget.title,
          );
      }

      final ThemeData theme = Theme.of(context);
      final double opacity = settings.toolbarOpacity;
      if (opacity > 0.0) {
        TextStyle titleStyle = theme.primaryTextTheme.title;
        titleStyle =
            titleStyle.copyWith(color: titleStyle.color.withOpacity(opacity));
        final bool effectiveCenterTitle = _getEffectiveCenterTitle(theme);
        final double scaleValue =
            Tween<double>(begin: 1.5, end: 1.0).transform(t);
        final Matrix4 scaleTransform = Matrix4.identity()
          ..scale(scaleValue, scaleValue, 1.0);
        final Alignment titleAlignment =
            _getTitleAlignment(effectiveCenterTitle);
        children.add(Container(
            padding: EdgeInsetsDirectional.only(
                start: effectiveCenterTitle ? 0.0 : 72.0, bottom: 16.0 + 48),
            child: Transform(
                alignment: titleAlignment,
                transform: scaleTransform,
                child: Align(
                    alignment: titleAlignment,
                    child: DefaultTextStyle(
                      style: titleStyle,
                      child: title,
                    )))));
      }
    }

    return ClipRect(child: Stack(children: children));
  }
}
