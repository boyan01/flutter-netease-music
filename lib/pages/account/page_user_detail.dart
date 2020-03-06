import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/material/flexible_app_bar.dart';
import 'package:quiet/material/images.dart';
import 'package:quiet/material/tabs.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/main/playlist_tile.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import 'user_detail_bean.dart';

part 'tab_about.dart';
part 'tab_events.dart';
part 'tab_music.dart';

///用户详情页
class UserDetailPage extends StatelessWidget {
  ///用户ID
  final int userId;

  const UserDetailPage({Key key, @required this.userId}) : super(key: key);

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
                return [
                  SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context), sliver: _UserDetailAppBar(user))
                ];
              },
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight + kTextTabBarHeight),
                  child: TabBarView(children: <Widget>[
                    TabMusic(user.profile),
                    TabEvents(),
                    TabAbout(user),
                  ]),
                ),
              ),
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
      leading: Container(),
      expandedHeight: 330,
      flexibleSpace: FlexibleDetailBar(
        background: FlexShadowBackground(
          child: Image(height: 300, width: 300, fit: BoxFit.cover, image: CachedImage(user.profile.backgroundUrl)),
        ),
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Spacer(),
            Row(
              children: <Widget>[
                RoundedImage(user.profile.avatarUrl, size: 60),
              ],
            ),
            SizedBox(height: 10),
            Text(user.profile.nickname, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400)),
            SizedBox(height: 6),
            Row(children: <Widget>[
              InkWell(
                  child: Text('关注:${user.profile.follows}'),
                  onTap: () {
                    toast('关注');
                  }),
              VerticalDivider(),
              InkWell(
                child: Text('粉丝:${user.profile.followeds}'),
                onTap: () {
                  toast('粉丝');
                },
              ),
            ]),
            SizedBox(height: 16),
          ]),
        ),
        builder: (context, t) {
          return AppBar(
            title: Text(t > 0.5 ? user.profile.nickname : ''),
            titleSpacing: 0,
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.more_vert, color: Theme.of(context).primaryIconTheme.color),
                  onPressed: () {
                    //TODO
                    toast('todo');
                  })
            ],
          );
        },
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
    );
  }
}
