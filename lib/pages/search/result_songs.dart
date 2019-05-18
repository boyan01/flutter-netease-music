import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/pages/playlist/dialog_copyright.dart';
import 'package:quiet/pages/playlist/music_list.dart';
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
    super.build(context);
    return Loader<Map>(
        loadTask: () =>
            neteaseRepository.search(widget.query, NeteaseSearchType.song),
        builder: (context, result) {
          return MusicList(
            musics: const [],
            onMusicTap: (context, item) async {
              var playable = await neteaseRepository.checkMusic(item.id);
              if (!playable) {
                showDialog(
                    context: context,
                    builder: (context) => DialogNoCopyRight());
                return;
              }
              final song = await neteaseRepository.getMusicDetail(item.id);
              if (song.isValue) {
                quiet.play(
                    music: mapJsonToMusic(song.asValue.value,
                        artistKey: "ar", albumKey: "al"));
              } else {
                showSimpleNotification(context, Text("播放歌曲失败!"),
                    leading: Icon(Icons.notification_important),
                    background: Theme.of(context).errorColor);
              }
            },
            child: AutoLoadMoreList(
              loadMore: (count) async {
                final result = await neteaseRepository.search(
                    widget.query, NeteaseSearchType.song,
                    offset: count);
                if (result.isValue) {
                  //if verify succeed, we assume that has reached the end
                  return result.asValue.value["result"]["songs"] ?? [];
                }
                return null;
              },
              totalCount: result["result"]["songCount"],
              initialList: result["result"]["songs"],
              builder: (context, item) {
                return MusicTile(mapJsonToMusic(item as Map));
              },
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
