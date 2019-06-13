import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

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
    super.build(context);
    return AutoLoadMoreList(loadMore: (offset) async {
      final result = await neteaseRepository
          .search(widget.query, NeteaseSearchType.playlist, offset: offset);
      if (result.isValue) {
        return LoadMoreResult(result.asValue.value["result"]["playlists"]);
      }
      return result as Result<List>;
    }, builder: (context, item) {
      return _PlayListTile(item);
    });
  }
}

class _PlayListTile extends StatelessWidget {
  final Map item;

  const _PlayListTile(this.item, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String subTitle =
        "${item["trackCount"]}首 by ${item["creator"]["nickname"]},"
        "播放${getFormattedNumber(item["playCount"])}次";
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return PlaylistDetailPage(item["id"]);
        }));
      },
      child: Container(
        height: 64,
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image(
                      image: CachedImage(item["coverImgUrl"]),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 4)),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Spacer(),
                Text(item["name"], maxLines: 1),
                Spacer(),
                Text(subTitle,
                    maxLines: 1, style: Theme.of(context).textTheme.caption),
                Spacer(),
                Divider(height: 0)
              ],
            ))
          ],
        ),
      ),
    );
  }
}
