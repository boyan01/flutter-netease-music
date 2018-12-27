import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:quiet/pages/page_comment.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

///歌单详情信息item高度
const double _HEIGHT_HEADER = 300;

class PlaylistDetailPage extends StatefulWidget {
  PlaylistDetailPage(this.playlistId, {this.playlist})
      : assert(playlistId != null);

  ///playlist id，can not be null
  final int playlistId;

  ///a simple playlist json obj , can be null
  ///used to preview playlist information when loading
  final Map<String, Object> playlist;

  @override
  State<StatefulWidget> createState() => _PlayListDetailState();
}

class _PlayListDetailState extends State<PlaylistDetailPage> {
  ValueNotifier<double> appBarOpacity = ValueNotifier(0);

  ScrollController scrollController;

  Map<String, Object> playlist;

  Color primaryColor;

  static _PlayListDetailState of(BuildContext context) {
    return context
        .ancestorStateOfType(const TypeMatcher<_PlayListDetailState>());
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(() {
      var scrollHeight = scrollController.offset;
      double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
      double areaHeight = (_HEIGHT_HEADER - appBarHeight);
      this.appBarOpacity.value = (scrollHeight / areaHeight).clamp(0.0, 1.0);
    });
  }

  ///generate a primary color by playlist cover image
  void loadPrimaryColor() async {
    if (playlist == null || this.primaryColor != null) {
      return;
    }
    PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        NeteaseImage(playlist["coverImgUrl"]));
    var primaryColor = generator.mutedColor?.color;
    setState(() {
      this.primaryColor = primaryColor;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          primaryColor: primaryColor ?? Theme.of(context).primaryColor,
          accentColor: primaryColor),
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Loader<Map<String, dynamic>>(
                loadTask: () =>
                    neteaseRepository.playlistDetail(widget.playlistId),
                resultVerify: neteaseRepository.responseVerify,
                loadingBuilder: (context) {
                  loadPrimaryColor();
                  Widget layout = Container(
                    height: 200,
                    child: Center(child: Text("加载中...")),
                  );
                  if (widget.playlist != null) {
                    layout = Column(
                      children: <Widget>[
                        _PlaylistDetailHeader(widget.playlist),
                        layout
                      ],
                    );
                  } else {
                    layout = Center(child: layout);
                  }
                  return layout;
                },
                failedWidgetBuilder: (context, result, msg) {
                  Widget layout = Container(
                    height: 200,
                    child: Center(child: Text("加载失败")),
                  );
                  if (widget.playlist != null) {
                    layout = Column(
                      children: <Widget>[
                        _PlaylistDetailHeader(widget.playlist),
                        layout
                      ],
                    );
                  } else {
                    layout = Center(child: layout);
                  }
                  return layout;
                },
                builder: (context, result) {
                  playlist = result["playlist"];
                  loadPrimaryColor();
                  return _PlaylistBody(
                    playlist,
                    scrollController: scrollController,
                  );
                }),
            Column(
              children: <Widget>[
                _OpacityTitle(
                    playlist == null ? "歌单" : playlist["name"], appBarOpacity)
              ],
            )
          ],
        ),
      ),
    );
  }
}

///the title of this page
class _OpacityTitle extends StatefulWidget {
  _OpacityTitle(this.name, this.appBarOpacity);

  ///title background opacity value notifier, from 0 - 1;
  final ValueNotifier<double> appBarOpacity;

  ///the name of playlist
  final String name;

  @override
  State<StatefulWidget> createState() => _OpacityTitleState();
}

class _OpacityTitleState extends State<_OpacityTitle> {
  double appBarOpacityValue = 0;

  @override
  void initState() {
    super.initState();
    widget.appBarOpacity.addListener(_onAppBarOpacity);
  }

  void _onAppBarOpacity() {
    setState(() {
      appBarOpacityValue = widget.appBarOpacity.value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.appBarOpacity.removeListener(_onAppBarOpacity);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
      title: Text(appBarOpacityValue < 0.5 ? "歌单" : (widget.name ?? "歌单")),
      toolbarOpacity: 1,
      backgroundColor:
          Theme.of(context).primaryColor.withOpacity(appBarOpacityValue),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.search),
            tooltip: "歌单内搜索",
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: _InternalFilterDelegate(
                      _PlayListDetailState.of(context).playlist,
                      Theme.of(context)));
            }),
        IconButton(
            icon: Icon(Icons.more_vert), tooltip: "更多选项", onPressed: () {})
      ],
    );
  }
}

///body display the list of song item and a header of playlist
class _PlaylistBody extends StatelessWidget {
  final ScrollController scrollController;

  _PlaylistBody(this.playlist, {this.scrollController})
      : songTileProvider = SongTileProvider(
            "playlist_${playlist["id"]}", _mapPlaylist(playlist["tracks"]));

