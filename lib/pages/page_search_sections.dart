import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/part/part_music_list_provider.dart';
import 'package:quiet/part/part_stated_page.dart';
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
          return ListView.builder(
            itemCount: artists.length,
            itemBuilder: (context, index) {
              return ArtistTile(map: artists[index] as Map);
            },
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

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
                  image: NetworkImage(map["picUrl"]),
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
          ],
        ),
      ),
    );
  }
}
