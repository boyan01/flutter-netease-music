import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
import 'package:quiet/pages/playlist/page_playlist_detail.dart';
import 'package:quiet/repository.dart';
import 'package:quiet/repository/netease.dart';

///各个排行榜数据
class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("排行榜"),
      ),
      body: Loader<Map>(
        loadTask: () => neteaseRepository!.topListDetail(),
        builder: (context, result) {
          return _Leaderboard((result['list'] as List).cast());
        },
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard(this.data);

  final List<Map> data;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];
    widgets.add(const _ItemTitle("官方榜"));
    for (var i = 0; i < 4; i++) {
      widgets.add(_ItemLeaderboard1(data[i]));
    }
    widgets.add(const _ItemTitle("全球榜"));
    widgets.add(GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shrinkWrap: true,
        itemCount: data.length - 4,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 10 / 13.5,
            mainAxisSpacing: 4,
            crossAxisSpacing: 8),
        itemBuilder: (context, int i) {
          return _ItemLeaderBoard2(data[i + 4]);
        }));
    return ListView(
      children: widgets,
    );
  }
}

class _ItemTitle extends StatelessWidget {
  const _ItemTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 16, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ItemLeaderBoard2 extends StatelessWidget {
  const _ItemLeaderBoard2(this.row);

  final Map row;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PlaylistDetailPage(row["id"]);
        }));
      },
      child: SizedBox(
        height: 130,
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Stack(
                  children: <Widget>[
                    Image(image: CachedImage(row["coverImgUrl"])),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 24,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black45])),
                        child: Row(
                          children: <Widget>[
                            const Spacer(),
                            Text(
                              row["updateFrequency"],
                              style: Theme.of(context).primaryTextTheme.caption,
                            ),
                            const Padding(padding: EdgeInsets.only(right: 4))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Text(
              row["name"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemLeaderboard1 extends StatelessWidget {
  const _ItemLeaderboard1(this.row);

  final Map row;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PlaylistDetailPage(row["id"]);
        }));
      },
      child: Container(
        height: 130,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Stack(
                  children: <Widget>[
                    Image(image: CachedImage(row["coverImgUrl"])),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 24,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black45])),
                        child: Row(
                          children: <Widget>[
                            const Spacer(),
                            Text(
                              row["updateFrequency"],
                              style: Theme.of(context).primaryTextTheme.caption,
                            ),
                            const Padding(padding: EdgeInsets.only(right: 4))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 8)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Spacer(),
                  Text(
                    _getTrack((row["tracks"] as List)[0] as Map),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    _getTrack((row["tracks"] as List)[1] as Map),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    _getTrack((row["tracks"] as List)[2] as Map),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  const Divider(height: 0),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _getTrack(Map map) {
    return "${map["first"]} - ${map["second"]}";
  }
}
