import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/page_comment.dart';
import 'package:quiet/pages/page_playlist_detail_selection.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import 'page_artist_detail.dart';

part 'page_album_detail.dart';

///歌单详情信息item高度
const double _HEIGHT_HEADER = 300;

///page display a Playlist
///
///Playlist : a list of musics by user collected
///
///need [playlistId] to load data from network
///
///
class PlaylistDetailPage extends StatefulWidget {
  PlaylistDetailPage(this.playlistId, {this.playlist})
      : assert(playlistId != null);

  ///playlist id，can not be null
  final int playlistId;

  ///a simple playlist json obj , can be null
  ///used to preview playlist information when loading
  final PlaylistDetail playlist;

  @override
  State<StatefulWidget> createState() => _PlayListDetailState();
}

class _PlayListDetailState extends State<PlaylistDetailPage> {
  Color primaryColor = Colors.teal;

  ///disable primary color generate by [loadPrimaryColor]
  ///because of [PaletteGenerator] bad performance
  bool primaryColorGenerated = true;

  ///generate a primary color by playlist cover image
  void loadPrimaryColor(PlaylistDetail playlist) async {
    if (primaryColorGenerated) {
      return;
    }
    primaryColorGenerated = true;
    PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        NeteaseImage(playlist.coverUrl));
    var primaryColor = generator.mutedColor?.color;
    setState(() {
      this.primaryColor = primaryColor;
      debugPrint(
          "generated color for playlist(${playlist.name}) : $primaryColor");
    });
  }

  ///build a preview stack for loading or error
  Widget buildPreview(BuildContext context, Widget content) {
    if (widget.playlist != null) {
      loadPrimaryColor(widget.playlist);
    }
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            widget.playlist == null
                ? null
                : _PlaylistDetailHeader(widget.playlist),
            Expanded(child: SafeArea(child: content))
          ]..removeWhere((v) => v == null),
        ),
        Column(
          children: <Widget>[
            _OpacityTitle(
              name: null,
              defaultName: "歌单",
              appBarOpacity: ValueNotifier(0),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          primaryColor: primaryColor,
          primaryColorDark: primaryColor,
          accentColor: primaryColor),
      child: Scaffold(
        body: Loader<PlaylistDetail>(
            loadTask: () => neteaseRepository.playlistDetail(widget.playlistId),
            loadingBuilder: (context) {
              return buildPreview(
                  context,
                  Container(
                    height: 200,
                    child: Center(child: Text("加载中...")),
                  ));
            },
            failedWidgetBuilder: (context, result, msg) {
              return buildPreview(
                  context,
                  Container(
                    height: 200,
                    child: Center(child: Text("加载失败")),
                  ));
            },
            builder: (context, result) {
              loadPrimaryColor(result);
              return _PlaylistBody(result);
            }),
      ),
    );
  }
}

///the title of this page
class _OpacityTitle extends StatefulWidget {
  _OpacityTitle(
      {@required this.name,
      @required this.appBarOpacity,
      @required this.defaultName,
      this.actions})
      : assert(defaultName != null);

  ///title background opacity value notifier, from 0 - 1;
  final ValueNotifier<double> appBarOpacity;

  ///the name of playlist
  final String name;

  final String defaultName;

  final List<Widget> actions;

  @override
  State<StatefulWidget> createState() => _OpacityTitleState();
}

class _OpacityTitleState extends State<_OpacityTitle> {
  double appBarOpacityValue = 0;

  @override
  void initState() {
    super.initState();
    widget.appBarOpacity?.addListener(_onAppBarOpacity);
  }

  void _onAppBarOpacity() {
    setState(() {
      appBarOpacityValue = widget.appBarOpacity.value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.appBarOpacity?.removeListener(_onAppBarOpacity);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
      title: Text(
          appBarOpacityValue < 0.5 ? widget.defaultName : (widget.name ?? "")),
      toolbarOpacity: 1,
      backgroundColor:
          Theme.of(context).primaryColor.withOpacity(appBarOpacityValue),
      actions: widget.actions,
    );
  }
}

///body display the list of song item and a header of playlist
class _PlaylistBody extends StatefulWidget {
  _PlaylistBody(this.playlist) : assert(playlist != null);

  final PlaylistDetail playlist;

  List<Music> get musicList => playlist.musicList;

  @override
  _PlaylistBodyState createState() {
    return new _PlaylistBodyState();
  }
}

class _PlaylistBodyState extends State<_PlaylistBody> {
  SongTileProvider _songTileProvider;

