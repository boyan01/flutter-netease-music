import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:url_launcher/url_launcher.dart';

///每日推荐歌曲页面
///NOTE：需要登陆
class DailyPlaylistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BoxWithBottomPlayerController(
        Loader<Map<String, Object>>(
            loadTask: () => neteaseRepository.recommendSongs(),
            resultVerify: neteaseRepository.responseVerify,
            builder: (context, result) {
              final list = (result["recommend"] as List)
                  .cast<Map>()
                  .map(mapJsonToMusic)
                  .toList();
              return MusicList(
                  token: 'playlist_daily_recommend',
                  musics: list,
                  trailingBuilder: MusicList.defaultTrailingBuilder,
                  leadingBuilder: MusicList.coverLeadingBuilder,
                  onMusicTap: MusicList.defaultOnTap,
                  child: _DailyMusicList());
            }),
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
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            title: Text('每日推荐'),
            titleSpacing: 0,
            forceElevated: innerBoxIsScrolled,
            elevation: 0,
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.help_outline),
                  onPressed: () {
                    launch("http://music.163.com/m/topic/19193112",
                        forceWebView: true);
                  })
            ],
            flexibleSpace: Container(
              padding: EdgeInsets.only(bottom: 50, top: kToolbarHeight),
              child: SafeArea(child: _HeaderContent()),
            ),
            expandedHeight: 232 - MediaQuery.of(context).padding.top,
            pinned: true,
            bottom: MusicListHeader(MusicList.of(context).musics.length),
          ),
        ];
      },
      body: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView.builder(
            itemCount: MusicList.of(context).musics.length,
            itemBuilder: (context, index) {
              return MusicTile(MusicList.of(context).musics[index]);
            }),
      ),
    );
  }
}

///每日推荐 Header 区域内容
class _HeaderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    final textTheme = Theme.of(context).primaryTextTheme;
    return DefaultTextStyle(
      maxLines: 1,
      style: textTheme.body1.copyWith(fontWeight: FontWeight.bold),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Spacer(),
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: date.day.toString().padLeft(2, '0'),
                  style: TextStyle(fontSize: 23)),
              TextSpan(text: ' / '),
              TextSpan(text: date.month.toString().padLeft(2, '0')),
            ])),
            SizedBox(height: 4),
            Text(
              '根据你的音乐口味，为你推荐好音乐',
              style: textTheme.caption,
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
