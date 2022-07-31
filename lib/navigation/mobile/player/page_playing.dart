import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../extension.dart';
import '../../../material.dart';
import '../../../pages/page_playing_list.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../common/player/cover.dart';
import '../../common/player/lyric_view.dart';
import '../../common/player/player_actions.dart';
import '../../common/player_progress.dart';
import 'background.dart';

class PlayingPage extends ConsumerWidget {
  const PlayingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(playerStateProvider).playingTrack;
    if (current == null) {
      WidgetsBinding.instance.scheduleFrameCallback((_) {
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
              children: [
                PlayingTitle(music: current),
                _CenterSection(music: current),
                const PlayingOperationBar(),
                const DurationProgressBar(),
                const PlayerControllerBar(),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).viewPadding.bottom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///player controller
/// pause,play,play next,play previous...
class PlayerControllerBar extends ConsumerWidget {
  const PlayerControllerBar({super.key});

  Widget getPlayModeIcon(BuildContext context, Color? color) {
    // TODO: implement getPlayModeIcon
    return Icon(Icons.shuffle, color: color);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).primaryIconTheme.color;

    final iconPlayPause = PlayingIndicator(
      playing: IconButton(
        tooltip: '暂停',
        iconSize: 40,
        icon: Icon(
          Icons.pause_circle_outline,
          color: color,
        ),
        onPressed: () {
          ref.read(playerProvider).pause();
        },
      ),
      pausing: IconButton(
        tooltip: '播放',
        iconSize: 40,
        icon: Icon(
          Icons.play_circle_outline,
          color: color,
        ),
        onPressed: () {
          ref.read(playerProvider).play();
        },
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            splashRadius: 24,
            icon: getPlayModeIcon(context, color),
            onPressed: () {
              // FIXME
              // context.player.setPlayMode(context.playMode.next);
            },
          ),
          IconButton(
            iconSize: 36,
            splashRadius: 24,
            tooltip: context.strings.skipToPrevious,
            icon: Icon(
              Icons.skip_previous,
              color: color,
            ),
            onPressed: () {
              ref.read(playerProvider).skipToPrevious();
            },
          ),
          iconPlayPause,
          IconButton(
            tooltip: context.strings.skipToNext,
            iconSize: 36,
            splashRadius: 24,
            icon: Icon(
              Icons.skip_next,
              color: color,
            ),
            onPressed: () {
              ref.read(playerProvider).skipToNext();
            },
          ),
          IconButton(
            tooltip: context.strings.playingList,
            splashRadius: 24,
            icon: Icon(
              Icons.menu,
              color: color,
            ),
            onPressed: () {
              PlayingListDialog.show(context);
            },
          ),
        ],
      ),
    );
  }
}

final _isShowLyricProvider = StateProvider((ref) => false);

class _CenterSection extends ConsumerWidget {
  const _CenterSection({super.key, required this.music});

  final Track music;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLyric = ref.watch(_isShowLyricProvider);
    return Expanded(
      child: AnimatedCrossFade(
        crossFadeState:
            showLyric ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        layoutBuilder: (
          Widget topChild,
          Key topChildKey,
          Widget bottomChild,
          Key bottomChildKey,
        ) {
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
          onTap: () {
            ref.read(_isShowLyricProvider.notifier).state = !showLyric;
          },
          child: AlbumCover(music: music),
        ),
        secondChild: PlayingLyricView(
          music: music,
          textStyle: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(height: 2, fontSize: 16, color: Colors.white),
          onTap: () {
            ref.read(_isShowLyricProvider.notifier).state = !showLyric;
          },
        ),
      ),
    );
  }
}

class PlayingTitle extends ConsumerWidget {
  const PlayingTitle({super.key, required this.music});

  final Track music;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      elevation: 0,
      leading: const BackButton(),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            music.name,
            style: context.primaryTextTheme.titleMedium,
          ),
          InkWell(
            onTap: () =>
                ref.read(navigatorProvider.notifier).navigateToArtistDetail(
                      context: context,
                      artists: music.artists,
                    ),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    music.displaySubtitle,
                    style: context.primaryTextTheme.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, size: 17),
              ],
            ),
          )
        ],
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
