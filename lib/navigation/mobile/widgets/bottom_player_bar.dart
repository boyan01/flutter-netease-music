import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/common/navigation_target.dart';
import 'package:quiet/providers/navigator_provider.dart';
import 'package:quiet/repository.dart';

import '../../../material/player.dart';
import '../../../pages/page_playing_list.dart';
import '../../../providers/lyric_provider.dart';
import '../../../providers/player_provider.dart';
import '../../common/like_button.dart';
import '../../common/progress_track_container.dart';

class BottomPlayerBar extends ConsumerWidget {
  const BottomPlayerBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(playingTrackProvider);
    final queue = ref.watch(playingListProvider);
    if (music == null) {
      return Container();
    }
    return Material(
      child: InkWell(
        onTap: () => ref.read(navigatorProvider.notifier).navigate(queue.isFM
            ? NavigationTargetFmPlaying()
            : NavigationTargetPlaying()),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: Image(
                  fit: BoxFit.cover,
                  image: CachedImage(music.imageUrl!),
                  width: 48,
                  height: 48,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        music.name,
                        style: context.textTheme.bodyText2,
                      ),
                      const SizedBox(height: 2),
                      DefaultTextStyle(
                        maxLines: 1,
                        style: context.textTheme.caption!,
                        child: ProgressTrackingContainer(
                          builder: (context) => _SubTitleOrLyric(
                            music.displaySubtitle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _PauseButton(),
              if (queue.isFM)
                LikeButton(music: music)
              else
                IconButton(
                  tooltip: context.strings.playingList,
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    PlayingListDialog.show(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubTitleOrLyric extends ConsumerWidget {
  const _SubTitleOrLyric(this.subtitle, {Key? key}) : super(key: key);

  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(playingTrackProvider);
    final playingLyric = ref.watch(lyricProvider(music!.id).stateOrNull());
    if (playingLyric == null) {
      return Text(subtitle);
    }
    final position = ref.read(playerStateProvider.notifier).position;
    final line =
        playingLyric.getLineByTimeStamp(position?.inMilliseconds ?? 0, 0)?.line;
    if (line == null || line.isEmpty) {
      return Text(subtitle);
    }
    return Text(line);
  }
}

class _PauseButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayingIndicator(
      playing: IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () {
            ref.read(playerStateProvider.notifier).pause();
          }),
      pausing: IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {
            ref.read(playerStateProvider.notifier).play();
          }),
      buffering: Container(
        height: 24,
        width: 24,
        //to fit  IconButton min width 48
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(4),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
