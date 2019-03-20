import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:url_launcher/url_launcher.dart';

///每日推荐歌曲
class DailyPlaylistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        titleSpacing: 0,
        title: const Text("每日推荐"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                launch("http://music.163.com/m/topic/19193112",
                    forceWebView: true);
              })
        ],
      ),
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
                  child: ListView.builder(itemBuilder: (context, index) {
                    if (index == 0) {
                      return MusicListHeader(list.length);
                    } else {
                      return MusicTile(list[index - 1]);
                    }
                  }));
            }),
      ),
    );
  }
}

///header of daily recommend list
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/daily_list_background.webp"))),
      height: 150,
      child: Container(
        padding: EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Spacer(),
            _Calendar(),
            Padding(padding: EdgeInsets.only(top: 12)),
            Row(
              children: <Widget>[
                Icon(
                  Icons.bubble_chart,
                  color: Theme.of(context).primaryTextTheme.caption.color,
                ),
                Text(
                  "自动生成，每天6:00更新",
                  style: Theme.of(context).primaryTextTheme.caption,
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 12))
          ],
        ),
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: <Widget>[
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            Container(
              child: Align(
                alignment: Alignment(0, 0.5),
                child: Text(
                  DateTime.now().day.toString(),
                  style: Theme.of(context)
                      .primaryTextTheme
                      .body1
                      .copyWith(fontSize: 28, fontWeight: FontWeight.w400),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
