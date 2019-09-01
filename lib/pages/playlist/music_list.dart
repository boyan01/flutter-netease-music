import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/route.dart';
import 'package:quiet/model/model.dart';
import 'package:quiet/pages/artists/page_artist_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import 'dialog_selector.dart';

class MusicList extends StatelessWidget {
  static MusicList of(BuildContext context) {
    final list = context.ancestorWidgetOfExactType(MusicList);
    assert(list != null, 'you can only use [MusicTile] inside MusicList scope');
    return list;
  }

  static final Widget Function(BuildContext context, Music music) defaultTrailingBuilder = (context, music) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[IconMV(music), _IconMore(music)],
    );
  };

  static final Widget Function(BuildContext context, Music music) indexedLeadingBuilder = (context, music) {
    int index = MusicList.of(context).musics.indexOf(music) + 1;
    return _buildPlayingLeading(context, music) ??
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
        );
  };

  static final Widget Function(BuildContext context, Music music) coverLeadingBuilder = (context, music) {
    return _buildPlayingLeading(context, music) ??
        Container(
          margin: const EdgeInsets.only(left: 8, right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: FadeInImage(
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              image: CachedImage(music.description.iconUri?.toString() ?? ""),
              placeholder: AssetImage("assets/playlist_playlist.9.png"),
            ),
          ),
        );
  };

  //return null if current music is not be playing
  static Widget _buildPlayingLeading(BuildContext context, Music music) {
    if (MusicList.of(context).token == PlayerState.of(context).token && music == PlayerState.of(context).current) {
      return Container(
        margin: const EdgeInsets.only(left: 8, right: 8),
        width: 40,
        height: 40,
        child: Center(
          child: Icon(Icons.volume_up, color: Theme.of(context).primaryColor),
        ),
      );
    }
    return null;
  }

  static final void Function(BuildContext context, Music muisc) defaultOnTap = (context, music) {
    final list = MusicList.of(context);
    if (quiet.compatValue.token == list.token && quiet.compatValue.isPlaying && quiet.compatValue.current == music) {
      //open playing page
      Navigator.pushNamed(context, ROUTE_PAYING);
    } else {
      quiet.playWithList(music, list.musics, list.token);
    }
  };

  final String token;

  final List<Music> musics;

  final void Function(BuildContext context, Music muisc) onMusicTap;

  final Widget Function(BuildContext context, Music music) leadingBuilder;

  final Widget Function(BuildContext context, Music music) trailingBuilder;

  final bool supportAlbumMenu;

  final void Function(Music music) remove;

  final Widget child;

  MusicList(
      {Key key,
      this.token,
      @required this.musics,
      this.onMusicTap,
      this.child,
      this.leadingBuilder,
      this.trailingBuilder,
      this.supportAlbumMenu = true,
      this.remove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// song item widget
class MusicTile extends StatelessWidget {
  final Music music;

  MusicTile(this.music, {Key key}) : super(key: key);

  Widget _buildPadding(BuildContext context, Music music) {
    return SizedBox(width: 8);
  }

  @override
  Widget build(BuildContext context) {
    final list = MusicList.of(context);
    return Container(
      height: 56,
      child: InkWell(
        onTap: () {
          if (list.onMusicTap != null) list.onMusicTap(context, music);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (list.leadingBuilder ?? _buildPadding)(context, music),
            Expanded(
              child: _SimpleMusicTile(music),
            ),
            (list.trailingBuilder ?? _buildPadding)(context, music),
          ],
        ),
      ),
    );
  }
}

class _SimpleMusicTile extends StatelessWidget {
  final Music music;

  const _SimpleMusicTile(this.music, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
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
        ],
      ),
    );
  }
}

///音乐列表头
class MusicListHeader extends StatelessWidget implements PreferredSizeWidget {
  MusicListHeader(this.count, {this.tail});

  final int count;

  final Widget tail;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        child: InkWell(
          onTap: () {
            final list = MusicList.of(context);
            if (quiet.compatValue.token == list.token && quiet.compatValue.isPlaying) {
              //open playing page
              Navigator.pushNamed(context, ROUTE_PAYING);
            } else {
              quiet.playWithList(null, list.musics, list.token);
            }
          },
          child: SizedBox.fromSize(
            size: preferredSize,
            child: Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 16)),
                Icon(
                  Icons.play_circle_outline,
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
                Spacer(),
                tail,
              ]..removeWhere((v) => v == null),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

///歌曲item的mv icon
class IconMV extends StatelessWidget {
  final Music music;

  const IconMV(this.music, {Key key})
      : assert(music != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (music.mvId == 0) {
      return Container();
    }
    return IconButton(
        icon: Icon(Icons.videocam),
        tooltip: 'MV',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MusicVideoPlayerPage(music.mvId)),
          );
        });
  }
}

enum _MusicAction {
  addToNext,
  comment,
  delete,

  ///添加到歌单
  addToPlaylist,

  ///导航到专辑
  album,

  ///导航到歌手
  artists,
}

class _IconMore extends StatelessWidget {
  final Music music;

  const _IconMore(this.music, {Key key}) : super(key: key);

  List<PopupMenuItem> _buildMenu(BuildContext context) {
    var items = [
      PopupMenuItem(
        child: Text("下一首播放"),
        value: _MusicAction.addToNext,
      ),
      PopupMenuItem(
        child: Text("收藏到歌单"),
        value: _MusicAction.addToPlaylist,
      ),
      PopupMenuItem(
        child: Text("评论"),
        value: _MusicAction.comment,
      ),
    ];

    items.add(PopupMenuItem(
        child: Text("歌手: ${music.artist.map((a) => a.name).join('/')}", maxLines: 1),
        //如果所有artist的id为0，那么disable这个item
        enabled: music.artist.fold(0, (c, ar) => c + ar.id) != 0,
        value: _MusicAction.artists));

    if (MusicList.of(context).supportAlbumMenu) {
      items.add(PopupMenuItem(
        child: Text("专辑"),
        value: _MusicAction.album,
      ));
    }
    if (MusicList.of(context).remove != null) {
      items.add(PopupMenuItem(
        child: Text("删除"),
        value: _MusicAction.delete,
      ));
    }
    return items;
  }

  void _handleMusicAction(BuildContext context, _MusicAction type) async {
    switch (type) {
      case _MusicAction.addToNext:
        quiet.insertToNext(music);
        break;
      case _MusicAction.comment:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CommentPage(
            threadId: CommentThreadId(music.id, CommentType.song, payload: CommentThreadPayload.music(music)),
          );
        }));
        break;
      case _MusicAction.delete:
        MusicList.of(context).remove(music);
        break;
      case _MusicAction.addToPlaylist:
        final id = await showDialog(
            context: context,
            builder: (context) {
              return PlaylistSelectorDialog();
            });
        if (id != null) {
          bool succeed = await neteaseRepository.playlistTracksEdit(PlaylistOperation.add, id, [music.id]);
          var scaffold = Scaffold.of(context);
          if (scaffold == null) {
            //not notify when scaffold is empty
            return;
          }
          if (succeed) {
            showSimpleNotification(Text("已添加到收藏"));
          } else {
            showSimpleNotification(Text("收藏歌曲失败!"),
                leading: Icon(Icons.error), background: Theme.of(context).errorColor);
          }
        }
        break;
      case _MusicAction.album:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return AlbumDetailPage(albumId: music.album.id);
        }));
        break;
      case _MusicAction.artists:
        launchArtistDetailPage(context, music.artist);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: _buildMenu,
      onSelected: (type) => _handleMusicAction(context, type),
    );
  }
}
