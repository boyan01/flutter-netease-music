library player;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material.dart';
import 'package:quiet/navigation/common/progress_track_container.dart';
import 'package:quiet/pages/page_playing_list.dart';
import 'package:quiet/providers/lyric_provider.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/repository.dart';

import '../../navigation/common/like_button.dart';

@visibleForTesting
class DisableBottomController extends StatelessWidget {
  const DisableBottomController({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return child!;
  }
}

class BoxWithBottomPlayerController extends StatelessWidget {
  const BoxWithBottomPlayerController(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.findAncestorWidgetOfExactType<DisableBottomController>() !=
        null) {
      return child;
    }

    final media = MediaQuery.of(context);
    //hide bottom player controller when view inserts
    //bottom too height (such as typing with soft keyboard)
    final bool hide = isSoftKeyboardDisplay(media);
    return Column(
      children: <Widget>[
        Expanded(
          child: MediaQuery(
            data: media.copyWith(
              viewInsets: media.viewInsets.copyWith(bottom: 0),
              padding: media.padding.copyWith(bottom: hide ? null : 0),
            ),
            child: child,
          ),
        ),
        if (!hide) BottomControllerBar(bottomPadding: media.padding.bottom),
        SizedBox(height: media.viewInsets.bottom)
      ],
    );
  }
}

///底部当前音乐播放控制栏
class BottomControllerBar extends ConsumerWidget {
  const BottomControllerBar({
    Key? key,
    this.bottomPadding = 0,
  }) : super(key: key);

  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(playingTrackProvider);
    final queue = ref.watch(playingListProvider);
    if (music == null) {
      return Container();
    }
    return InkWell(
      onTap: () {
        context.rootNavigator
            .pushNamed(queue.isFM ? pageFmPlaying : pagePlaying);
      },
      child: Card(
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4.0),
            topRight: Radius.circular(4.0),
          ),
        ),
        child: Container(
          height: 56,
          margin: EdgeInsets.only(bottom: bottomPadding),
          child: Row(
            children: <Widget>[
              QuietHero(
                tag: "album_cover",
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                      child: music.imageUrl == null
                          ? Container(color: Colors.grey)
                          : Image(
                              fit: BoxFit.cover,
                              image: CachedImage(music.imageUrl!),
                            ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Spacer(),
                      Text(
                        music.name,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      const Padding(padding: EdgeInsets.only(top: 2)),
                      DefaultTextStyle(
                        maxLines: 1,
                        style: Theme.of(context).textTheme.caption!,
                        child: ProgressTrackingContainer(
                          builder: (context) =>
                              _SubTitleOrLyric(music.displaySubtitle),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              _PauseButton(),
              if (queue.isFM)
                LikeButton.current(context)
              else
                IconButton(
                    tooltip: "当前播放列表",
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      PlayingListDialog.show(context);
                    }),
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
