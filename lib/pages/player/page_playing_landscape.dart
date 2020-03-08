import 'package:flutter/material.dart';
import 'package:quiet/component/player/player.dart';
import 'package:quiet/pages/player/cover.dart';

import 'background.dart';
import 'page_playing.dart';
import 'player_progress.dart';

class LandscapePlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          BlurBackground(music: context.listenPlayerValue.current),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: <Widget>[
                Flexible(child: _LayoutCover()),
                Flexible(child: _LayoutLyric()),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// left cover layout
class _LayoutCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AlbumCover(music: context.listenPlayerValue.current),
        Spacer(),
        PlayerControllerBar(),
        SizedBox(height: 16),
        DurationProgressBar(),
        SizedBox(height: 16),
      ],
    );
  }
}

class _LayoutLyric extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        PlayingTitle(music: context.listenPlayerValue.current),
        Expanded(child: PlayingLyricView(music: context.listenPlayerValue.current)),
        PlayingOperationBar(),
        SizedBox(height: 16),
      ],
    );
  }
}
