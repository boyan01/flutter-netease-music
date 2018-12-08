import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:quiet/service/channel_media_player.dart';

class PlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Quiet(
        child: Stack(
          children: <Widget>[
            _BlurBackground(),
            Material(
              color: Colors.transparent,
              child: Column(
                children: <Widget>[
                  _PlayingTitle(),
                  _CenterSection(),
                  _OperationBar(),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  _DurationProgressBar(),
                  _ControllerBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///player controller
/// pause,play,play next,play previous...
class _ControllerBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryIconTheme.color;
    var state =
        PlayerState.of(context, aspect: PlayerStateAspect.play).value.state;

    Widget iconPlayPause;
    if (state.isPlaying) {
      iconPlayPause = IconButton(
          tooltip: "暂停",
          iconSize: 40,
          icon: Icon(
            Icons.pause_circle_outline,
            color: color,
          ),
          onPressed: () {
            quiet.pause();
          });
    } else if (state.isBuffering) {
      iconPlayPause = SizedBox(
        height: 40,
        width: 40,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      iconPlayPause = IconButton(
          tooltip: "播放",
          iconSize: 40,
          icon: Icon(
            Icons.play_circle_outline,
            color: color,
          ),
          onPressed: () {
            quiet.play();
          });
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
              icon: Icon(
                Icons.shuffle,
                color: color,
              ),
              onPressed: () {}),
          IconButton(
              iconSize: 36,
              icon: Icon(
                Icons.skip_previous,
                color: color,
              ),
              onPressed: () {
                quiet.playPrevious();
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
                quiet.playNext();
              }),
          IconButton(
              tooltip: "当前播放列表",
              icon: Icon(
                Icons.menu,
                color: color,
              ),
              onPressed: () {}),
        ],
      ),
    );
  }
}

class _DurationProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).primaryTextTheme;
    var state = PlayerState.of(context).value.state;

    Widget progressIndicator;

    String durationText;
    String positionText;

    if (state.initialized) {
      var duration = state.duration.inMilliseconds;
      var position = state.position.inMilliseconds;

      durationText = getTimeStamp(duration);
      positionText = getTimeStamp(position);

      int maxBuffering = 0;
      for (DurationRange range in state.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
//          LinearProgressIndicator(
//            value: maxBuffering / duration,
//            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
//            backgroundColor: Colors.white12,
//          ),
          Slider(
            value: position.toDouble(),
            min: 0.0,
            activeColor: theme.body1.color.withOpacity(0.75),
            inactiveColor: theme.caption.color.withOpacity(0.3),
            max: duration.toDouble(),
            onChanged: (value) {
              quiet.seekTo(value.round());
            },
          ),
        ],
      );
    } else {
      //a disable slider if media is not available
      progressIndicator = Slider(value: 0, onChanged: (_) => {});
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: <Widget>[
          Text(positionText ?? "00:00", style: theme.body1),
          Padding(padding: EdgeInsets.only(left: 4)),
          Expanded(
            child: progressIndicator,
          ),
          Padding(padding: EdgeInsets.only(left: 4)),
          Text(durationText ?? "00:00", style: theme.body1),
        ],
      ),
    );
  }
}

class _OperationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconColor = Theme.of(context).primaryIconTheme.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: Icon(
              Icons.favorite_border,
              color: iconColor,
            ),
            onPressed: null),
        IconButton(
            icon: Icon(
              Icons.file_download,
              color: iconColor,
            ),
            onPressed: null),
        IconButton(
            icon: Icon(
              Icons.comment,
              color: iconColor,
            ),
            onPressed: null),
        IconButton(
            icon: Icon(
              Icons.share,
              color: iconColor,
            ),
            onPressed: null),
      ],
    );
  }
}

class _CenterSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CenterSectionState();
}

class _CenterSectionState extends State<_CenterSection> {
  bool showLyric = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
          onTap: () {
            setState(() {
              showLyric = !showLyric;
            });
          },
          child: AnimatedCrossFade(
            crossFadeState: showLyric
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 300),
            firstChild: _AlbumCover(),
            secondChild: _CloudLyric(),
          )),
    );
  }
}

class _CloudLyric extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CloudLyricState();
}

class _CloudLyricState extends State<_CloudLyric> {
  Music music;

  LyricContent lyric;

  ///
  /// 0 -> loading
  /// 1 -> no lyric
  /// 2 -> load success
  /// 3 -> load failed
  int get state => _state;

  set state(int state) {
    if (state < 0 || state > 3 || state == _state) {
      return;
    }
    setState(() {
      _state = state;
    });
  }

  int _state = 0;

