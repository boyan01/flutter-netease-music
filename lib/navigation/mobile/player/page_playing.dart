import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material.dart';
import 'package:quiet/pages/page_playing_list.dart';
import 'package:quiet/repository.dart';

import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../common/player/cover.dart';
import '../../common/player/lyric_view.dart';
import '../../common/player/player_actions.dart';
import '../../common/player_progress.dart';
import 'background.dart';

class PlayingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.read(playerStateProvider).playingTrack;
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
                PlayerControllerBar(),
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
  Widget getPlayModeIcon(BuildContext context, Color? color) {
    // TODO: implement getPlayModeIcon
    return Icon(Icons.shuffle, color: color);
  }

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
              }),
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
              }),
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
              }),
          IconButton(
              tooltip: context.strings.playingList,
              splashRadius: 24,
              icon: Icon(
                Icons.menu,
                color: color,
              ),
              onPressed: () {
                PlayingListDialog.show(context);
              }),
        ],
      ),
    );
  }
}

class _CenterSection extends StatefulWidget {
  const _CenterSection({Key? key, required this.music}) : super(key: key);
  final Track music;

  @override
  State<StatefulWidget> createState() => _CenterSectionState();
}

class _CenterSectionState extends State<_CenterSection> {
  static bool _showLyric = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedCrossFade(
        crossFadeState:
            _showLyric ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
          onTap: () {
            setState(() {
              _showLyric = !_showLyric;
            });
          },
          child: AlbumCover(music: widget.music),
        ),
        secondChild: PlayingLyricView(
          music: widget.music,
          textStyle: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(height: 2, fontSize: 16, color: Colors.white),
          onTap: () {
            setState(() {
              _showLyric = !_showLyric;
            });
          },
        ),
      ),
    );
  }
}

class PlayingTitle extends ConsumerWidget {
  const PlayingTitle({Key? key, required this.music}) : super(key: key);
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
            onTap: () => ref
                .read(navigatorProvider.notifier)
                .navigateToArtistDetail(
                    context: context, artists: music.artists),
            child: Row(
              mainAxisSize: MainAxisSize.max,
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
