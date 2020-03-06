import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quiet/material/flexible_app_bar.dart';
import 'package:quiet/pages/account/page_need_login.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:url_launcher/url_launcher.dart';

///每日推荐歌曲页面
///NOTE：需要登陆
class DailyPlaylistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageNeedLogin(
      builder: (context) => Scaffold(
        body: BoxWithBottomPlayerController(
          Loader<Map>(
              loadTask: () => neteaseRepository.recommendSongs(),
              builder: (context, result) {
                final list = (result["recommend"] as List).cast<Map>().map(mapJsonToMusic).toList();
                return MusicTileConfiguration(
                    token: 'playlist_daily_recommend',
                    musics: list,
                    trailingBuilder: MusicTileConfiguration.defaultTrailingBuilder,
                    leadingBuilder: MusicTileConfiguration.coverLeadingBuilder,
                    onMusicTap: MusicTileConfiguration.defaultOnTap,
                    child: _DailyMusicList());
              }),
        ),
      ),
    );
  }
}

///数据加载成功后的整体页面
///主要分为两部分：
///1. head: 包括标题 header 和播放全部 header
///2. content: 音乐列表
class _DailyMusicList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text('每日推荐'),
          titleSpacing: 0,
          forceElevated: false,
          elevation: 0,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.help_outline),
                onPressed: () {
                  launch("http://music.163.com/m/topic/19193112", forceWebView: true);
                })
          ],
          flexibleSpace: _HeaderContent(),
          expandedHeight: 232 - MediaQuery.of(context).padding.top,
          pinned: true,
          bottom: MusicListHeader(MusicTileConfiguration.of(context).musics.length),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return MusicTile(MusicTileConfiguration.of(context).musics[index]);
        }, childCount: MusicTileConfiguration.of(context).musics.length)),
      ],
    );
  }
}

///每日推荐 Header 区域内容
class _HeaderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    final textTheme = Theme.of(context).primaryTextTheme;
    return FlexibleDetailBar(
      background: Container(color: Theme.of(context).primaryColor),
      content: DefaultTextStyle(
        maxLines: 1,
        style: textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Spacer(flex: 10),
              Text.rich(TextSpan(children: [
                TextSpan(text: date.day.toString().padLeft(2, '0'), style: TextStyle(fontSize: 23)),
                TextSpan(text: ' / '),
                TextSpan(text: date.month.toString().padLeft(2, '0')),
              ])),
              SizedBox(height: 4),
              Text(
                '根据你的音乐口味，为你推荐好音乐',
                style: textTheme.caption,
              ),
              Spacer(flex: 12),
            ],
          ),
        ),
      ),
    );
  }
}