  ValueNotifier<int> position = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    quiet.addListener(_onMusicStateChanged);
    _onMusicStateChanged();
  }

  void _onMusicStateChanged() {
    if (quiet.value.current == music) {
      if (music == null) {
        state = 1;
      }
    } else {
      music = quiet.value.current;
      state = 0;
      neteaseRepository.lyric(music.id).then((content) {
        if (content == null) {
          state = 3;
        } else {
          lyric = LyricContent.from(content);
          state = 2;
        }
      });
    }

    position.value = quiet.value.state.position.inMilliseconds;
  }

  @override
  void dispose() {
    super.dispose();
    quiet.removeListener(_onMusicStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style =
        Theme.of(context).primaryTextTheme.body1.copyWith(height: 1.5);

    if (state == 2) {
      //load success
      return LayoutBuilder(builder: (context, constraints) {
        return Container(
          child: Lyric(
            lyric: lyric,
            lyricLineStyle: style.copyWith(color: style.color.withAlpha(189)),
            highlight: style.color,
            position: position,
            size: Size(
                constraints.maxWidth,
                constraints.maxHeight == double.infinity
                    ? 0
                    : constraints.maxHeight),
          ),
        );
      });
    }

    Widget widget;
    if (state == 0) {
      widget = Text(
        "加载中...",
        style: style,
      );
    } else if (state == 1) {
      widget = Text(
        "暂无歌词",
        style: style,
      );
    } else if (state == 3) {
      widget = Text(
        "加载失败",
        style: style,
      );
    } else {
      throw Exception("state erro :$state");
    }
    return Container(
      child: Center(
        child: widget,
      ),
    );
  }
}

class _AlbumCover extends StatefulWidget {
  @override
  State createState() => _AlbumCoverState();
}

class _AlbumCoverState extends State<_AlbumCover>
    with TickerProviderStateMixin {
  //album cover rotation animation
  AnimationController controller;

  //cover needle controller
  AnimationController needleController;

  //cover needle in and out animation
  Animation<double> needleAnimation;

  //album cover rotation
  double rotation = 0;

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    needleController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 700),
        animationBehavior: AnimationBehavior.normal);
    needleAnimation = Tween<double>(begin: -1 / 12, end: 0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(needleController);

    controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 13),
        animationBehavior: AnimationBehavior.normal)
      ..addListener(() {
        setState(() {
          rotation = controller.value * 2 * pi;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && controller.value == 1) {
          controller.forward(from: 0);
        }
      });

    quiet.addListener(_onMusicStateChanged);
  }

  void _onMusicStateChanged() {
    var state = quiet.value.state;

    var _isPlaying = state.isPlaying;

    //handle album cover animation
    if (_isPlaying && !isPlaying) {
      debugPrint("controller status : ${controller.status}");
      controller.forward(from: (rotation) / (2 * pi));
    } else if (!_isPlaying) {
      controller.stop();
    }

    //handle needle rotation animation
    if (isPlaying != _isPlaying) {
      if (_isPlaying) {
        needleController.forward(from: controller.value);
      } else {
        needleController.reverse(from: controller.value);
      }
    }

    isPlaying = _isPlaying;
  }

  @override
  void dispose() {
    super.dispose();
    quiet.removeListener(_onMusicStateChanged);
    controller.dispose();
    needleController.dispose();
  }

  static const double HEIGHT_SPACE_ALBUM_TOP = 100;

  @override
  Widget build(BuildContext context) {
    var music = PlayerState.of(context).value.current;
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: HEIGHT_SPACE_ALBUM_TOP),
          margin: const EdgeInsets.symmetric(horizontal: 64),
          child: Transform.rotate(
            angle: rotation,
            child: Material(
              elevation: 3,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(500),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 1,
                child: Hero(
                  tag: "album_cover",
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/playing_page_disc.png"))),
                    padding: EdgeInsets.all(30),
                    child: ClipOval(
                      child: Image(
                        image: NeteaseImage(music.album.coverImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ClipRect(
          child: Container(
            child: Align(
              alignment: Alignment(0, -1),
              child: Transform.translate(
                offset: Offset(40, -15),
                child: RotationTransition(
                  turns: needleAnimation,
                  alignment:
                      //44,37 是针尾的圆形的中心点像素坐标, 273,402是playing_page_needle.png的宽高
                      //所以对此计算旋转中心点的偏移,以保重旋转动画的中心在针尾圆形的中点
                      const Alignment(-1 + 44 * 2 / 273, -1 + 37 * 2 / 402),
                  child: Image.asset(
                    "assets/playing_page_needle.png",
                    height: HEIGHT_SPACE_ALBUM_TOP * 1.8,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _BlurBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var music = PlayerState.of(context).value.current;
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: NeteaseImage(music.album.coverImageUrl),
        fit: BoxFit.cover,
      )),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 7, sigmaX: 7),
        child: Container(
          color: Colors.black87.withOpacity(0.2),
        ),
      ),
    );
  }
}

class _PlayingTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var music =
        PlayerState.of(context, aspect: PlayerStateAspect.music).value.current;
    return AppBar(
      elevation: 0,
      leading: IconButton(
          tooltip: '返回上一层',
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          onPressed: () => Navigator.pop(context)),
      title: Text(music.title),
      backgroundColor: Colors.transparent,
      centerTitle: true,
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
    );
  }
}
