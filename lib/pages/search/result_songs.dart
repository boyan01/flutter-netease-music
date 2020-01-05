import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
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

class SongsResultSectionState extends State<SongsResultSection> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MusicTileConfiguration(
      musics: const [],
      onMusicTap: (context, item) async {
        var playable = await neteaseRepository.checkMusic(item.id);
        if (!playable) {
          showDialog(context: context, builder: (context) => DialogNoCopyRight());
          return;
        }
        final song = await neteaseRepository.getMusicDetail(item.id);
        if (song.isValue) {
          final metadata = mapJsonToMusic(song.asValue.value, artistKey: "ar", albumKey: "al").metadata;
          context.player
            ..insertToNext(metadata)
            ..transportControls.playFromMediaId(metadata.mediaId);
        } else {
          showSimpleNotification(Text("播放歌曲失败!"),
              leading: Icon(Icons.notification_important), background: Theme.of(context).errorColor);
        }
      },
      child: AutoLoadMoreList(
        loadMore: (count) async {
          final result = await neteaseRepository.search(widget.query, NeteaseSearchType.song, offset: count);
          if (result.isValue) {
            return LoadMoreResult(result.asValue.value["result"]["songs"] ?? []);
          }
          return result as Result<List>;
        },
        builder: (context, item) {
          return MusicTile(mapJsonToMusic(item as Map));
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
