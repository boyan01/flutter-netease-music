import 'package:flutter/material.dart';
import 'package:quiet/pages/page_playlist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/part/part_music_list_provider.dart';
import 'package:quiet/repository/netease.dart';

class MainCloudPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CloudPageState();
}

class CloudPageState extends State<MainCloudPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _NavigationLine(),
        _Header("推荐歌单", () {}),
        _SectionPlaylist(),
        _Header("最新音乐", () {}),
        _SectionNewSongs(),
      ],
    );
  }
}

class _NavigationLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _ItemNavigator(Icons.radio, "私人FM", () {}),
          _ItemNavigator(Icons.today, "每日推荐", () {
            Navigator.pushNamed(context, ROUTE_DAILY);
          }),
          _ItemNavigator(Icons.show_chart, "排行榜", () {
            Navigator.pushNamed(context, ROUTE_LEADERBOARD);
          }),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 8)),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .subhead
                .copyWith(fontWeight: FontWeight.w800),
          ),
          Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  _Header(this.text, this.onTap);
}

class _ItemNavigator extends StatelessWidget {
  final IconData icon;

  final String text;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            children: <Widget>[
              ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  color: Theme.of(context).primaryColor,
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryIconTheme.color,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 8)),
              Text(text),
            ],
          ),
        ));
  }

  _ItemNavigator(this.icon, this.text, this.onTap);
}

class _SectionPlaylist extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PlaylistSectionState();
}

class _PlaylistSectionState extends State<_SectionPlaylist> {
  List<Map<String, Object>> list;

  @override
  void initState() {
    super.initState();
    neteaseRepository.personalizedPlaylist(limit: 6).then((result) {
      if (result["code"] == 200) {
        setState(() {
          list = (result["result"] as List).cast();
          debugPrint("result :$result");
        });
      } else {
        debugPrint(" personalizedPlaylist falied with ${result["code"]}");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int i = 0;
    List<Widget> widgets = list?.map((e) {
      return _buildPlaylistItem(context, i++);
    })?.toList();

    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 10 / 14,
      children: widgets ?? [],
    );
  }

  Widget _buildPlaylistItem(BuildContext context, int index) {
    Map<String, Object> playlist = list == null ? null : list[index];

    if (playlist == null) {
      return null;
    }

    GestureLongPressCallback onLongPress;

    String copyWrite = playlist["copywriter"];
    if (copyWrite != null && copyWrite.isNotEmpty) {
      onLongPress = () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                  playlist["copywriter"],
                  style: Theme.of(context).textTheme.body2,
                ),
              );
            });
      };
    }

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PagePlaylistDetail(
            playlist["id"],
          );
        }));
      },
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          children: <Widget>[
            SizedBox(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: Image(
                  image: NeteaseImage(playlist["picUrl"]),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 4)),
            Text(
              playlist["name"],
              maxLines: 2,
              style: Theme.of(context)
                  .textTheme
                  .body2
                  .copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionNewSongs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewSongState();
}

class _NewSongState extends State<_SectionNewSongs> {
  SongTileProvider songTileProvider;

  @override
  void initState() {
    super.initState();
    neteaseRepository.personalizedNewSong().then((result) {
      if (result["code"] == 200) {
        setState(() {
          List<Music> songs = (result["result"] as List)
              .cast<Map>()
              .map(_mapJsonToMusic)
              .toList();
          songTileProvider = SongTileProvider("playlist_main_newsong", songs);
        });
      }
    });
  }

  Music _mapJsonToMusic(Map json) {
    Map<String, Object> song = json["song"];
    return mapJsonToMusic(song);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (songTileProvider != null) {
      for (int i = 1; i <= songTileProvider.musics.length; i++) {
        widgets.add(songTileProvider.buildWidget(i, context));
      }
    }
    return Column(
      children: widgets,
    );
  }
}
