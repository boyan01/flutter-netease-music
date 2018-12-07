import 'dart:ui';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:url_launcher/url_launcher.dart';

///每日推荐歌曲
class DailyPlaylistPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DailyPlaylistState();
}

class _DailyPlaylistState extends State<DailyPlaylistPage> {
  List<Music> list;

  CancelableOperation task;

  @override
  void initState() {
    super.initState();
    task = CancelableOperation.fromFuture(neteaseRepository.recommendSongs())
      ..value.then((result) {
        if (result["code"] == 200) {
          setState(() {
            list = (result["recommend"] as List)
                .cast<Map>()
                .map(mapJsonToMusic)
                .toList();
          });
        }
      });
  }

  @override
  void dispose() {
    task.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (list == null) {
      body = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      body = _DailyList(SongTileProvider("playlist_daily_recommend", list));
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
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
      body: body,
    );
  }
}

class _DailyList extends StatelessWidget {
  _DailyList(this.songTileProvider);

  final SongTileProvider songTileProvider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: songTileProvider.musics.length + 2,
        itemBuilder: (context, int index) {
          if (index == 0) {
            return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("assets/daily_list_background.webp"))),
              height: 180,
              child: Container(
                padding: EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Spacer(),
                    Container(
                      height: 80,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              size: 80,
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
                                      .copyWith(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w900),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 12)),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.bubble_chart,
                          color:
                              Theme.of(context).primaryTextTheme.caption.color,
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
          } else {
            return songTileProvider.buildWidget(index - 1, context);
          }
        });
  }
}
