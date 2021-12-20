import 'package:flutter/material.dart';
import 'package:quiet/component.dart';

import '../common/player/cover.dart';
import '../common/player/lyric_view.dart';
import '../common/player/player_actions.dart';

class PagePlaying extends StatelessWidget {
  const PagePlaying({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      elevation: 10,
      child: Row(
        children: [
          Flexible(flex: 5, child: _LayoutCover()),
          Flexible(flex: 4, child: _LayoutLyric()),
        ],
      ),
    );
  }
}

// left cover layout
class _LayoutCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: IgnorePointer(
              ignoring: true,
              child: AlbumCover(music: context.playingTrack!),
            ),
          ),
          const Spacer(),
          PlayingOperationBar(iconColor: context.iconTheme.color),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class _LayoutLyric extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playingTrack = context.playingTrack!;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          Text(
            playingTrack.name,
            style: context.textTheme.headline6.bold,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          DefaultTextStyle(
            style: context.textTheme.caption!,
            child: Row(
              children: [
                Text('${context.strings.album}:'),
                const SizedBox(width: 4),
                Flexible(
                  child: Tooltip(
                    message: playingTrack.album?.name,
                    child: Text(
                      playingTrack.album?.name ?? '',
                      style: TextStyle(color: context.colorScheme.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Text('${context.strings.artists}:'),
                const SizedBox(width: 4),
                Flexible(
                  child: Tooltip(
                    message: playingTrack.artists.map((a) => a.name).join(', '),
                    child: Text(
                      playingTrack.artists
                          .map((artist) => artist.name)
                          .join('/'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: PlayingLyricView(
              music: playingTrack,
              textStyle: context.textTheme.bodyMedium!
                  .copyWith(height: 2, fontSize: 14),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
