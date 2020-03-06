library player;

import 'package:flutter/material.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/material/playing_indicator.dart';
import 'package:quiet/pages/page_playing_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/cached_image.dart';

@visibleForTesting
class DisableBottomController extends StatelessWidget {
  final Widget child;

  const DisableBottomController({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class BoxWithBottomPlayerController extends StatelessWidget {
  BoxWithBottomPlayerController(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.findAncestorWidgetOfExactType<DisableBottomController>() != null) {
      return child;
    }

    final media = MediaQuery.of(context);
    //hide bottom player controller when view inserts
    //bottom too height (such as typing with soft keyboard)
    bool hide = isSoftKeyboardDisplay(media);
    return Column(
      children: <Widget>[
        Expanded(child: child),
        if (!hide) BottomControllerBar(bottomPadding: media.padding.bottom),
        SizedBox(height: media.viewInsets.bottom)
      ],
    );
  }
}

///底部当前音乐播放控制栏
class BottomControllerBar extends StatelessWidget {
  final double bottomPadding;

  const BottomControllerBar({Key key, this.bottomPadding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final music = context.playerValue.current;
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
            borderRadius:
                const BorderRadius.only(topLeft: const Radius.circular(4.0), topRight: const Radius.circular(4.0))),
        child: Container(
          height: 56,
          margin: EdgeInsets.only(bottom: bottomPadding),
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
                      child: music.imageUrl == null
                          ? Container(color: Colors.grey)
                          : Image(
                              fit: BoxFit.cover,
                              image: CachedImage(music.imageUrl),
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
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Padding(padding: const EdgeInsets.only(top: 2)),
                      DefaultTextStyle(
                        child: ProgressTrackContainer(builder: (context) => _SubTitleOrLyric(music.subTitle)),
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

class _SubTitleOrLyric extends StatelessWidget {
  final String subtitle;

  const _SubTitleOrLyric(this.subtitle, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playingLyric = PlayingLyric.of(context);
    if (!playingLyric.hasLyric) {
      return Text(subtitle);
    }
    final line = playingLyric.lyric.getLineByTimeStamp(context.playbackState.positionWithOffset, 0)?.line;
    if (line == null || line.isEmpty) {
      return Text(subtitle);
    }
    return Text(line);
  }
}

class _PauseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlayingIndicator(
      playing: IconButton(
          icon: Icon(Icons.pause),
          onPressed: () {
            context.transportControls.pause();
          }),
      pausing: IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () {
            context.transportControls.play();
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
