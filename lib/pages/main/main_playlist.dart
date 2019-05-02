import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/material/button.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/page_playlist_edit.dart';
import 'package:quiet/pages/record/page_record.dart';
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
    super.build(context);
    final userId = UserAccount.of(context).userId;

    Widget widget;

    if (!UserAccount.of(context).isLogin) {
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
                _ExpansionPlaylistGroup.fromPlaylist(
                  "创建的歌单",
                  created,
                  onAddClick: () {
                    toast(context, 'add: todo');
                  },
                  onMoreClick: () {
                    toast(context, 'more: todo');
                  },
                ),
                _ExpansionPlaylistGroup.fromPlaylist(
                  "收藏的歌单",
                  subscribed,
                  onMoreClick: () {
                    toast(context, 'more: todo');
                  },
                )
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
        UserAccount.of(context).isLogin
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
              title: Text('播放记录'),
              onTap: () {
                if (UserAccount.of(context, rebuildOnChange: false).isLogin) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return RecordPage(
                        uid: UserAccount.of(context, rebuildOnChange: false)
                            .userId);
                  }));
                } else {
                  //todo show login dialog
                }
              },
            )),
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
        ListTile(
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
        ),
        Container(height: 8, color: Color(0xfff5f5f5))
      ]..removeWhere((v) => v == null),
    );
  }
}

class _ExpansionPlaylistGroup extends StatefulWidget {
  _ExpansionPlaylistGroup(this.title, this.children,
      {this.onMoreClick, this.onAddClick});

  _ExpansionPlaylistGroup.fromPlaylist(String title, List<PlaylistDetail> list,
      {@required VoidCallback onMoreClick, VoidCallback onAddClick})
      : this(title, list.map((p) => _ItemPlaylist(playlist: p)).toList(),
            onAddClick: onAddClick, onMoreClick: onMoreClick);

  final String title;

  final List<Widget> children;

  //icon more click callback
  final VoidCallback onMoreClick;

  //icon add click callback. if null, hide
  final VoidCallback onAddClick;

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
    return InkWell(
      onTap: _handleTap,
      child: Container(
        height: 40,
        child: Row(
          children: <Widget>[
            RotationTransition(
                turns: _iconTurns,
                child: Icon(
                  Icons.chevron_right,
                  size: 25,
                  color: Color(0xff4d4d4d),
                )),
            SizedBox(width: 4),
            Text('${widget.title}',
                style: Theme.of(context)
                    .textTheme
                    .title
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(width: 4),
            Text(
              '(${widget.children.length})',
              style: Theme.of(context).textTheme.caption,
            ),
            Spacer(),
            widget.onAddClick == null
                ? Container()
                : IconButton2(
                    iconSize: 24,
                    padding: EdgeInsets.all(4),
                    icon: Icon(Icons.add),
                    onPressed: widget.onAddClick),
            IconButton2(
                padding: EdgeInsets.all(4),
                icon: Icon(Icons.more_vert),
                onPressed: widget.onMoreClick),
            SizedBox(width: 8),
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
            Padding(padding: EdgeInsets.only(left: 16)),
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
                height: 50,
                width: 50,
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(),
                  Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15),
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
                  PopupMenuItem(child: Text("分享"), value: PlaylistOp.share),
                  PopupMenuItem(child: Text("编辑歌单信息"), value: PlaylistOp.edit),
                  PopupMenuItem(child: Text("删除"), value: PlaylistOp.delete),
                ];
              },
              onSelected: (op) {
                switch (op) {
                  case PlaylistOp.delete:
                  case PlaylistOp.share:
                    showSimpleNotification(context, Text("Not implemented"),
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
            ),
          ],
        ),
      ),
    );
  }
}

enum PlaylistOp { edit, share, delete }
