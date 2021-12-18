import 'package:flutter/material.dart';
import 'package:quiet/material.dart';
import 'package:quiet/pages/artists/page_artist_detail.dart';
import 'package:quiet/pages/page_playing_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository.dart';

import '../../navigation/common/player/cover.dart';
import '../../navigation/common/player/lyric_view.dart';
import '../../navigation/common/player/player_actions.dart';
import '../../navigation/common/player_progress.dart';
import 'background.dart';

///歌曲播放页面
class PlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final current = context.playingTrack;
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
                PlayingTitle(music: current),
                _CenterSection(music: current),
                const PlayingOperationBar(),
                DurationProgressBar(),
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
class PlayerControllerBar extends StatelessWidget {
  Widget getPlayModeIcon(BuildContext context, Color? color) {
    return Icon(context.playMode.icon, color: color);
  }

  @override
  Widget build(BuildContext context) {
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
            context.player.pause();
          }),
      pausing: IconButton(
          tooltip: "播放",
          iconSize: 40,
          icon: Icon(
            Icons.play_circle_outline,
            color: color,
          ),
          onPressed: () {
            context.player.play();
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
              icon: getPlayModeIcon(context, color),
              onPressed: () {
                // FIXME
                // context.player.setPlayMode(context.playMode.next);
              }),
          IconButton(
              iconSize: 36,
              icon: Icon(
                Icons.skip_previous,
                color: color,
              ),
              onPressed: () {
                context.player.skipToPrevious();
              }),
          iconPlayPause,
          IconButton(
              tooltip: "下一曲",
              iconSize: 36,
              icon: Icon(
                Icons.skip_next,
                color: color,
              ),
              onPressed: () {
                context.player.skipToNext();
              }),
          IconButton(
              tooltip: "当前播放列表",
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

class PlayingTitle extends StatelessWidget {
  const PlayingTitle({Key? key, required this.music}) : super(key: key);
  final Track music;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AppBar(
        elevation: 0,
        primary: false,
        leading: LandscapeWidgetSwitcher(
          portrait: (context) {
            return IconButton(
                tooltip: '返回上一层',
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).primaryIconTheme.color,
                ),
                onPressed: () => Navigator.pop(context));
          },
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              music.name,
              style: const TextStyle(fontSize: 17),
            ),
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
                          .bodyText2!
                          .copyWith(fontSize: 13),
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
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  child: Text("下载"),
                ),
              ];
            },
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
          ),
          LandscapeWidgetSwitcher(landscape: (context) {
            return CloseButton(onPressed: () {
              context.rootNavigator.maybePop();
            });
          })
        ],
      ),
    );
  }
}
