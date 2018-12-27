import 'package:flutter/material.dart';
import 'package:quiet/model/model.dart';
import 'package:quiet/pages/page_comment.dart';

import 'part.dart';

export 'package:quiet/model/model.dart';

typedef SongTileCallback = void Function(Music muisc);

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
    if (quiet.value.token == token && quiet.value.isPlaying) {
      //open playing page
      Navigator.pushNamed(context, ROUTE_PAYING);
    } else {
      quiet.playWithList(musics[0], musics, token);
    }
  }

  void _play(int index, BuildContext context) {
    var toPlay = musics[index];
    if (quiet.value.token == token &&
        quiet.value.isPlaying &&
        quiet.value.current == toPlay) {
      //open playing page
      Navigator.pushNamed(context, ROUTE_PAYING);
    } else {
      quiet.playWithList(toPlay, musics, token);
    }
  }

  ///build title for song list
  /// index = 0 -> song list header
  /// index = other -> song tile
  ///
  /// leadingType : the leading of a song tile, detail for [SongTileLeadingType]
  Widget buildWidget(int index, BuildContext context,
      {SongTileLeadingType leadingType = SongTileLeadingType.number,
      SongTileCallback onTap,
      VoidCallback onDelete,
      bool canDelete = false}) {
    if (index == 0) {
      return SongListHeader(musics.length, _playAll);
    }
    if (index - 1 < musics.length) {
      var item = musics[index - 1];
      return SongTile(
        item,
        index,
        onTap: () => onTap == null ? _play(index - 1, context) : onTap(item),
        leadingType: leadingType,
        onDelete: onDelete,
        playing: token == PlayerState.of(context).value.token &&
            item == PlayerState.of(context).value.current,
      );
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

///the leading for song tile
///default is show a number in the front of song tile
enum SongTileLeadingType {
  none,
  cover,
  number,
}

/// song item widget
class SongTile extends StatelessWidget {
  SongTile(this.music, this.index,
      {this.onTap,
      this.leadingType = SongTileLeadingType.number,
      this.playing = false,
      this.onDelete})
      : assert(leadingType != null);

  /// song data
  final Music music;

  /// [music]'index in list, start with 1
  final int index;

  final bool playing;

  final GestureTapCallback onTap;

  final SongTileLeadingType leadingType;

  ///callback when popup menu delete selected
  ///if [onDelete] be null , popup menu will not show delete menu
  final VoidCallback onDelete;

  Widget buildLeading(BuildContext context) {
    if (leadingType != SongTileLeadingType.none && playing) {
      return Container(
        margin: const EdgeInsets.only(left: 8, right: 8),
        width: 40,
        height: 40,
        child: Center(
          child: Icon(Icons.volume_up, color: Theme.of(context).primaryColor),
        ),
      );
    }
    Widget leading;
    switch (leadingType) {
      case SongTileLeadingType.number:
        leading = Container(
          margin: const EdgeInsets.only(left: 8, right: 8),
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              index.toString(),
              style: Theme.of(context).textTheme.body2,
            ),
          ),
        );
        break;
      case SongTileLeadingType.none:
        leading = Padding(padding: EdgeInsets.only(left: 16));
        break;
      case SongTileLeadingType.cover:
        leading = Container(
          margin: const EdgeInsets.only(left: 8, right: 8),
          width: 40,
          height: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Image(
              image: NetworkImage(music.album.coverImageUrl),
            ),
          ),
        );
        break;
    }
    return leading;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildLeading(context),
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
                      itemBuilder: (context) =>
                          <PopupMenuItem<SongPopupMenuType>>[
                            PopupMenuItem(
                              child: Text("下一首播放"),
                              value: SongPopupMenuType.addToNext,
                            ),
                            PopupMenuItem(
                              child: Text("评论"),
                              value: SongPopupMenuType.comment,
                            ),
                            onDelete == null
                                ? null
                                : PopupMenuItem(
                                    child: Text("删除"),
                                    value: SongPopupMenuType.delete,
                                  )
                          ]..removeWhere((v) => v == null),
                      onSelected: (SongPopupMenuType type) async {
                        switch (type) {
                          case SongPopupMenuType.addToNext:
                            quiet.insertToNext(music);
                            break;
                          case SongPopupMenuType.comment:
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommentPage(
                                threadId: CommentThreadId(
                                    music.id, CommentType.song,
                                    playload:
                                        CommentThreadPayload.music(music)),
                              );
                            }));
                            break;
                          case SongPopupMenuType.delete:
                            bool delete = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Text("确认将所选音乐从列表中删除?"),
                                    actions: <Widget>[
                                      FlatButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text("取消")),
                                      FlatButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text("确认")),
                                    ],
                                  );
                                });
                            if (delete != null && delete && onDelete != null) {
                              onDelete();
                            }
                            break;
                        }
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

enum SongPopupMenuType {
  addToNext,
  comment,
  delete,
}
