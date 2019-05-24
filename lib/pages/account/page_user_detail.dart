import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/material/flexible_app_bar.dart';
import 'package:quiet/material/tabs.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import 'user_detail_bean.dart';

///用户详情页
class UserDetailPage extends StatelessWidget {
  ///用户ID
  final int userId;

  const UserDetailPage({Key key,@required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Loader<Map>(
      initialData: neteaseLocalData.get('user_detail_$userId'),
      loadTask: () => neteaseRepository.getUserDetail(userId),
      builder: (BuildContext context, Map result) {
        neteaseLocalData['user_detail_$userId'] = result;
        final user = UserDetail.fromJsonMap(result.cast());
        return _DetailPage(user: user);
      },
    );
  }
}

class _DetailPage extends StatelessWidget {
  final UserDetail user;

  const _DetailPage({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BoxWithBottomPlayerController(DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, _) {
                return [_UserDetailAppBar(user)];
              },
              body: TabBarView(children: <Widget>[
                Container(),
                Container(),
                Container(),
              ]),
            ))));
  }
}

///伸缩自如的AppBar
class _UserDetailAppBar extends StatelessWidget {
  final UserDetail user;

  const _UserDetailAppBar(this.user, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 330,
      flexibleSpace: FlexibleDetailBar(
        background: FlexShadowBackground(
          child: Image(
              height: 300,
              width: 300,
              image: NeteaseImage(user.profile.backgroundUrl)),
        ),
        content: Column(children: <Widget>[]),
      ),
      elevation: 0,
      forceElevated: false,
      bottom: RoundedTabBar(
        tabs: <Widget>[
          Tab(text: '音乐(${user.profile.playlistCount})'),
          Tab(text: '动态(${user.profile.eventCount})'),
          Tab(text: '关于TA'),
        ],
      ),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.more_vert,
                color: Theme.of(context).primaryIconTheme.color),
            onPressed: () {
              //TODO
              toast(context, 'todo');
            })
      ],
    );
  }
}
