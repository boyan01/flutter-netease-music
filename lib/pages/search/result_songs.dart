import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

///song list result
class SongsResultSection extends StatefulWidget {
  const SongsResultSection({Key? key, required this.query}) : super(key: key);

  final String? query;

  @override
  SongsResultSectionState createState() {
    return SongsResultSectionState();
  }
}

class SongsResultSectionState extends State<SongsResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MusicTileConfiguration(
      musics: const [],
      onMusicTap: (context, item) async {
        // TODO check music is playable?
        context.player
          ..insertToNext(item.metadata)
          ..transportControls.playFromMediaId(item.metadata.mediaId);
      },
      child: AutoLoadMoreList(
        loadMore: (count) async {
          final result = await neteaseRepository!
              .search(widget.query, NeteaseSearchType.song, offset: count);
          if (result.isValue) {
            return LoadMoreResult(
                result.asValue!.value["result"]["songs"] ?? []);
          }
          return result as Result<List>;
        },
        builder: (context, dynamic item) {
          return MusicTile(mapJsonToMusic(item as Map));
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
