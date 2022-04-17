import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/repository.dart';

class PlaylistResultSection extends StatefulWidget {
  const PlaylistResultSection({Key? key, this.query}) : super(key: key);
  final String? query;

  @override
  State<PlaylistResultSection> createState() => _PlaylistResultSectionState();
}

class _PlaylistResultSectionState extends State<PlaylistResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AutoLoadMoreList(loadMore: (offset) async {
      final result = await neteaseRepository!
          .search(widget.query, SearchType.playlist, offset: offset);
      if (result.isValue) {
        return LoadMoreResult(result.asValue!.value["result"]["playlists"]);
      }
      return result as Result<List>;
    }, builder: (context, dynamic item) {
      return _PlayListTile(item);
    });
  }
}

class _PlayListTile extends StatelessWidget {
  const _PlayListTile(this.item, {Key? key}) : super(key: key);
  final Map item;

  @override
  Widget build(BuildContext context) {
    final String subTitle =
        "${item["trackCount"]}首 by ${item["creator"]["nickname"]}, "
        "播放${getFormattedNumber(item["playCount"])}次";
    return InkWell(
      onTap: () {
        // TODO navigate to playlist detail
      },
      child: SizedBox(
        height: 64,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4),
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
            const Padding(padding: EdgeInsets.only(left: 4)),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Spacer(),
                Text(item["name"], maxLines: 1),
                const Spacer(),
                Text(subTitle,
                    maxLines: 1, style: Theme.of(context).textTheme.caption),
                const Spacer(),
                const Divider(height: 0)
              ],
            ))
          ],
        ),
      ),
    );
  }
}
