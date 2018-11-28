import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:video_player/video_player.dart';

class PlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Quiet(
        child: Stack(
          children: <Widget>[
            _BlurBackground(),
            Material(
              color: Colors.transparent,
              child: Column(
                children: <Widget>[
                  _PlayingTitle(),
                  Spacer(),
                  _AlbumCover(),
                  Spacer(),
                  _OperationBar(),
                  _DurationProgressBar(),
                  _ControllerBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControllerBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryIconTheme.color;
    var state = PlayerState.of(context).value.state;

    Widget iconPlayPause;
    if (state.isPlaying) {
      iconPlayPause = IconButton(
          tooltip: "暂停",
          iconSize: 40,
          icon: Icon(
            Icons.pause_circle_outline,
            color: color,
          ),
          onPressed: () {
            quiet.pause();
          });
    } else if (state.isBuffering) {
      iconPlayPause = SizedBox(
        height: 40,
        width: 40,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      iconPlayPause = IconButton(
          tooltip: "播放",
          iconSize: 40,
          icon: Icon(
            Icons.play_circle_outline,
            color: color,
          ),
          onPressed: () {
            quiet.play();
          });
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
              icon: Icon(
                Icons.shuffle,
                color: color,
              ),
              onPressed: () {}),
          IconButton(
              iconSize: 36,
              icon: Icon(
                Icons.skip_previous,
                color: color,
              ),
              onPressed: () {
                quiet.playPrevious();
              }),
          iconPlayPause,
          IconButton(
              tooltip: "下一曲",
              iconSize: 36,
              icon: Icon(
                Icons.skip_next,
                color: color,
              ),
              onPressed: () {
                quiet.playNext();
              }),
          IconButton(
              tooltip: "当前播放列表",
              icon: Icon(
                Icons.menu,
                color: color,
              ),
              onPressed: () {}),
        ],
      ),
    );
  }
}

class _DurationProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).primaryTextTheme;
    var state = PlayerState.of(context).value.state;

    Widget progressIndicator;

    String durationText;
    String positionText;

    if (state.initialized) {
      var duration = state.duration.inMilliseconds;
      var position = state.position.inMilliseconds;

      durationText = getTimeStamp(duration);
      positionText = getTimeStamp(position);

      int maxBuffering = 0;
      for (DurationRange range in state.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          LinearProgressIndicator(
            value: maxBuffering / duration,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            backgroundColor: Colors.white12,
          ),
          LinearProgressIndicator(
            value: position / duration,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        backgroundColor: Colors.transparent,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: <Widget>[
          Text(positionText ?? "00:00", style: theme.body1),
          Padding(padding: EdgeInsets.only(left: 8)),
          Expanded(
            child: progressIndicator,
          ),
          Padding(padding: EdgeInsets.only(left: 8)),
          Text(durationText ?? "00:00", style: theme.body1),
        ],
      ),
    );
  }
}

class _OperationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconColor = Theme.of(context).primaryIconTheme.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: Icon(
              Icons.favorite_border,
              color: iconColor,
            ),
            onPressed: null),
        IconButton(
            icon: Icon(
              Icons.file_download,
              color: iconColor,
            ),
            onPressed: null),
        IconButton(
            icon: Icon(
              Icons.comment,
              color: iconColor,
            ),
            onPressed: null),
        IconButton(
            icon: Icon(
              Icons.share,
              color: iconColor,
            ),
            onPressed: null),
      ],
    );
  }
}

class _AlbumCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var music = PlayerState.of(context).value.current;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 64),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipOval(
          child: CachedNetworkImage(imageUrl: music.album.coverImageUrl),
        ),
      ),
    );
  }
}

class _BlurBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var music = PlayerState.of(context).value.current;
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: CachedNetworkImageProvider(music.album.coverImageUrl),
        fit: BoxFit.cover,
      )),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 7, sigmaX: 7),
        child: Container(
          color: Colors.black87.withOpacity(0.2),
        ),
      ),
    );
  }
}

class _PlayingTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var music = PlayerState.of(context).value.current;
    return AppBar(
      elevation: 0,
      leading: IconButton(
          tooltip: '返回上一层',
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          onPressed: () => Navigator.pop(context)),
      title: Text(music.title),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      actions: <Widget>[
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: Text("下载"),
              ),
            ];
          },
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).primaryIconTheme.color,
          ),
        )
      ],
    );
  }
}
