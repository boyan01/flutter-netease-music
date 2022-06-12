import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/repository.dart';

///video list result
class VideosResultSection extends StatefulWidget {
  const VideosResultSection({Key? key, required this.query}) : super(key: key);

  final String? query;

  @override
  State<VideosResultSection> createState() => _VideosResultSectionState();
}

class _VideosResultSectionState extends State<VideosResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AutoLoadMoreList(loadMore: (offset) async {
      final result = await neteaseRepository!
          .search(widget.query, SearchType.video, offset: offset);
      if (result.isError) {
        return result.asError!;
      }
      return result.asValue!.value['result']['videos'];
    }, builder: (context, dynamic item) {
      return VideoTile(map: item);
    });
  }

  @override
  bool get wantKeepAlive => true;
}

///item for video
class VideoTile extends StatelessWidget {
  const VideoTile({Key? key, required this.map}) : super(key: key);

  final Map<String, dynamic> map;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint("on tag : ${map["vid"]}");
      },
      child: SizedBox(
        height: 72,
        child: Row(
          children: <Widget>[
            Container(
              height: 72,
              width: 72 * 1.6,
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image(
                  image: CachedImage(map['coverUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 8)),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(map['title'],
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(
                      "${getTimeStamp(map["durationms"])} by ${(map["creator"] as List).cast<Map>().map((creator) {
                        return creator["userName"];
                      }).join("/")}",
                      style: Theme.of(context).textTheme.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )),
                const Divider(height: 0)
              ],
            ))
          ],
        ),
      ),
    );
  }
}
