import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/material.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/page_playlist_edit.dart';
import 'package:quiet/pages/playlist/page_playlist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/cached_image.dart';

///歌单列表元素
class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    Key key,
    @required this.playlist,
    this.enableMore = true,
    this.enableHero = true,
  }) : super(key: key);

  final PlaylistDetail playlist;

  final bool enableMore;

  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    Widget cover = Container(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        child: FadeInImage(
          placeholder: AssetImage("assets/playlist_playlist.9.png"),
          image: CachedImage(playlist.coverUrl),
          fit: BoxFit.cover,
          height: 50,
          width: 50,
        ),
      ),
    );
    if (enableHero) {
      cover = QuietHero(
        tag: playlist.heroTag,
        child: cover,
      );
    }

    return InkWell(
      onTap: () {
        context.secondaryNavigator
            .push(MaterialPageRoute(builder: (context) => PlaylistDetailPage(playlist.id, playlist: playlist)));
      },
      child: Container(
        height: 60,
        child: Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 16)),
            cover,
            Padding(padding: EdgeInsets.only(left: 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(),
                  Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15),
                  ),
                  Padding(padding: EdgeInsets.only(top: 4)),
                  Text("${playlist.trackCount}首", style: Theme.of(context).textTheme.caption),
                  Spacer(),
                ],
              ),
            ),
            if (enableMore)
              PopupMenuButton<PlaylistOp>(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(child: Text("分享"), value: PlaylistOp.share),
                    PopupMenuItem(child: Text("编辑歌单信息"), value: PlaylistOp.edit),
                    PopupMenuItem(child: Text("删除"), value: PlaylistOp.delete),
                  ];
                },
                onSelected: (op) {
                  switch (op) {
                    case PlaylistOp.delete:
                    case PlaylistOp.share:
                      toast("未接入。");
                      break;
                    case PlaylistOp.edit:
                      context.secondaryNavigator.push(MaterialPageRoute(builder: (context) {
                        return PlaylistEditPage(playlist);
                      }));
                      break;
                  }
                },
                icon: Icon(Icons.more_vert),
              ),
          ],
        ),
      ),
    );
  }
}

enum PlaylistOp { edit, share, delete }
