import 'package:flutter/material.dart';

export 'package:quiet/model/model.dart';

/// provider song list item widget
class SongTileProvider {
  SongTileProvider(this.musics);

  final List<dynamic> musics;

  Widget buildWidget(int index) {
    if (index == 0) {
      return SongListHeader(musics.length);
    }
    if (index - 1 < musics.length) {
      return SongTile(musics[index - 1], index);
    }
    return null;
  }
}

/// song list header
class SongListHeader extends StatelessWidget {
  SongListHeader(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).dividerColor, width: 0.5))),
      child: Row(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 16)),
          Icon(
            Icons.play_circle_outline,
            size: 18,
            color: Theme.of(context).iconTheme.color,
          ),
          Padding(padding: EdgeInsets.only(left: 4)),
          Text(
            "播放全部",
            style: Theme.of(context).textTheme.body1,
          ),
          Padding(padding: EdgeInsets.only(left: 2)),
          Text(
            "(共$count首)",
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
    );
  }
}

/// song item widget
class SongTile extends StatelessWidget {
  SongTile(this.music, this.index);

  /// music json item
  final Map<String, Object> music;

  /// [music]'index in list, start with 1
  final int index;

  @override
  Widget build(BuildContext context) {
    var artist = (music["ar"] as List)
        .map((e) => e["name"])
        .join('/');

    var album = (music["al"] as Map)["name"];

    return Container(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 8, right: 8),
            width: 40,
            height: 40,
            child: Center(
              child: Text(
                index.toString(),
                style: Theme.of(context).textTheme.body2,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Theme.of(context).dividerColor, width: 0.3))),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        music["name"],
                        style: Theme.of(context).textTheme.body1,
                      ),
                      Text(
                        "$album - $artist",
                        style: Theme.of(context).textTheme.caption,
                      )
                    ],
                  )),
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Text("下一首播放"),
                        )
                      ];
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
