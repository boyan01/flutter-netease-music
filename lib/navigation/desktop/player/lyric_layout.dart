import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/common/navigation_target.dart';
import 'package:quiet/providers/navigator_provider.dart';
import 'package:quiet/repository.dart';

import '../../common/player/lyric_view.dart';
import '../widgets/highlight_clickable_text.dart';

class LyricLayout extends ConsumerWidget {
  const LyricLayout({
    Key? key,
    required this.track,
  }) : super(key: key);

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Row(
            children: [
              Flexible(
                child: MouseHighlightText(
                  style: context.textTheme.caption,
                  highlightStyle: context.textTheme.caption!.copyWith(
                    color: context.textTheme.bodyMedium!.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  children: [
                    MouseHighlightSpan.normal(
                        text: '${context.strings.album}:'),
                    MouseHighlightSpan.widget(widget: const SizedBox(width: 4)),
                    MouseHighlightSpan.highlight(
                      text: track.album?.name ?? '',
                      onTap: () {
                        final id = track.album?.id;
                        if (id == null) {
                          return;
                        }
                        ref
                            .read(navigatorProvider.notifier)
                            .navigate(NavigationTargetAlbumDetail(id));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: MouseHighlightText(
                  style: context.textTheme.caption,
                  highlightStyle: context.textTheme.caption!.copyWith(
                    color: context.textTheme.bodyMedium!.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  children: [
                    MouseHighlightSpan.normal(
                        text: '${context.strings.artists}:'),
                    MouseHighlightSpan.widget(widget: const SizedBox(width: 4)),
                    ...track.artists
                        .map((artist) => MouseHighlightSpan.highlight(
                              text: artist.name,
                              onTap: () {
                                if (artist.id == 0) {
                                  return;
                                }
                                ref.read(navigatorProvider.notifier).navigate(
                                    NavigationTargetArtistDetail(artist.id));
                              },
                            ))
                        .separated(MouseHighlightSpan.normal(text: '/')),
                  ],
                ),
              ),
            ],
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