  final Map<String, Object> playlist;
  final SongTileProvider songTileProvider;

  @override
  Widget build(BuildContext context) {
    return Quiet(
      child: BoxWithBottomPlayerController(
        ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: 1 + (songTileProvider?.size ?? 0),
          itemBuilder: _buildList,
          controller: scrollController,
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, int index) {
    if (index == 0) {
      return _PlaylistDetailHeader(playlist);
    }
    return songTileProvider?.buildWidget(index - 1, context);
  }
}

///map playlist json tracks to Music list
List<Music> _mapPlaylist(List<Object> tracks) {
  var list = tracks
      .cast<Map>()
      .map((e) => mapJsonToMusic(e, artistKey: "ar", albumKey: "al"));
  return list.toList();
}

///action button for playlist header
class _HeaderAction extends StatelessWidget {
  _HeaderAction(this.icon, this.action, this.onTap);

  final IconData icon;

  final String action;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).primaryTextTheme;

    return InkResponse(
      onTap: onTap,
      splashColor: textTheme.body1.color,
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: textTheme.body1.color,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 2),
          ),
          Text(
            action,
            style: textTheme.caption,
          )
        ],
      ),
    );
  }
}

///a detail header describe playlist information
class _PlaylistDetailHeader extends StatelessWidget {
  _PlaylistDetailHeader(this.playlist);

  final Map<String, Object> playlist;

  @override
  Widget build(BuildContext context) {
    Map<String, Object> creator = playlist["creator"];

    Color color;
    if (_PlayListDetailState.of(context).primaryColor != null) {
      //NOTE: use theme.primaryColor to rebuild when primaryColor updated
      color = Theme.of(context).primaryColor;
    } else {
      color = Colors.black;
    }

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: <Color>[
        color,
        color.withOpacity(0.8),
        color.withOpacity(0.5),
      ], begin: Alignment.topLeft)),
      child: Material(
        color: Colors.black.withOpacity(0.5),
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight),
          child: Column(
            children: <Widget>[
              Container(
                height: 150,
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      margin: EdgeInsets.only(left: 32, right: 20),
                      child: Hero(
                        tag: playlist["coverImgUrl"],
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                            child: Image(
                                fit: BoxFit.cover,
                                image: NeteaseImage(playlist["coverImgUrl"])),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 40),
                          child: Text(
                            playlist["name"],
                            style: Theme.of(context)
                                .primaryTextTheme
                                .title
                                .copyWith(fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 20)),
                        InkWell(
                          onTap: () => {},
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: ClipOval(
                                  child: Image(
                                      image:
                                          NeteaseImage(creator["avatarUrl"])),
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(left: 4)),
                              Text(
                                creator["nickname"],
                                style: Theme.of(context).primaryTextTheme.body1,
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).primaryIconTheme.color,
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _HeaderAction(Icons.comment, "评论", () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CommentPage(
                          threadId: CommentThreadId(
                              playlist["id"], CommentType.playlist,
                              playload:
                                  CommentThreadPayload.playlist(playlist)),
                        );
                      }));
                    }),
                    _HeaderAction(Icons.share, "分享", () => {}),
                    _HeaderAction(Icons.file_download, "下载", () => {}),
                    _HeaderAction(Icons.check_box, "多选", () => {}),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _InternalFilterDelegate extends SearchDelegate {
  _InternalFilterDelegate(this.playlist, this.theme)
      : list = _mapPlaylist(playlist["tracks"]);

  final Map<String, dynamic> playlist;

  final List<Music> list;

  final ThemeData theme;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    var theme = this.theme ?? Theme.of(context);
    return theme.copyWith(
        textTheme:
            theme.textTheme.copyWith(title: theme.primaryTextTheme.title),
        primaryColorBrightness: Brightness.dark);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    return Theme(
        data: theme,
        child: BoxWithBottomPlayerController(buildSection(context)));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  Widget buildSection(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    var result = list
        ?.where((m) => m.title.contains(query) || m.subTitle.contains(query))
        ?.toList();
    if (result == null || result.isEmpty) {
      return _EmptyResultSection(query);
    }
    return _InternalResultSection(musics: result);
  }
}

class _EmptyResultSection extends StatelessWidget {
  const _EmptyResultSection(this.query);

  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 50),
      child: Center(
        child: Text('未找到与"$query"相关的内容'),
      ),
    );
  }
}

class _InternalResultSection extends StatelessWidget {
  const _InternalResultSection({Key key, this.musics}) : super(key: key);

  ///result song list, can not be null and empty
  final List<Music> musics;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: musics.length,
        itemBuilder: (context, index) {
          return SongTile(
            musics[index],
            index,
            leadingType: SongTileLeadingType.none,
            onTap: () {
              quiet.play(music: musics[index]);
            },
          );
        });
  }
}
