import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/material/flexible_app_bar.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/account/page_user_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import 'music_list.dart';
import 'page_playlist_detail_selection.dart';
import 'playlist_internal_search.dart';

///歌单详情信息 header 高度
const double HEIGHT_HEADER = 280 + kToolbarHeight;

///page display a Playlist
///
///Playlist : a list of musics by user collected
///
///need [playlistId] to load data from network
///
///
class PlaylistDetailPage extends StatefulWidget {
  PlaylistDetailPage(this.playlistId, {this.playlist}) : assert(playlistId != null);

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
  Widget _buildPreview(BuildContext context, Widget content) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: widget.playlist == null ? Text('歌单') : null,
          expandedHeight: widget.playlist == null ? kToolbarHeight : HEIGHT_HEADER,
          flexibleSpace: widget.playlist == null ? null : _PlaylistDetailHeader(widget.playlist),
          bottom: widget.playlist == null ? null : MusicListHeader(widget.playlist.trackCount),
        ),
        SliverList(delegate: SliverChildListDelegate([content]))
      ],
    );
  }

  Widget _buildLoading(BuildContext context) {
    return _buildPreview(context, Container(height: 200, child: Center(child: Text("加载中..."))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BoxWithBottomPlayerController(
        Loader<PlaylistDetail>(
            initialData: neteaseLocalData.getPlaylistDetail(widget.playlistId),
            loadTask: () => neteaseRepository.playlistDetail(widget.playlistId),
            loadingBuilder: (context) {
              return _buildLoading(context);
            },
            errorBuilder: (context, result) {
              return _buildPreview(
                  context,
                  Container(
                    height: 200,
                    child: Center(child: Text("加载失败")),
                  ));
            },
            builder: (context, result) {
              if (result == null) return _buildLoading(context);
              return _PlaylistBody(result);
            }),
      ),
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
  @override
  Widget build(BuildContext context) {
    return MusicTileConfiguration(
      token: "playlist_${widget.playlist.id}",
      musics: widget.musicList,
      remove: widget.playlist.creator["userId"] != UserAccount.of(context).userId
          ? null
          : (music) async {
              var result =
                  await neteaseRepository.playlistTracksEdit(PlaylistOperation.remove, widget.playlist.id, [music.id]);
              if (result) {
                setState(() {
                  widget.playlist.musicList.remove(music);
                });
              }
              toast(result ? '删除成功' : '删除失败');
            },
      onMusicTap: MusicTileConfiguration.defaultOnTap,
      leadingBuilder: MusicTileConfiguration.indexedLeadingBuilder,
      trailingBuilder: MusicTileConfiguration.defaultTrailingBuilder,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            elevation: 0,
            pinned: true,
            backgroundColor: Colors.transparent,
            expandedHeight: HEIGHT_HEADER,
            bottom: _buildListHeader(context),
            flexibleSpace: _PlaylistDetailHeader(widget.playlist),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) => MusicTile(widget.musicList[index]),
                childCount: widget.musicList.length),
          ),
        ],
      ),
    );
  }

  ///订阅与取消订阅歌单
  Future<bool> _doSubscribeChanged(bool subscribe) async {
    bool succeed;
    try {
      succeed = await showLoaderOverlay(context, neteaseRepository.playlistSubscribe(widget.playlist.id, !subscribe));
    } catch (e) {
      succeed = false;
    }
    String action = !subscribe ? "收藏" : "取消收藏";
    if (succeed) {
      showSimpleNotification(Text("$action成功"));
    } else {
      showSimpleNotification(Text("$action失败"), background: Theme.of(context).errorColor);
    }
    return succeed ? !subscribe : subscribe;
  }

  Widget _buildListHeader(BuildContext context) {
    bool owner = widget.playlist.creator["userId"] == UserAccount.of(context).userId;
    Widget tail;
    if (!owner) {
      tail = _SubscribeButton(widget.playlist.subscribed, widget.playlist.subscribedCount, _doSubscribeChanged);
    }
    return MusicListHeader(widget.musicList.length, tail: tail);
  }
}

class _SubscribeButton extends StatefulWidget {
  final bool subscribed;

  final int subscribedCount;

  ///currentState : is playlist be subscribed when function invoked
  final Future<bool> Function(bool currentState) doSubscribeChanged;