  ScrollController scrollController;

  ValueNotifier<double> appBarOpacity = ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    debugPrint(
        "show playlist detail : ${widget.playlist.name} , count :${widget.musicList.length}");

    _songTileProvider =
        SongTileProvider("playlist_${widget.playlist.id}", widget.musicList);
    scrollController = ScrollController();
    scrollController.addListener(() {
      var scrollHeight = scrollController.offset;
      double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
      double areaHeight = (_HEIGHT_HEADER - appBarHeight);
      this.appBarOpacity.value = (scrollHeight / areaHeight).clamp(0.0, 1.0);
    });
  }

  @override
  void didUpdateWidget(_PlaylistBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _songTileProvider =
        SongTileProvider("playlist_${widget.playlist.id}", widget.musicList);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        BoxWithBottomPlayerController(
          ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: 1 + (_songTileProvider?.size ?? 0),
            itemBuilder: _buildList,
            controller: scrollController,
          ),
        ),
        Column(
          children: <Widget>[
            _OpacityTitle(
              name: widget.playlist.name,
              defaultName: "歌单",
              appBarOpacity: appBarOpacity,
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.search),
                    tooltip: "歌单内搜索",
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate: _InternalFilterDelegate(
                              widget.playlist, Theme.of(context)));
                    }),
                IconButton(
                    icon: Icon(Icons.more_vert),
                    tooltip: "更多选项",
                    onPressed: () {})
              ],
            )
          ],
        )
      ],
    );
  }

  ///订阅与取消订阅歌单
  Future<bool> _doSubscribeChanged(bool subscribe) async {
    bool succeed;
    try {
      succeed = await showLoaderOverlay(context,
          neteaseRepository.playlistSubscribe(widget.playlist.id, !subscribe));
    } catch (e) {
      succeed = false;
    }
    String action = !subscribe ? "收藏" : "取消收藏";
    if (succeed) {
      showSimpleNotification(context, Text("$action成功"));
    } else {
      showSimpleNotification(context, Text("$action失败"),
          background: Theme.of(context).errorColor);
    }
    return succeed ? !subscribe : subscribe;
  }

  Widget _buildList(BuildContext context, int index) {
    if (index == 0) {
      return _PlaylistDetailHeader(widget.playlist);
    }
    if (widget.musicList.isEmpty) {
      return _EmptyPlaylistSection();
    }
    bool owner =
        widget.playlist.creator["userId"] == LoginState.of(context).userId;
    if (index == 1) {
      Widget tail;
      if (!owner) {
        tail = _SubscribeButton(widget.playlist.subscribed,
            widget.playlist.subscribedCount, _doSubscribeChanged);
      }
      return _songTileProvider?.buildListHeader(context, tail: tail);
    }
    return _songTileProvider?.buildWidget(index - 1, context,
        onDelete: !owner
            ? null
            : () async {
                var result = await neteaseRepository.playlistTracksEdit(
                    PlaylistOperation.remove,
                    widget.playlist.id,
                    [_songTileProvider.musics[index - 2].id]);
                if (result) {
                  setState(() {
                    widget.playlist.musicList.removeAt(index - 2);
                  });
                  showSimpleNotification(context, Text("已成功删除歌曲"));
                } else {
                  showSimpleNotification(context, Text("删除歌曲失败"),
                      icon: Icon(Icons.error),
                      background: Theme.of(context).errorColor);
                }
              });
  }
}

class _SubscribeButton extends StatefulWidget {
  final bool subscribed;

  final int subscribedCount;

  ///currentState : is playlist be subscribed when function invoked
  final Future<bool> Function(bool currentState) doSubscribeChanged;

  const _SubscribeButton(
      this.subscribed, this.subscribedCount, this.doSubscribeChanged,
      {Key key})
      : super(key: key);

