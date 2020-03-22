import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component.dart';
import 'package:quiet/material.dart';
import 'package:quiet/pages/artists/page_artist_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/repository/cached_image.dart';
import 'package:quiet/repository/netease.dart';

import 'background.dart';
import 'player_progress.dart';

/// FM 播放页面
class PagePlayingFm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final current = context.listenPlayerValue.current;
    if (current == null) {
      WidgetsBinding.instance.scheduleFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return Container();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          BlurBackground(music: current),
          Material(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                AppBar(
                  title: Text("私人FM"),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                _CenterSection(),
                const SizedBox(height: 8),
                DurationProgressBar(),
                _FmControllerBar(),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterSection extends StatefulWidget {
  const _CenterSection({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CenterSectionState();
}

class _CenterSectionState extends State<_CenterSection> {
  static bool _showLyric = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedCrossFade(
        crossFadeState: _showLyric ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
          return Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Center(
                key: bottomChildKey,
                child: bottomChild,
              ),
              Center(
                key: topChildKey,
                child: topChild,
              ),
            ],
          );
        },
        duration: Duration(milliseconds: 300),
        firstChild: GestureDetector(
          onTap: () {
            setState(() {
              _showLyric = !_showLyric;
            });
          },
          child: _FmCover(),
        ),
        secondChild: PlayingLyricView(
          music: context.listenPlayerValue.current,
          onTap: () {
            setState(() {
              _showLyric = !_showLyric;
            });
          },
        ),
      ),
    );
  }
}

class _FmCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final music = context.listenPlayerValue.current;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image(image: CachedImage(music.imageUrl)),
          ),
        ),
        Text(
          music.title ?? "",
          style: Theme.of(context).primaryTextTheme.subtitle1,
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () {
            launchArtistDetailPage(context, music.artist);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(maxWidth: 200),
                child: Text(
                  music.artistString,
                  style: Theme.of(context).primaryTextTheme.caption.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, size: 17, color: Theme.of(context).primaryTextTheme.caption.color),
            ],
          ),
        )
      ],
    );
  }
}

class _FmControllerBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryIconTheme.color;

    final iconPlayPause = PlayingIndicator(
      playing: IconButton(
          tooltip: "暂停",
          iconSize: 40,
          icon: Icon(
            Icons.pause_circle_outline,
            color: color,
          ),
          onPressed: () {
            context.transportControls.pause();
          }),
      pausing: IconButton(
          tooltip: "播放",
          iconSize: 40,
          icon: Icon(
            Icons.play_circle_outline,
            color: color,
          ),
          onPressed: () {
            context.transportControls.play();
          }),
      buffering: Container(
        height: 56,
        width: 56,
        child: Center(
          child: Container(height: 24, width: 24, child: CircularProgressIndicator()),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: color,
              ),
              onPressed: () {
                toast('已加入不喜欢列表，以后将减少类似的推荐。');
                context.transportControls.skipToNext();
              }),
          LikeButton.current(context),
          iconPlayPause,
          IconButton(
              tooltip: "下一曲",
              icon: Icon(
                Icons.skip_next,
                color: color,
              ),
              onPressed: () {
                context.transportControls.skipToNext();
              }),
          IconButton(
              tooltip: "当前播放列表",
              icon: Icon(
                Icons.comment,
                color: color,
              ),
              onPressed: () {
                context.secondaryNavigator.push(MaterialPageRoute(
                    builder: (context) => CommentPage(
                          threadId: CommentThreadId(
                            context.playerValue.current.id,
                            CommentType.song,
                            payload: CommentThreadPayload.music(context.playerValue.current),
                          ),
                        )));
              }),
        ],
      ),
    );
  }
}
