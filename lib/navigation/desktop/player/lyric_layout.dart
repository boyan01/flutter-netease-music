import 'package:flutter/material.dart';
import 'package:quiet/extension.dart';

import '../../common/player/lyric_view.dart';

class LyricLayout extends StatelessWidget {
  const LyricLayout({Key? key}) : super(key: key);

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
