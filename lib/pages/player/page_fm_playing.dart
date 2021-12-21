import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/material.dart';
import 'package:quiet/pages/artists/page_artist_detail.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/repository.dart';

import '../../navigation/common/like_button.dart';
import '../../navigation/common/player/lyric_view.dart';
import '../../navigation/common/player_progress.dart';
import 'background.dart';

/// FM 播放页面
class PagePlayingFm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(playingTrackProvider);
    if (current == null) {
      WidgetsBinding.instance!.scheduleFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return Container();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          BlurBackground(music: current),
          Material(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                AppBar(
                  title: const Text("私人FM"),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                const _CenterSection(),
                const SizedBox(height: 8),
                DurationProgressBar(),
                _FmControllerBar(),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterSection extends HookConsumerWidget {
  const _CenterSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLyric = useState(false);

    return Expanded(
      child: AnimatedCrossFade(
        crossFadeState: showLyric.value
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild,
            Key bottomChildKey) {
          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Center(
                key: bottomChildKey,
                child: bottomChild,
              ),
              Center(
                key: topChildKey,
                child: topChild,
              ),
            ],
          );
        },
        duration: const Duration(milliseconds: 300),
        firstChild: GestureDetector(
          onTap: () => showLyric.value = !showLyric.value,
          child: const _FmCover(),
        ),
        secondChild: PlayingLyricView(
          music: ref.watch(playingTrackProvider)!,
          textStyle: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(height: 2, fontSize: 16, color: Colors.white),
          onTap: () => showLyric.value = !showLyric.value,
        ),
      ),
    );
  }
}

class _FmCover extends ConsumerWidget {
  const _FmCover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(playingTrackProvider)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Image(
                image: CachedImage(music.imageUrl!),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) {
                    child = Container(child: child);
                  }
                  return child;
                },
              ),
            ),
          ),
        ),
        Text(
          music.name,
          style: Theme.of(context).primaryTextTheme.subtitle1,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            launchArtistDetailPage(context, music.artists);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  music.displaySubtitle,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .caption!
                      .copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right,
                  size: 17,
                  color: Theme.of(context).primaryTextTheme.caption!.color),
            ],
          ),
        )
      ],
    );
  }
}

class _FmControllerBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).primaryIconTheme.color;
    final iconPlayPause = PlayingIndicator(
      playing: IconButton(
          tooltip: "暂停",
          iconSize: 40,
          icon: Icon(
            Icons.pause_circle_outline,
            color: color,
          ),
          onPressed: () {
            ref.read(playerProvider).pause();
          }),
      pausing: IconButton(
          tooltip: "播放",
          iconSize: 40,
          icon: Icon(
            Icons.play_circle_outline,
            color: color,
          ),
          onPressed: () {
            ref.read(playerProvider).play();
          }),
      buffering: const SizedBox(
        height: 56,
        width: 56,
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: color,
              ),
              onPressed: () {
                toast('已加入不喜欢列表，以后将减少类似的推荐。');
                ref.read(playerProvider).skipToNext();
              }),
          LikeButton.current(context),
          iconPlayPause,
          IconButton(
              tooltip: "下一曲",
              icon: Icon(
                Icons.skip_next,
                color: color,
              ),
              onPressed: () {
                ref.read(playerProvider).skipToNext();
              }),
          IconButton(
              tooltip: "当前播放列表",
              icon: Icon(
                Icons.comment,
                color: color,
              ),
              onPressed: () {
                // TODO
              }),
        ],
      ),
    );
  }
}
