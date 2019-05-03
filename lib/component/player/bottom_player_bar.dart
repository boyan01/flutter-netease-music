library player;

import 'package:flutter/material.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/material/playing_indicator.dart';
import 'package:quiet/pages/page_playing_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease_image.dart';

class BoxWithBottomPlayerController extends StatelessWidget {
  BoxWithBottomPlayerController(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    //hide bottom player controller when view inserts
    //bottom too height (such as typing with soft keyboard)
    ///fixme [Scaffold#resizeToAvoidBottomInset] 影响了这个判断
    bool hide = isSoftKeyboardDisplay(MediaQuery.of(context));
    return Column(
      children: <Widget>[
        Expanded(child: child),
        hide ? Container() : BottomControllerBar(),
      ],
    );
  }
}

///底部当前音乐播放控制栏
class BottomControllerBar extends StatelessWidget {
  Widget _buildSubtitle(BuildContext context, Music music) {
    final playingLyric = PlayingLyric.of(context);
    if (!playingLyric.hasLyric) {
      return Text(music.subTitle);
    }
    final line = playingLyric.lyric
        .getLineByTimeStamp(
            PlayerState.of(context, aspect: PlayerStateAspect.position)
                .value
                .position
                .inMilliseconds,
            0)
        .line;
    if (line.isEmpty) {
      return Text(music.subTitle);
    }
    return Text(line);
  }

  @override
  Widget build(BuildContext context) {
    var music =
        PlayerState.of(context, aspect: PlayerStateAspect.music).value.current;
    if (music == null) {
      return Container();
    }
    return InkWell(
      onTap: () {
        if (music != null) {
          Navigator.pushNamed(context, ROUTE_PAYING);
        }
      },
      child: Card(
        margin: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
                topLeft: const Radius.circular(4.0),
                topRight: const Radius.circular(4.0))),
        child: Container(
          height: 56,
          child: Row(
            children: <Widget>[
              Hero(
                tag: "album_cover",
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      child: music.album.coverImageUrl == null
                          ? Container(color: Colors.grey)
                          : Image(
                              fit: BoxFit.cover,
                              image: NeteaseImage(music.album.coverImageUrl),
                            ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: DefaultTextStyle(
                  style: TextStyle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Spacer(),
                      Text(
                        music.title,
                        style: Theme.of(context).textTheme.body1,
                      ),
                      Padding(padding: const EdgeInsets.only(top: 2)),
                      DefaultTextStyle(
                        child: _buildSubtitle(context, music),
                        maxLines: 1,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              _PauseButton(),
              IconButton(
                  tooltip: "当前播放列表",
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return PlayingListDialog();
                        });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlayingIndicator(
      playing: IconButton(
          icon: Icon(Icons.pause),
          onPressed: () {
            quiet.pause();
          }),
      pausing: IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () {
            quiet.play();
          }),
      buffering: Container(
        height: 24,
        width: 24,
        //to fit  IconButton min width 48
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(4),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
