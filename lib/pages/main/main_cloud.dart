import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/pages/playlist/page_playlist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

class MainCloudPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CloudPageState();
}

class CloudPageState extends State<MainCloudPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          _ItemNavigator(Icons.radio, "私人FM", () {
            toast("未接入");
          }),
          _ItemNavigator(Icons.today, "每日推荐", () {
            context.secondaryNavigator.pushNamed(pageDaily);
          }),
          _ItemNavigator(Icons.show_chart, "排行榜", () {
            context.secondaryNavigator.pushNamed(pageLeaderboard);
          }),
        ],
      ),
    );
  }
}

///common header for section
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
            style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w800),
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
              Material(
                shape: CircleBorder(),
                elevation: 5,
                child: ClipOval(
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
              ),
              Padding(padding: EdgeInsets.only(top: 8)),
              Text(text),
            ],
          ),
        ));
  }

  _ItemNavigator(this.icon, this.text, this.onTap);
}

class _SectionPlaylist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Loader<Map>(
      loadTask: () => neteaseRepository.personalizedPlaylist(limit: 6),
      builder: (context, result) {
        List<Map> list = (result["result"] as List).cast();
        return LayoutBuilder(builder: (context, constraints) {
          assert(constraints.maxWidth.isFinite, "can not layout playlist item in infinite width container.");
          final parentWidth = constraints.maxWidth - 8;
          int count = /* false ? 6 : */ 3;
          double width = (parentWidth ~/ count).toDouble().clamp(80.0, 200.0);
          double spacing = (parentWidth - width * count) / (count + 1);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 + spacing),
            child: Wrap(
              spacing: spacing,
              direction: Axis.horizontal,
              children: list.map<Widget>((p) {
                return _PlayListItemView(playlist: p, width: width);
              }).toList(),
            ),
          );
        });
      },
    );
  }
}

class _PlayListItemView extends StatelessWidget {
  final Map playlist;

  final double width;

  const _PlayListItemView({
    Key key,
    @required this.playlist,
    @required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            });
      };
    }

    return InkWell(
      onTap: () {
        context.secondaryNavigator.push(MaterialPageRoute(builder: (context) {
          return PlaylistDetailPage(
            playlist["id"],
          );
        }));
      },
      onLongPress: onLongPress,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          children: <Widget>[
            Container(
              height: width,
              width: width,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: FadeInImage(
                    placeholder: AssetImage("assets/playlist_playlist.9.png"),
                    image: CachedImage(playlist["picUrl"]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 4)),
            Text(
              playlist["name"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionNewSongs extends StatelessWidget {
  Music _mapJsonToMusic(Map json) {
    Map<String, Object> song = json["song"];
    return mapJsonToMusic(song);
  }

  @override
  Widget build(BuildContext context) {
    return Loader<Map>(
      loadTask: () => neteaseRepository.personalizedNewSong(),
      builder: (context, result) {
        List<Music> songs = (result["result"] as List).cast<Map>().map(_mapJsonToMusic).toList();
        return MusicTileConfiguration(
          musics: songs,
          token: 'playlist_main_newsong',
          onMusicTap: MusicTileConfiguration.defaultOnTap,
          leadingBuilder: MusicTileConfiguration.indexedLeadingBuilder,
          trailingBuilder: MusicTileConfiguration.defaultTrailingBuilder,
          child: Column(
            children: songs.map((m) => MusicTile(m)).toList(),
          ),
        );
      },
    );
  }
}
