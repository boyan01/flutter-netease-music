// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:quiet/navigation/mobile/artists/page_artist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository.dart';
import 'package:quiet/repository/netease.dart';

class ArtistsResultSection extends StatefulWidget {
  const ArtistsResultSection({Key? key, this.query}) : super(key: key);
  final String? query;

  @override
  _ArtistsResultSectionState createState() => _ArtistsResultSectionState();
}

class _ArtistsResultSectionState extends State<ArtistsResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AutoLoadMoreList(loadMore: (offset) async {
      final result = await neteaseRepository!
          .search(widget.query, SearchType.artist, offset: offset);
      if (result.isValue) {
        return Result.value(
            (result.asValue!.value["result"]["artists"] as List?)!);
      }
      return result as Result<List>;
    }, builder: (context, dynamic item) {
      return ArtistTile(map: item as Map);
    });
  }

  @override
  bool get wantKeepAlive => true;
}

///artist result list tile
class ArtistTile extends StatelessWidget {
  const ArtistTile({Key? key, required this.map}) : super(key: key);
  final Map map;

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
      child: SizedBox(
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
            const Padding(padding: EdgeInsets.only(left: 8)),
            Expanded(
                child: Column(
              children: [
                Expanded(
                    child: Row(
                  children: [
                    Expanded(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(map["name"]))),
                    if (map["accountId"] != null)
                      Row(children: <Widget>[
                        const Icon(
                          Icons.person,
                          size: 16,
                        ),
                        const Padding(padding: EdgeInsets.only(left: 2)),
                        Text("已入驻", style: Theme.of(context).textTheme.caption)
                      ])
                  ],
                )),
                const Divider(height: 0)
              ],
            )),
            const Padding(padding: EdgeInsets.only(right: 8))
          ],
        ),
      ),
    );
  }
}
