import 'package:flutter/material.dart';
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
    return Loader(
        loadTask: () =>
            neteaseRepository.search(widget.query, NeteaseSearchType.playlist),
        builder: (context, result) {
          return AutoLoadMoreList(
              loadMore: (offset) async {
                final result = await neteaseRepository.search(
                    widget.query, NeteaseSearchType.playlist,
                    offset: offset);
                if (result.isValue) {
                  return result.asValue.value["result"]["playlists"];
                }
                return null;
              },
              initialList: result["result"]["playlists"],
              totalCount: result["result"]["playlistCount"],
              builder: (context, item) {
                String subTitle =
                    "${item["trackCount"]}首 by ${item["creator"]["nickname"]},"
                    "播放${getFormattedNumber(item["playCount"])}次";
                return InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
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
                                  image: NeteaseImage(item["coverImgUrl"]),
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
                                maxLines: 1,
                                style: Theme.of(context).textTheme.caption),
                            Spacer(),
                            Divider(height: 0)
                          ],
                        ))
                      ],
                    ),
                  ),
                );
              });
        });
  }
}
