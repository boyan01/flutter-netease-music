import 'package:flutter/material.dart';
import 'package:quiet/pages/artists/page_artist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

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
    super.build(context);
    return AutoLoadMoreList(loadMore: (offset) async {
      final result = await neteaseRepository
          .search(widget.query, NeteaseSearchType.artist, offset: offset);
      if (result.isValue) {
        return Result.value(result.asValue.value["result"]["artists"] as List);
      }
      return result as Result<List>;
    }, builder: (context, item) {
      return ArtistTile(map: item as Map);
    });
  }

  @override
  bool get wantKeepAlive => true;
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
      onTap: map["id"] == 0
          ? null
          : () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ArtistDetailPage(artistId: map["id"]);
              }));
            },
      child: Container(
        height: 64,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image(
                    image: CachedImage(map["img1v1Url"]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 8)),
            Expanded(
                child: Column(
              children: <Widget>[
                Expanded(
                    child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(map["name"]))),
                    map["accountId"] == null
                        ? null
                        : Row(children: <Widget>[
                            Icon(
                              Icons.person,
                              size: 16,
                            ),
                            Padding(padding: EdgeInsets.only(left: 2)),
                            Text("已入驻",
                                style: Theme.of(context).textTheme.caption)
                          ])
                  ]..removeWhere((v) => v == null),
                )),
                Divider(height: 0)
              ],
            )),
            Padding(padding: EdgeInsets.only(right: 8))
          ],
        ),
      ),
    );
  }
}
