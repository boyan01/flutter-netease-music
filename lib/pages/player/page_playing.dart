import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:music_player/music_player.dart';
import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/material/playing_indicator.dart';
import 'package:quiet/pages/artists/page_artist_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/pages/page_playing_list.dart';
import 'package:quiet/pages/player/page_playing_landscape.dart';
import 'package:quiet/part/part.dart';

import 'background.dart';
import 'cover.dart';
import 'lyric.dart';
import 'player_progress.dart';

///歌曲播放页面
class PlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final current = context.listenPlayerValue.current;
    if (current == null) {
      WidgetsBinding.instance.scheduleFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return Container();
    }
    if (context.isLandscape) {
      return LandscapePlayingPage();
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
                PlayingOperationBar(),
                const SizedBox(height: 10),
                DurationProgressBar(),
                PlayerControllerBar(),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
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
  Widget getPlayModeIcon(BuildContext context, Color color) {
    return Icon(context.playMode.icon, color: color);
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryIconTheme.color;

    final iconPlayPause = PlayingIndicator(
      playing: IconButton(
          tooltip: "暂停",
          iconSize: 40,
          icon: Icon(
            Icons.pause_circle_outline,
            color: color,
          ),
          onPressed: () {
            context.transportControls.pause();
          }),
      pausing: IconButton(
          tooltip: "播放",
          iconSize: 40,
          icon: Icon(
            Icons.play_circle_outline,
            color: color,
          ),
          onPressed: () {
            context.transportControls.play();
          }),
      buffering: Container(
        height: 56,
        width: 56,
        child: Center(
          child: Container(height: 24, width: 24, child: CircularProgressIndicator()),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
              icon: getPlayModeIcon(context, color),
              onPressed: () {
                context.transportControls.setPlayMode(context.playMode.next);
              }),
          IconButton(
              iconSize: 36,
              icon: Icon(
                Icons.skip_previous,
                color: color,
              ),
              onPressed: () {
                context.transportControls.skipToPrevious();
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
                context.transportControls.skipToNext();
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

class PlayingOperationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).primaryIconTheme.color;

    final music = context.listenPlayerValue.current;
    final liked = LikedSongList.contain(context, music);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: iconColor,
            ),
            onPressed: () {
              if (liked) {
                LikedSongList.of(context).dislikeMusic(music);
              } else {
                LikedSongList.of(context).likeMusic(music);
              }
            }),
        IconButton(
            icon: Icon(
              Icons.file_download,
              color: iconColor,
            ),
            onPressed: () {
              notImplemented(context);
            }),
        IconButton(
            icon: Icon(
              Icons.comment,
              color: iconColor,
            ),
            onPressed: () {
              if (music == null) {
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CommentPage(
                  threadId: CommentThreadId(music.id, CommentType.song, payload: CommentThreadPayload.music(music)),
                );
              }));
            }),
        IconButton(
            icon: Icon(
              Icons.share,
              color: iconColor,
            ),
            onPressed: () {
              notImplemented(context);
            }),
      ],
    );
  }
}

class _CenterSection extends StatefulWidget {
  final Music music;

  const _CenterSection({Key key, @required this.music}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CenterSectionState();
}

class _CenterSectionState extends State<_CenterSection> {
  static bool _showLyric = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedCrossFade(
        crossFadeState: _showLyric ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
          return Stack(
            overflow: Overflow.visible,
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
        duration: Duration(milliseconds: 300),
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

class PlayingLyricView extends StatelessWidget {
  final VoidCallback onTap;

  final Music music;

  const PlayingLyricView({Key key, this.onTap, @required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProgressTrackingContainer(builder: _buildLyric, player: context.player);
  }

  Widget _buildLyric(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.bodyText2.copyWith(height: 2, fontSize: 16, color: Colors.white);
    final playingLyric = PlayingLyric.of(context);

    if (playingLyric.hasLyric) {
      return LayoutBuilder(builder: (context, constraints) {
        final normalStyle = style.copyWith(color: style.color.withOpacity(0.7));
        //歌词顶部与尾部半透明显示
        return ShaderMask(
          shaderCallback: (rect) {
            return ui.Gradient.linear(Offset(rect.width / 2, 0), Offset(rect.width / 2, constraints.maxHeight), [
              const Color(0x00FFFFFF),
              style.color,
              style.color,
              const Color(0x00FFFFFF),
            ], [
              0.0,
              0.15,
              0.85,
              1
            ]);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Lyric(
              lyric: playingLyric.lyric,
              lyricLineStyle: normalStyle,
              highlight: style.color,
              position: context.playbackState.positionWithOffset,
              onTap: onTap,
              size: Size(constraints.maxWidth, constraints.maxHeight == double.infinity ? 0 : constraints.maxHeight),
              playing: context.playbackState.isPlaying,
            ),
          ),
        );
      });
    } else {
      return Container(
        child: Center(
          child: Text(playingLyric.message, style: style),
        ),
      );
    }
  }
}

class PlayingTitle extends StatelessWidget {
  final Music music;

  const PlayingTitle({Key key, @required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: AppBar(
        elevation: 0,
        primary: false,
        leading: IconButton(
            tooltip: '返回上一层',
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            onPressed: () => Navigator.pop(context)),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              music.title,
              style: TextStyle(fontSize: 17),
            ),
            InkWell(
              onTap: () {
                launchArtistDetailPage(context, music.artist);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(maxWidth: 200),
                    child: Text(
                      music.artist.map((a) => a.name).join('/'),
                      style: Theme.of(context).primaryTextTheme.bodyText2.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 17),
                ],
              ),
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text("下载"),
                ),
              ];
            },
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
          )
        ],
      ),
    );
  }
}
