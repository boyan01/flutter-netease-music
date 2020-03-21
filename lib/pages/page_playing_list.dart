import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/pages/playlist/dialog_selector.dart';
import 'package:quiet/part/part.dart';

/// Current Playing List Dialog
///
/// use [show] to open PlayingList
///
/// TODO: do no use [showModalBottomSheet]
///
///
class PlayingListDialog extends StatefulWidget {
  static void show(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return PlayingListDialog();
        });
  }

  @override
  PlayingListDialogState createState() {
    return new PlayingListDialogState();
  }
}

class PlayingListDialogState extends State<PlayingListDialog> {
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    final playingList = context.player.value.playingList;
    final music = context.player.value.current;
    assert(music != null, '展示播放列表时，当前音乐不能为空！');
    double offset = playingList.indexOf(music) * _HEIGHT_MUSIC_TILE;
    _controller = ScrollController(initialScrollOffset: offset);
  }

  @override
  Widget build(BuildContext context) {
    final playingList = context.listenPlayerValue.playingList;
    final music = context.listenPlayerValue.current;

    return _PlayingListContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Header(),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Expanded(
            child: ListView.builder(
                controller: _controller,
                itemCount: playingList.length,
                itemBuilder: (context, index) {
                  var item = playingList[index];
                  return _MusicTile(music: item, playing: item == music);
                }),
          )
        ],
      ),
    );
  }
}

class _PlayingListContainer extends StatelessWidget {
  final Widget child;

  const _PlayingListContainer({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (context.isLandscape) {
      return _LandscapePlayingListContainer(child: child);
    } else {
      return _PortraitPlayingListContainer(child: child);
    }
  }
}

class _PortraitPlayingListContainer extends StatelessWidget {
  final Widget child;

  const _PortraitPlayingListContainer({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: child,
      ),
    );
  }
}

class _LandscapePlayingListContainer extends StatelessWidget {
  final Widget child;

  const _LandscapePlayingListContainer({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        width: 520,
        child: Material(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playMode = context.playMode;
    final count = context.playList.queue.length;
    return Container(
      height: 48,
      child: Row(
        children: <Widget>[
          FlatButton.icon(
              onPressed: () {
                context.transportControls.setPlayMode(playMode.next);
              },
              icon: Icon(playMode.icon),
              label: Text("${playMode.name}($count)")),
          Spacer(),
          FlatButton.icon(
              onPressed: () async {
                final ids = context.playList.queue.map((m) => int.parse(m.mediaId)).toList();
                if (ids.isEmpty) {
                  return;
                }
                final succeed = await PlaylistSelectorDialog.addSongs(context, ids);
                if (succeed == null) {
                  return;
                }
                if (succeed) {
                  showSimpleNotification(Text("添加到收藏成功"));
                } else {
                  showSimpleNotification(Text("添加到收藏失败"),
                      leading: Icon(Icons.error), background: Theme.of(context).errorColor);
                }
              },
              icon: Icon(Icons.add_box),
              label: Text("收藏全部")),
          IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () async {
                Navigator.pop(context);
                //FIXME
//                  context.player.setPlayList(PlayList.empty());
              })
        ],
      ),
    );
  }
}

const _HEIGHT_MUSIC_TILE = 48.0;

class _MusicTile extends StatelessWidget {
  final Music music;
  final bool playing;

  const _MusicTile({Key key, this.music, this.playing = false})
      : assert(music != null && playing != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget leading;
    Color name, artist;
    if (playing) {
      Color color = Theme.of(context).primaryColorLight;
      leading = Container(
        margin: EdgeInsets.only(right: 8),
        child: Icon(
          Icons.volume_up,
          color: color,
          size: 18,
        ),
      );
      name = color;
      artist = color;
    } else {
      leading = Container();
      name = Theme.of(context).textTheme.bodyText2.color;
      artist = Theme.of(context).textTheme.caption.color;
    }
    return InkWell(
      onTap: () {
        context.transportControls.playFromMediaId(music.metadata.mediaId);
      },
      child: Container(
        padding: EdgeInsets.only(left: 8),
        height: _HEIGHT_MUSIC_TILE,
        decoration:
            BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.3))),
        child: Row(
          children: <Widget>[
            leading,
            Expanded(
                child: Text.rich(
              TextSpan(children: [
                TextSpan(text: music.title, style: TextStyle(color: name)),
                TextSpan(
                    text: " - ${music.artist.map((a) => a.name).join('/')}",
                    style: TextStyle(color: artist, fontSize: 12))
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  context.player.removeMusicItem(music.metadata);
                })
          ],
        ),
      ),
    );
  }
}
