import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/page_comment.dart';
import 'package:quiet/pages/playlist/page_playlist_detail_selection.dart';
import 'package:quiet/pages/playlist/playlist_internal_search.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import 'music_list.dart';

///歌单详情信息item高度
const double HEIGHT_HEADER = 300;

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
  ///build a preview stack for loading or error
  Widget buildPreview(BuildContext context, Widget content) {
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
            OpacityTitle(
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
    return Scaffold(
      body: Loader<PlaylistDetail>(
          initialData: neteaseLocalData.getPlaylistDetail(widget.playlistId),
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
            return _PlaylistBody(result);
          }),
    );
  }
}

///the title of this page
class OpacityTitle extends StatefulWidget {
  OpacityTitle(
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
  State<StatefulWidget> createState() => OpacityTitleState();
}

class OpacityTitleState extends State<OpacityTitle> {
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
      title: Text(appBarOpacityValue < 0.5
          ? widget.defaultName
          : (widget.name ?? widget.defaultName)),
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
      token: "playlist_${widget.playlist.id}",
      musics: widget.musicList,
      remove: widget.playlist.creator["userId"] != LoginState.of(context).userId
          ? null
          : (music) async {
              var result = await neteaseRepository.playlistTracksEdit(
                  PlaylistOperation.remove, widget.playlist.id, [music.id]);
              if (result) {
                setState(() {
                  widget.playlist.musicList.remove(music);
                });
              }
              toast(context, result ? '删除成功' : '删除失败');
            },
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
                            delegate: PlaylistInternalSearchDelegate(
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
      ),
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
      return Container(
        child: Text('暂时还没有音乐'),
      );
    }

    bool owner =
        widget.playlist.creator["userId"] == LoginState.of(context).userId;
    if (index == 1) {
      Widget tail;
      if (!owner) {
        tail = _SubscribeButton(widget.playlist.subscribed,
            widget.playlist.subscribedCount, _doSubscribeChanged);
      }
      return MusicListHeader(widget.musicList.length, tail: tail);
    }
    return MusicTile(widget.musicList[index - 2]);
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

///播放列表头部背景
class PlayListHeaderBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: <Color>[
        color,
        color.withOpacity(0.8),
        color.withOpacity(0.5),
      ], begin: Alignment.topLeft)),
    );
  }
}

///header show list information
class DetailHeader extends StatelessWidget {
  const DetailHeader(
      {Key key,
      @required this.content,
      this.onCommentTap,
      this.onShareTap,
      this.onSelectionTap,
      int commentCount = 0,
      int shareCount = 0})
      : this.commentCount = commentCount ?? 0,
        this.shareCount = shareCount ?? 0,
        super(key: key);

  final Widget content;

  final GestureTapCallback onCommentTap;
  final GestureTapCallback onShareTap;
  final GestureTapCallback onSelectionTap;

  final int commentCount;
  final int shareCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PlayListHeaderBackground(),
        Material(
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
                      _HeaderAction(Icons.check_box, "多选", onSelectionTap),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
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

    return DetailHeader(
        commentCount: playlist.commentCount,
        shareCount: playlist.shareCount,
        onCommentTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CommentPage(
              threadId: CommentThreadId(playlist.id, CommentType.playlist,
                  payload: CommentThreadPayload.playlist(playlist)),
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
        onShareTap: () => notImplemented(context),
        content: Container(
          height: 150,
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: <Widget>[
              SizedBox(width: 24),
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  child: Stack(
                    children: <Widget>[
                      Hero(
                        tag: playlist.heroTag,
                        child: Image(
                            fit: BoxFit.cover,
                            image: NeteaseImage(playlist.coverUrl)),
                      ),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              Colors.black54,
                              Colors.black26,
                              Colors.transparent,
                              Colors.transparent,
                            ])),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.headset,
                                  color:
                                      Theme.of(context).primaryIconTheme.color,
                                  size: 12),
                              Text(getFormattedNumber(playlist.playCount),
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .body1
                                      .copyWith(fontSize: 11))
                            ],
                          ),
                        ),
                      )
                    ],
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
