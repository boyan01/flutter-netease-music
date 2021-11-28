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
          BlurBackground(music: context.playingTrack!),
          Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom +
                    MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Row(
                children: <Widget>[
                  Flexible(child: _LayoutCover()),
                  Flexible(child: _LayoutLyric()),
                ],
              ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AlbumCover(music: context.playingTrack!),
        ),
        const Spacer(),
        const SizedBox(height: 20),
        PlayerControllerBar(),
        const SizedBox(height: 20),
        DurationProgressBar(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _LayoutLyric extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        PlayingTitle(music: context.playingTrack!),
        Expanded(child: PlayingLyricView(music: context.playingTrack!)),
        PlayingOperationBar(),
        const SizedBox(height: 16),
      ],
    );
  }
}
