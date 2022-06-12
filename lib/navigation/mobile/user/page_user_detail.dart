import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../component/netease/netease_loader.dart';
import '../../../extension.dart';
import '../../../material/flexible_app_bar.dart';
import '../../../material/images.dart';
import '../../../material/tabs.dart';
import '../../../providers/user_detail_provider.dart';
import '../../../repository.dart';
import '../home/playlist_tile.dart';

part 'tab_about.dart';
part 'tab_events.dart';
part 'tab_music.dart';

///用户详情页
class UserDetailPage extends ConsumerWidget {
  const UserDetailPage({Key? key, required this.userId}) : super(key: key);

  ///用户ID
  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(userDetailProvider(userId).logErrorOnDebug());
    return snapshot.when(
      data: (user) => _DetailPage(user: user),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(userId.toString())),
        body: Center(
          child: Text(context.formattedError(error)),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: Text(userId.toString())),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({
    Key? key,
    required this.user,
  }) : super(key: key);
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) {
              return [
                SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                    sliver: _UserDetailAppBar(user))
              ];
            },
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: kToolbarHeight + kTextTabBarHeight),
                child: TabBarView(children: <Widget>[
                  TabMusic(user),
                  TabEvents(),
                  TabAbout(user),
                ]),
              ),
            ),
          )),
    );
  }
}

///伸缩自如的AppBar
class _UserDetailAppBar extends StatelessWidget {
  const _UserDetailAppBar(this.user, {Key? key}) : super(key: key);
  final User user;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      leading: Container(),
      expandedHeight: 330,
      flexibleSpace: FlexibleDetailBar(
        background: FlexShadowBackground(
          child: Image(
              height: 300,
              width: 300,
              fit: BoxFit.cover,
              image: CachedImage(user.backgroundUrl)),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Spacer(),
                Row(
                  children: <Widget>[
                    RoundedImage(user.avatarUrl, size: 60),
                  ],
                ),
                const SizedBox(height: 10),
                Text(user.nickname,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w400)),
                const SizedBox(height: 6),
                Row(children: <Widget>[
                  InkWell(
                      onTap: () {
                        toast('关注');
                      },
                      child: Text('关注:${user.followers}')),
                  const VerticalDivider(),
                  InkWell(
                    onTap: () {
                      toast('粉丝');
                    },
                    child: Text('粉丝:${user.followedUsers}'),
                  ),
                ]),
                const SizedBox(height: 16),
              ]),
        ),
        builder: (context, t) {
          return AppBar(
            title: Text(t > 0.5 ? user.nickname : ''),
            titleSpacing: 0,
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.more_vert,
                      color: Theme.of(context).primaryIconTheme.color),
                  onPressed: () {
                    //TODO
                    toast('todo');
                  })
            ],
          );
        },
      ),
      elevation: 0,
      bottom: RoundedTabBar(
        tabs: <Widget>[
          Tab(text: '音乐(${user.playlistCount})'),
          Tab(text: '动态(${user.eventCount})'),
          const Tab(text: '关于TA'),
        ],
      ),
    );
  }
}
