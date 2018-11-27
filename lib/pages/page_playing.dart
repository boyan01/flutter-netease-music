import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';

class PlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Quiet(
        child: Stack(
          children: <Widget>[
            _BlurBackground(),
            Column(
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
              onPressed: () {}),
          IconButton(
              tooltip: "播放/暂停",
              iconSize: 40,
              icon: Icon(
                Icons.play_circle_outline,
                color: color,
              ),
              onPressed: () {}),
          IconButton(
              tooltip: "下一曲",
              iconSize: 36,
              icon: Icon(
                Icons.skip_next,
                color: color,
              ),
              onPressed: () {}),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: <Widget>[
          Text("00:00", style: theme.body2),
          Padding(padding: EdgeInsets.only(left: 4)),
          Expanded(
            child: Slider(
              value: 0,
              activeColor: theme.body1.color,
              onChanged: (v) {},
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 4)),
          Text("00:00", style: theme.body2),
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
