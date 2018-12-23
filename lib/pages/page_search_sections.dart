import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/part/part_music_list_provider.dart';
import 'package:quiet/repository/netease.dart';

///song list result
class SongsResultSection extends StatefulWidget {
  const SongsResultSection({Key key, @required this.query}) : super(key: key);

  final String query;

  @override
  SongsResultSectionState createState() {
    return new SongsResultSectionState();
  }
}

class SongsResultSectionState extends State<SongsResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Loader<Map<String, dynamic>>(
        loadTask: () =>
            neteaseRepository.search(widget.query, NeteaseSearchType.song),
        resultVerify: neteaseRepository.responseVerify,
        builder: (context, result) {
          List songs = result["result"]["songs"];
          var provider = SongTileProvider("search",
              songs.cast<Map>().map((s) => mapJsonToMusic(s)).toList());
          return ListView.builder(itemBuilder: (context, index) {
            return provider.buildWidget(index + 1, context,
                leadingType: SongTileLeadingType.none, onTap: (music) {
              debugPrint("on muisc taped : $music");
            });
          });
        });
  }

  @override
  bool get wantKeepAlive => true;
}

///video list result
class VideosResultSection extends StatefulWidget {
  const VideosResultSection({Key key, @required this.query}) : super(key: key);

  final String query;

  @override
  _VideosResultSectionState createState() => _VideosResultSectionState();
}

class _VideosResultSectionState extends State<VideosResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Loader<Map<String, dynamic>>(
        loadTask: () =>
            neteaseRepository.search(widget.query, NeteaseSearchType.video),
        resultVerify: neteaseRepository.responseVerify,
        builder: (context, result) {
          List videos = result["result"]["videos"];
          return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return VideoTile(map: videos[index] as Map<String, dynamic>);
              });
        });
  }

  @override
  bool get wantKeepAlive => true;
}

///item for video
class VideoTile extends StatelessWidget {
  const VideoTile({Key key, this.map})
      : assert(map != null),
        super(key: key);

  final Map<String, dynamic> map;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint("on tag : ${map["vid"]}");
      },
      child: Container(
        height: 72,
        child: Row(
          children: <Widget>[
            Container(
              height: 72,
              width: 72 * 1.6,
              padding: EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image(
                  image: NetworkImage(map["coverUrl"]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 8)),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(map["title"],
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(
                      "${getTimeStamp(map["durationms"])} by ${(map["creator"] as List).cast<Map>().map((creator) {
                        return creator["userName"];
                      }).join("/")}",
                      style: Theme.of(context).textTheme.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )),
                Divider(
                  height: 0,
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}

class ArtistsResultSection extends StatefulWidget {
  final String query;

  const ArtistsResultSection({Key key, this.query}) : super(key: key);

  @override
  _ArtistsResultSectionState createState() => _ArtistsResultSectionState();
}

class _ArtistsResultSectionState extends State<ArtistsResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Loader<Map<String, dynamic>>(
        loadTask: () =>
            neteaseRepository.search(widget.query, NeteaseSearchType.artist),
        resultVerify: neteaseRepository.responseVerify,
        builder: (context, result) {
          List artists = result["result"]["artists"];
          return ListView.separated(
            itemCount: artists.length,
            itemBuilder: (context, index) {
              return ArtistTile(map: artists[index] as Map);
            },
            separatorBuilder: (context, index) {
              return Divider(
                indent: 56,
                height: 0,
              );
            },
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class AlbumsResultSection extends StatefulWidget {
  final String query;

  const AlbumsResultSection({Key key, this.query}) : super(key: key);

  @override
  _AlbumsResultSectionState createState() => _AlbumsResultSectionState();
}

class _AlbumsResultSectionState extends State<AlbumsResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Loader<Map<String, dynamic>>(
        loadTask: () =>
            neteaseRepository.search(widget.query, NeteaseSearchType.album),
        resultVerify: neteaseRepository.responseVerify,
        builder: (context, result) {
          List albums = result["result"]["albums"];
          return ListView.builder(
              itemCount: albums.length,
              itemBuilder: (context, index) {
                Map album = albums[index] as Map;

                String subTitle = (album["artists"] as List)
                    .cast<Map>()
                    .map((ar) => ar["name"])
                    .toList()
                    .join("/");
                if (album["containedSong"] == null ||
                    (album["containedSong"] as String).isEmpty) {
                  String publishTime = DateFormat("y.M.d").format(
                      DateTime.fromMillisecondsSinceEpoch(
                          album["publishTime"]));
                  subTitle = subTitle + " $publishTime";
                } else {
                  subTitle = subTitle + " 包含单曲: ${album["containedSong"]}";
                }
                return ListTile(
                  leading: Image(
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      image: NeteaseImage(album["picUrl"])),
                  title: Text(album["name"],
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(subTitle,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    debugPrint("on tap ${album["id"]} ");
                  },
                );
              });
        });
  }
}

class PlaylistResultSection extends StatefulWidget {
  final String query;

  const PlaylistResultSection({Key key, this.query}) : super(key: key);

  @override
  _PlaylistResultSectionState createState() => _PlaylistResultSectionState();
}

class _PlaylistResultSectionState extends State<PlaylistResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Loader(
        loadTask: () =>
            neteaseRepository.search(widget.query, NeteaseSearchType.playlist),
        resultVerify: neteaseRepository.responseVerify,
        builder: (context, result) {
          List list = result["result"]["playlists"];
          return ListView.builder(
            itemBuilder: (context, index) {
              Map item = list[index] as Map;
              String subTitle =
                  "${item["trackCount"]}首 by ${item["creator"]["nickname"]},"
                  "播放${getFormattedNumber(item["playCount"])}次";
              return ListTile(
                title: Text(item["name"], maxLines: 1),
                leading: Image(
                    image: NeteaseImage(item["coverImgUrl"]),
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40),
                subtitle: Text(
                  subTitle,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.caption,
                ),
              );
            },
            itemCount: list.length,
          );
        });
  }
}

///artist result list tile
class ArtistTile extends StatelessWidget {
  final Map map;

  const ArtistTile({Key key, @required this.map})
      : assert(map != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint("on tap : ${map["id"]}");
      },
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 8),
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image(
                  image: NeteaseImage(map["img1v1Url"]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 8)),
            Expanded(
                child: Align(
              alignment: Alignment.centerLeft,
              child: Text(map["name"]),
            )),
            map["accountId"] == null
                ? null
                : Row(
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        size: 16,
                      ),
                      Padding(padding: EdgeInsets.only(left: 2)),
                      Text("已入驻", style: Theme.of(context).textTheme.caption)
                    ],
                  )
          ]..removeWhere((v) => v == null),
        ),
      ),
    );
  }
}
