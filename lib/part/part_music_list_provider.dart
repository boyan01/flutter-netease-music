import 'package:flutter/material.dart';
import 'package:quiet/model/model.dart';

export 'package:quiet/model/model.dart';

import 'part.dart';

/// provider song list item widget
class SongTileProvider {
  SongTileProvider(this.token, this.musics)
      : assert(token != null),
        assert(musics != null);

  final List<Music> musics;

  final String token;

  //song item length plus a header
  get size => musics.length + 1;

  void _playAll(BuildContext context) {
    if (quiet.value.playlist.token == token && quiet.value.state.isPlaying) {
      //open playing page
      Navigator.pushNamed(null, ROUTE_PAYING);
    } else {
      quiet.playWithList(musics[0], musics, token);
    }
  }

  void _play(int index, BuildContext context) {
    var toPlay = musics[index];
    if (quiet.value.playlist.token == token &&
        quiet.value.state.isPlaying &&
        quiet.value.current == toPlay) {
      //open playing page
      Navigator.pushNamed(null, ROUTE_PAYING);
    } else {
      quiet.playWithList(toPlay, musics, token);
    }
  }

  Widget buildWidget(int index, BuildContext context) {
    if (index == 0) {
      return SongListHeader(musics.length, _playAll);
    }
    if (index - 1 < musics.length) {
      return SongTile(musics[index - 1], index,
          onTap: () => _play(index - 1, context));
    }
    return null;
  }
}

/// song list header
class SongListHeader extends StatelessWidget {
  SongListHeader(this.count, this.onTap);

  final int count;

  final void Function(BuildContext) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context),
      child: Container(
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
      ),
    );
  }
}

/// song item widget
class SongTile extends StatelessWidget {
  SongTile(this.music, this.index, {this.onTap});

  /// music item
  final Music music;

  /// [music]'index in list, start with 1
  final int index;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
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
                            color: Theme.of(context).dividerColor,
                            width: 0.3))),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Spacer(),
                        Text(
                          music.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.body1,
                        ),
                        Padding(padding: EdgeInsets.only(top: 3)),
                        Text(
                          music.subTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Spacer(),
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
      ),
    );
  }
}