  const _SubscribeButton(this.subscribed, this.subscribedCount, this.doSubscribeChanged, {Key key}) : super(key: key);

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
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor.withOpacity(0.5), Theme.of(context).primaryColor])),
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
                  Icon(Icons.add, color: Theme.of(context).primaryIconTheme.color),
                  SizedBox(width: 4),
                  Text(
                    "收藏(${getFormattedNumber(widget.subscribedCount)})",
                    style: Theme.of(context).primaryTextTheme.bodyText2,
                  ),
                  SizedBox(width: 16),
                ],
              ),
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
                Icon(Icons.folder_special, size: 20, color: Theme.of(context).disabledColor),
                SizedBox(width: 4),
                Text(getFormattedNumber(widget.subscribedCount),
                    style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14)),
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
                      FlatButton(onPressed: () => Navigator.pop(context), child: Text("取消")),
                      FlatButton(onPressed: () => Navigator.pop(context, true), child: Text("不再收藏"))
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
      splashColor: textTheme.bodyText2.color,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: textTheme.bodyText2.color,
            ),
            const Padding(padding: EdgeInsets.only(top: 4)),
            Text(
              action,
              style: textTheme.caption.copyWith(fontSize: 13),
            )
          ],
        ),
      ),
    );
  }
}

///播放列表头部背景
class PlayListHeaderBackground extends StatelessWidget {
  final String imageUrl;

  const PlayListHeaderBackground({Key key, @required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Image(image: CachedImage(imageUrl), fit: BoxFit.cover, width: 120, height: 1),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        Container(color: Colors.black.withOpacity(0.3))
      ],
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
      int shareCount = 0,
      this.background})
      : this.commentCount = commentCount ?? 0,
        this.shareCount = shareCount ?? 0,
        super(key: key);

  final Widget content;

  final GestureTapCallback onCommentTap;
  final GestureTapCallback onShareTap;
  final GestureTapCallback onSelectionTap;

  final int commentCount;
  final int shareCount;

  final Widget background;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        background,
        Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
            child: Column(
              children: <Widget>[
                content,
                SizedBox(height: 10),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _HeaderAction(Icons.comment, commentCount > 0 ? commentCount.toString() : "评论", onCommentTap),
                    _HeaderAction(Icons.share, shareCount > 0 ? shareCount.toString() : "分享", onShareTap),
                    _HeaderAction(Icons.file_download, '下载', null),
                    _HeaderAction(Icons.check_box, "多选", onSelectionTap),
                  ],
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ]..removeWhere((v) => v == null),
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
    return FlexibleDetailBar(
      background: PlayListHeaderBackground(imageUrl: playlist.coverUrl),
      content: _buildContent(context),
      builder: (context, t) => AppBar(
        title: Text(t > 0.5 ? playlist.name : '歌单'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              tooltip: "歌单内搜索",
              onPressed: () {
                showSearch(context: context, delegate: PlaylistInternalSearchDelegate(playlist));
              }),
          IconButton(icon: Icon(Icons.more_vert), tooltip: "更多选项", onPressed: () {})
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    Map<String, Object> creator = playlist.creator;

    return DetailHeader(
        commentCount: playlist.commentCount,
        shareCount: playlist.shareCount,
        onCommentTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CommentPage(
              threadId:
                  CommentThreadId(playlist.id, CommentType.playlist, payload: CommentThreadPayload.playlist(playlist)),
            );
          }));
        },
        onSelectionTap: () async {
          if (musicList == null) {
            showSimpleNotification(Text("歌曲未加载,请加载后再试"));
          } else {
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
              return PlaylistSelectionPage(
                  list: musicList,
                  onDelete: (selected) async {
                    return neteaseRepository.playlistTracksEdit(
                        PlaylistOperation.remove, playlist.id, selected.map((m) => m.id).toList());
                  });
            }));
          }
        },
        onShareTap: () => notImplemented(context),
        content: Container(
          height: 146,
          padding: EdgeInsets.only(top: 20),
          child: Row(
            children: <Widget>[
              SizedBox(width: 16),
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  child: Stack(
                    children: <Widget>[
                      Hero(
                        tag: playlist.heroTag,
                        child: Image(fit: BoxFit.cover, image: CachedImage(playlist.coverUrl)),
                      ),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
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
                              Icon(Icons.headset, color: Theme.of(context).primaryIconTheme.color, size: 12),
                              Text(getFormattedNumber(playlist.playCount),
                                  style: Theme.of(context).primaryTextTheme.bodyText2.copyWith(fontSize: 11))
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
                      style: Theme.of(context).primaryTextTheme.headline6.copyWith(fontSize: 17),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return UserDetailPage(userId: creator['userId']);
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: ClipOval(
                                child: Image(image: CachedImage(creator["avatarUrl"])),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(left: 4)),
                            Text(
                              creator["nickname"],
                              style: Theme.of(context).primaryTextTheme.bodyText2,
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
