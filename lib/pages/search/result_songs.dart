import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository.dart';
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
          ..insertToNext(item)
          ..playFromMediaId(item.id);
      },
      child: AutoLoadMoreList(
        loadMore: (count) async {
          final result = await neteaseRepository!
              .search(widget.query, SearchType.song, offset: count);
          if (result.isValue) {
            return LoadMoreResult(
                result.asValue!.value["result"]["songs"] ?? []);
          }
          return result as Result<List>;
        },
        builder: (context, dynamic item) {
          // FIXME search item handle.
          return MusicTile(item);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
