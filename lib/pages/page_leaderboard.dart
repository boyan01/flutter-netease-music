import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:quiet/pages/page_playlist_detail.dart';
import 'package:quiet/repository/netease.dart';

///各个排行榜数据
class LeaderboardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map> data;

  CancelableOperation task;

  @override
  void initState() {
    super.initState();
    task = CancelableOperation.fromFuture(neteaseRepository.topListDetail())
      ..value.then((result) {
        if (result["code"] == 200) {
          setState(() {
            data = (result["list"] as List).cast();
          });
        } else {
          debugPrint("#topListDetail falied $result");
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
    if (data == null) {
      body = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      body = _Leaderboard(data);
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("排行榜"),
      ),
      body: body,
    );
  }
}

class _Leaderboard extends StatelessWidget {
  /// [data] 中官方榜起始位置
  static const int INDEX_OFFICIAL = 0;

  /// [data] 全球榜起始位置
  static const int INDEX_GLOBAL = 5;

  _Leaderboard(this.data);

  final List<Map> data;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    widgets.add(_ItemTitle("官方榜"));
    for (var i = 0; i < 4; i++) {
      widgets.add(_ItemLeaderboard1(data[i]));
    }
    widgets.add(_ItemTitle("全球榜"));
    widgets.add(GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 8),
        shrinkWrap: true,
        itemCount: data.length - 4,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
  _ItemTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8, left: 16, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .subhead
            .copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ItemLeaderBoard2 extends StatelessWidget {
  _ItemLeaderBoard2(this.row);

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
                    Image(image: NeteaseImage(row["coverImgUrl"])),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 24,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: const [
                              Colors.transparent,
                              Colors.black45
                            ])),
                        child: Row(
                          children: <Widget>[
                            Spacer(),
                            Text(
                              row["updateFrequency"],
                              style: Theme.of(context).primaryTextTheme.caption,
                            ),
                            Padding(padding: EdgeInsets.only(right: 4))
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
  _ItemLeaderboard1(this.row);

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
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Stack(
                  children: <Widget>[
                    Image(image: NeteaseImage(row["coverImgUrl"])),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 24,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: const [
                              Colors.transparent,
                              Colors.black45
                            ])),
                        child: Row(
                          children: <Widget>[
                            Spacer(),
                            Text(
                              row["updateFrequency"],
                              style: Theme.of(context).primaryTextTheme.caption,
                            ),
                            Padding(padding: EdgeInsets.only(right: 4))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 8)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(),
                  Text(
                    _getTrack((row["tracks"] as List)[0] as Map),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Text(
                    _getTrack((row["tracks"] as List)[1] as Map),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Text(
                    _getTrack((row["tracks"] as List)[2] as Map),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Divider(
                    height: 0,
                  ),
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
