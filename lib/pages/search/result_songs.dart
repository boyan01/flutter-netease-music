import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/part/part.dart';
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
          return AutoLoadMoreList(
            loadMore: (count) async {
              Map result = await neteaseRepository
                  .search(widget.query, NeteaseSearchType.song, offset: count);
              var verify = neteaseRepository.responseVerify(result);
              if (verify.isSuccess) {
                //if verify succeed, we assume that has reached the end
                return result["result"]["songs"] ?? [];
              }
              return null;
            },
            totalCount: result["result"]["songCount"],
            initialList: result["result"]["songs"],
            builder: (context, item) {
              return SongTile(
                mapJsonToMusic(item as Map),
                0, //we do not need index here
                leadingType: SongTileLeadingType.none,
                onTap: () async {
                  var playable = await neteaseRepository.checkMusic(item["id"]);
                  if (!playable) {
                    showDialog(
                        context: context,
                        builder: (context) => DialogNoCopyRight());
                    return;
                  }
                  final song =
                      await neteaseRepository.getMusicDetail(item["id"]);
                  if (song != null) {
                    quiet.play(
                        music: mapJsonToMusic(song,
                            artistKey: "ar", albumKey: "al"));
                  } else {
                    showSimpleNotification(context, Text("播放歌曲失败!"),
                        leading: Icon(Icons.notification_important),
                        background: Theme.of(context).errorColor);
                  }
                },
              );
            },
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