  @override
  _SubscribeButtonState createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<_SubscribeButton> {
  bool subscribed = false;

  @override
  void initState() {
    super.initState();
    subscribed = widget.subscribed;
  }

  @override
  Widget build(BuildContext context) {
    if (!subscribed) {
      return Container(
        height: 40,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Theme.of(context).primaryColor.withOpacity(0.5),
          Theme.of(context).primaryColor
        ])),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final result = await widget.doSubscribeChanged(subscribed);
              setState(() {
                subscribed = result;
              });
            },
            child: Row(
              children: <Widget>[
                SizedBox(width: 16),
                Icon(Icons.add,
                    color: Theme.of(context).primaryIconTheme.color),
                SizedBox(width: 4),
                Text(
                  "收藏(${getFormattedNumber(widget.subscribedCount)})",
                  style: Theme.of(context).primaryTextTheme.body1,
                ),
                SizedBox(width: 16),
              ],
            ),
          ),
        ),
      );
    } else {
      return InkWell(
          child: Container(
            height: 40,
            child: Row(
              children: <Widget>[
                SizedBox(width: 16),
                Icon(Icons.folder_special,
                    size: 20, color: Theme.of(context).disabledColor),
                SizedBox(width: 4),
                Text(getFormattedNumber(widget.subscribedCount),
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(fontSize: 14)),
                SizedBox(width: 16),
              ],
            ),
          ),
          onTap: () async {
            final result = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text("确定不再收藏此歌单吗?"),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("取消")),
                      FlatButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text("不再收藏"))
                    ],
                  );
                });
            if (result != null && result) {
              final result = await widget.doSubscribeChanged(subscribed);
              setState(() {
                subscribed = result;
              });
            }
          });
    }
  }
}

class _EmptyPlaylistSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Center(
        child: Text("暂无音乐"),
      ),
    );
  }
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

///header show list information
class _DetailHeader extends StatelessWidget {
  const _DetailHeader(
      {Key key,
      @required this.content,
      this.onCommentTap,
      this.onShareTap,
      this.onDownloadTap,
      this.onSelectionTap,
      this.commentCount = 0,
      this.shareCount = 0})
      : assert(commentCount != null),
        assert(shareCount != null),
        super(key: key);

  final Widget content;

  final GestureTapCallback onCommentTap;
  final GestureTapCallback onShareTap;
  final GestureTapCallback onDownloadTap;
  final GestureTapCallback onSelectionTap;

  final int commentCount;
  final int shareCount;

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColorDark;

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
              content,
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _HeaderAction(
                        Icons.comment,
                        commentCount > 0 ? commentCount.toString() : "评论",
                        onCommentTap),
                    _HeaderAction(
                        Icons.share,
                        shareCount > 0 ? shareCount.toString() : "分享",
                        onShareTap),
                    _HeaderAction(Icons.file_download, "下载", onDownloadTap),
                    _HeaderAction(Icons.check_box, "多选", onSelectionTap),
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

///a detail header describe playlist information
class _PlaylistDetailHeader extends StatelessWidget {
  _PlaylistDetailHeader(this.playlist) : assert(playlist != null);

  final PlaylistDetail playlist;

  ///the music list
  ///could be null if music list if not loaded
  List<Music> get musicList => playlist.musicList;

  @override
  Widget build(BuildContext context) {
    Map<String, Object> creator = playlist.creator;

    return _DetailHeader(
        onCommentTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CommentPage(
              threadId: CommentThreadId(playlist.id, CommentType.playlist,
                  playload: CommentThreadPayload.playlist(playlist)),
            );
          }));
        },
        onSelectionTap: () async {
          if (musicList == null) {
            showSimpleNotification(context, Text("歌曲未加载,请加载后再试"));
          } else {
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
              return PlaylistSelectionPage(
                  list: musicList,
                  onDelete: (selected) async {
                    return neteaseRepository.playlistTracksEdit(
                        PlaylistOperation.remove,
                        playlist.id,
                        selected.map((m) => m.id).toList());
                  });
            }));
          }
        },
        onDownloadTap: () => notImplemented(context),
        onShareTap: () => notImplemented(context),
        content: Container(
          height: 150,
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: <Widget>[
              SizedBox(width: 24),
              Hero(
                tag: playlist.heroTag,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    child: Image(
                        fit: BoxFit.cover,
                        image: NeteaseImage(playlist.coverUrl)),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10),
                    Text(
                      playlist.name,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .title
                          .copyWith(fontSize: 17),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () => {},
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: ClipOval(
                                child: Image(
                                    image: NeteaseImage(creator["avatarUrl"])),
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
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 16),
            ],
          ),
        ));
  }
}

class _InternalFilterDelegate extends SearchDelegate {
  _InternalFilterDelegate(this.playlist, this.theme)
      : assert(playlist != null && playlist.musicList != null);

  final PlaylistDetail playlist;

  List<Music> get list => playlist.musicList;

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
