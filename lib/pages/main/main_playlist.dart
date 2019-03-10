import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/page_playlist_edit.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:quiet/repository/netease_image.dart';

///the first page display in page_main
class MainPlaylistPage extends StatefulWidget {
  @override
  createState() => _MainPlaylistState();
}

class _MainPlaylistState extends State<MainPlaylistPage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<RefreshIndicatorState> _indicatorKey = GlobalKey();

  GlobalKey<LoaderState> _loaderKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final userId = LoginState.of(context).userId;

    Widget widget;

    if (!LoginState.of(context).isLogin) {
      widget = _PinnedHeader();
    } else {
      widget = RefreshIndicator(
        key: _indicatorKey,
        onRefresh: () => Future.wait([
              _loaderKey.currentState.refresh(),
              Counter.refresh(context),
            ]),
        child: Loader(
            key: _loaderKey,
            initialData: neteaseLocalData.getUserPlaylist(userId),
            loadTask: () => neteaseRepository.userPlaylist(userId),
            resultVerify: simpleLoaderResultVerify((v) => v != null),
            loadingBuilder: (context) {
              _indicatorKey.currentState.show();
              return ListView(children: [
                _PinnedHeader(),
              ]);
            },
            failedWidgetBuilder: (context, result, msg) {
              return ListView(children: [
                _PinnedHeader(),
                Loader.buildSimpleFailedWidget(context, result, msg),
              ]);
            },
            builder: (context, result) {
              final created =
                  result.where((p) => p.creator["userId"] == userId).toList();
              final subscribed =
                  result.where((p) => p.creator["userId"] != userId).toList();
              return ListView(children: [
                _PinnedHeader(),
                _ExpansionPlaylistGroup.fromPlaylist("创建的歌单", created),
                _ExpansionPlaylistGroup.fromPlaylist("收藏的歌单", subscribed)
              ]);
            }),
      );
    }
    return widget;
  }

  @override
  bool get wantKeepAlive => true;
}

class _PinnedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LoginState.of(context).isLogin
            ? null
            : DividerWrapper(
                child: ListTile(
                    title: Text("当前未登录，点击登录!"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, "/login");
                    }),
              ),
        DividerWrapper(
            indent: 16,
            child: ListTile(
              leading: Icon(
                Icons.schedule,
                color: Theme.of(context).primaryColor,
              ),
              title: Text("最近播放"),
              onTap: () {
                notImplemented(context);
              },
            )),
        DividerWrapper(
          indent: 16,
          child: ListTile(
              leading: Icon(
                Icons.file_download,
                color: Theme.of(context).primaryColor,
              ),
              title: Text("下载管理"),
              onTap: () {
                Navigator.pushNamed(context, ROUTE_DOWNLOADS);
              }),
        ),
        DividerWrapper(
            indent: 16,
            child: ListTile(
              leading: Icon(
                Icons.cast,
                color: Theme.of(context).primaryColor,
              ),
              title: Text.rich(TextSpan(children: [
                TextSpan(text: '我的电台 '),
                TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    text:
                        '(${Counter.of(context).djRadioCount + Counter.of(context).createDjRadioCount})'),
              ])),
              onTap: () {
                Navigator.pushNamed(context, ROUTE_MY_DJ);
              },
            )),
        DividerWrapper(
            indent: 16,
            child: ListTile(
              leading: Icon(
                Icons.library_music,
                color: Theme.of(context).primaryColor,
              ),
              title: Text.rich(TextSpan(children: [
                TextSpan(text: '我的收藏 '),
                TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    text:
                        '(${Counter.of(context).mvCount + Counter.of(context).artistCount})'),
              ])),
              onTap: () {
                Navigator.pushNamed(context, ROUTE_MY_COLLECTION);
              },
            )),
      ]..removeWhere((v) => v == null),
    );
  }
}

class _ExpansionPlaylistGroup extends StatefulWidget {
  _ExpansionPlaylistGroup(this.title, this.children);

  _ExpansionPlaylistGroup.fromPlaylist(String title, List<PlaylistDetail> list)
      : this(title, list.map((p) => _ItemPlaylist(playlist: p)).toList());

  final String title;

  final List<Widget> children;

  @override
  _ExpansionPlaylistGroupState createState() => _ExpansionPlaylistGroupState();
}

class _ExpansionPlaylistGroupState extends State<_ExpansionPlaylistGroup>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _quarterTween =
      Tween<double>(begin: 0.0, end: 0.25);

  AnimationController _controller;

  Animation<double> _iconTurns;
  Animation<double> _heightFactor;

  bool _expanded;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _iconTurns = _controller.drive(_quarterTween.chain(_easeInTween));
    _heightFactor = _controller.drive(_easeInTween);

    _expanded = PageStorage.of(context)?.readState(context) ?? true;
    if (_expanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((_) {
          if (mounted) {
            setState(() {}); //Rebuild without widget.children.
          }
        });
      }
      PageStorage.of(context)?.writeState(context, _expanded);
    });
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildTitle(context),
        ClipRect(
          child: Align(
            heightFactor: _heightFactor.value,
            child: child,
          ),
        )
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    final color = Theme.of(context).textTheme.caption.color;
    return Container(
      color: const Color.fromARGB(255, 243, 243, 243),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: InkWell(
        onTap: _handleTap,
        child: Row(
          children: <Widget>[
            RotationTransition(
                turns: _iconTurns,
                child: Icon(
                  Icons.chevron_right,
                  color: color,
                )),
            SizedBox(width: 4),
            Text('${widget.title}(${widget.children.length})',
                style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_expanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}

class _ItemPlaylist extends StatelessWidget {
  const _ItemPlaylist({Key key, @required this.playlist}) : super(key: key);

  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PlaylistDetailPage(playlist.id, playlist: playlist)));
      },
      child: Container(
        height: 60,
        child: Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 8)),
            Hero(
              tag: playlist.heroTag,
              child: SizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: FadeInImage(
                    placeholder: AssetImage("assets/playlist_playlist.9.png"),
                    image: NeteaseImage(playlist.coverUrl),
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    fit: BoxFit.cover,
                  ),
                ),
                height: 52,
                width: 52,
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 8)),
            Expanded(
                child: Column(
              children: <Widget>[
                Expanded(
                    child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Spacer(),
                          Text(
                            playlist.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.body1,
                          ),
                          Padding(padding: EdgeInsets.only(top: 4)),
                          Text("${playlist.trackCount}首",
                              style: Theme.of(context).textTheme.caption),
                          Spacer(),
                        ],
                      ),
                    ),
                    PopupMenuButton<PlaylistOp>(
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                              child: Text("下载"), value: PlaylistOp.download),
                          PopupMenuItem(
                              child: Text("分享"), value: PlaylistOp.share),
                          PopupMenuItem(
                              child: Text("编辑歌单信息"), value: PlaylistOp.edit),
                          PopupMenuItem(
                              child: Text("删除"), value: PlaylistOp.delete),
                        ];
                      },
                      onSelected: (op) {
                        switch (op) {
                          case PlaylistOp.delete:
                          case PlaylistOp.share:
                          case PlaylistOp.download:
                            showSimpleNotification(
                                context, Text("Not implemented"),
                                background: Theme.of(context).errorColor);
                            break;
                          case PlaylistOp.edit:
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return PlaylistEditPage(playlist);
                            }));
                            break;
                        }
                      },
                      icon: Icon(Icons.more_vert),
                    )
                  ],
                )),
                Divider(height: 0),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

enum PlaylistOp { edit, share, download, delete }
