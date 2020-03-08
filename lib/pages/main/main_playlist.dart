import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/material/button.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/record/page_record.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import 'playlist_tile.dart';

///the first page display in page_main
class MainPlaylistPage extends StatefulWidget {
  @override
  createState() => _MainPlaylistState();
}

class _MainPlaylistState extends State<MainPlaylistPage> with AutomaticKeepAliveClientMixin {
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
            loadingBuilder: (context) {
              _indicatorKey.currentState.show();
              return ListView(children: [
                _PinnedHeader(),
              ]);
            },
            errorBuilder: (context, result) {
              return ListView(children: [
                _PinnedHeader(),
                Loader.buildSimpleFailedWidget(context, result),
              ]);
            },
            builder: (context, result) {
              final created = result.where((p) => p.creator["userId"] == userId).toList();
              final subscribed = result.where((p) => p.creator["userId"] != userId).toList();
              return ListView(children: [
                _PinnedHeader(),
                _ExpansionPlaylistGroup.fromPlaylist(
                  "创建的歌单",
                  created,
                  onAddClick: () {
                    toast('add: todo');
                  },
                  onMoreClick: () {
                    toast('more: todo');
                  },
                ),
                _ExpansionPlaylistGroup.fromPlaylist(
                  "收藏的歌单",
                  subscribed,
                  onMoreClick: () {
                    toast('more: todo');
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
        if (!UserAccount.of(context).isLogin)
          DividerWrapper(
            child: ListTile(
                title: Text("当前未登录，点击登录!"),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  context.rootNavigator.pushNamed(pageLogin);
                }),
          ),
        DividerWrapper(
            indent: 16,
            child: ListTile(
              leading: Icon(
                Icons.schedule,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text('播放记录'),
              onTap: () {
                if (UserAccount.of(context, rebuildOnChange: false).isLogin) {
                  context.secondaryNavigator.push(MaterialPageRoute(builder: (context) {
                    return RecordPage(uid: UserAccount.of(context, rebuildOnChange: false).userId);
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
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text.rich(TextSpan(children: [
                TextSpan(text: '我的电台 '),
                TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    text: '(${Counter.of(context).djRadioCount + Counter.of(context).createDjRadioCount})'),
              ])),
              onTap: () {
                context.secondaryNavigator.pushNamed(pageMyDj);
              },
            )),
        ListTile(
          leading: Icon(
            Icons.library_music,
            color: Theme.of(context).iconTheme.color,
          ),
          title: Text.rich(TextSpan(children: [
            TextSpan(text: '我的收藏 '),
            TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.grey),
                text: '(${Counter.of(context).mvCount + Counter.of(context).artistCount})'),
          ])),
          onTap: () {
            context.secondaryNavigator.pushNamed(ROUTE_MY_COLLECTION);
          },
        ),
        Container(height: 8, color: Theme.of(context).dividerColor)
      ]..removeWhere((v) => v == null),
    );
  }
}

class _ExpansionPlaylistGroup extends StatefulWidget {
  _ExpansionPlaylistGroup(this.title, this.children, {this.onMoreClick, this.onAddClick}) : assert(children != null);

  _ExpansionPlaylistGroup.fromPlaylist(String title, List<PlaylistDetail> list,
      {@required VoidCallback onMoreClick, VoidCallback onAddClick})
      : this(title, list.map((p) => PlaylistTile(playlist: p)).toList(),
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

class _ExpansionPlaylistGroupState extends State<_ExpansionPlaylistGroup> with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _quarterTween = Tween<double>(begin: 0.0, end: 0.25);

  AnimationController _controller;

  Animation<double> _iconTurns;
  Animation<double> _heightFactor;

  bool _expanded;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
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
                style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(width: 4),
            Text(
              '(${widget.children.length})',
              style: Theme.of(context).textTheme.caption,
            ),
            Spacer(),
            widget.onAddClick == null
                ? Container()
                : IconButton2(
                    iconSize: 24, padding: EdgeInsets.all(4), icon: Icon(Icons.add), onPressed: widget.onAddClick),
            IconButton2(padding: EdgeInsets.all(4), icon: Icon(Icons.more_vert), onPressed: widget.onMoreClick),
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
