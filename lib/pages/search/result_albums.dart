import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader/loader.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

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
    super.build(context);
    return AutoLoadMoreList<Map>(loadMore: (offset) async {
      final result = await neteaseRepository
          .search(widget.query, NeteaseSearchType.album, offset: offset);
      if (result.isError) return result as Result<List>;
      final list = result.asValue.value["result"]["albums"] as List;
      return LoadMoreResult(list?.cast<Map>() ?? const []);
    }, builder: (context, album) {
      return AlbumTile(
        album: album,
        subtitle: (album) {
          String subTitle = (album["artists"] as List)
              .cast<Map>()
              .map((ar) => ar["name"])
              .toList()
              .join("/");
          if (album["containedSong"] == null ||
              (album["containedSong"] as String).isEmpty) {
            String publishTime = DateFormat("y.M.d").format(
                DateTime.fromMillisecondsSinceEpoch(album["publishTime"]));
            subTitle = subTitle + " $publishTime";
          } else {
            subTitle = subTitle + " 包含单曲: ${album["containedSong"]}";
          }
          return subTitle;
        },
      );
    });
  }
}
