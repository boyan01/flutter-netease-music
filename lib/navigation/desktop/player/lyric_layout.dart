import 'package:flutter/material.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/repository.dart';

import '../../common/player/lyric_view.dart';

class LyricLayout extends StatelessWidget {
  const LyricLayout({
    Key? key,
    required this.track,
  }) : super(key: key);

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          Text(
            track.name,
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
                    message: track.album?.name,
                    child: Text(
                      track.album?.name ?? '',
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
                    message: track.artists.map((a) => a.name).join(', '),
                    child: Text(
                      track.artists.map((artist) => artist.name).join('/'),
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
              music: track,
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
