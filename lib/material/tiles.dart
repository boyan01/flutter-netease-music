import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiet/component/route.dart';
import 'package:quiet/repository/cached_image.dart';

class AlbumTile extends StatelessWidget {
  const AlbumTile({Key key, @required this.album, this.subtitle})
      : assert(album != null),
        super(key: key);

  ///netease album json object
  final Map album;

  final String Function(Map album) subtitle;

  String _defaultSubtitle(Map album) {
    String date = DateFormat("y.M.d")
        .format(DateTime.fromMillisecondsSinceEpoch(album["publishTime"]));
    return "$date 歌曲 ${album["size"]}";
  }

  @override
  Widget build(BuildContext context) {
    String subtitle = (this.subtitle ?? _defaultSubtitle)(album);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return AlbumDetailPage(albumId: album["id"], album: album);
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
                      image: CachedImage(album["picUrl"]), fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 4)),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Spacer(),
                Text(album["name"], maxLines: 1),
                Spacer(),
                Text(subtitle,
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
