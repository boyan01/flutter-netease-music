import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:quiet/pages/page_comment.dart';
import 'package:quiet/pages/page_playing_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:quiet/service/channel_media_player.dart';

///歌曲播放页面
class PlayingPage extends StatefulWidget {
  @override
  _PlayingPageState createState() {
    return new _PlayingPageState();
  }
}

class _PlayingPageState extends State<PlayingPage> {
  Music _music;

  @override
  void initState() {
    super.initState();
    _music = quiet.value.current;
    quiet.addListener(_onPlayerStateChanged);
  }

  void _onPlayerStateChanged() {
    if (_music != quiet.value.current) {
      _music = quiet.value.current;
      if (_music == null) {
        Navigator.pop(context);
      } else {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _BlurBackground(music: _music),
          Material(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                _PlayingTitle(music: _music),
                _CenterSection(music: _music),
                _OperationBar(),
                Padding(padding: EdgeInsets.only(top: 10)),
                _DurationProgressBar(),
                _ControllerBar(),
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
class _ControllerBar extends StatelessWidget {
  Widget getPlayModeIcon(context, Color color) {
    var playMode = PlayerState.of(context, aspect: PlayerStateAspect.playMode)
        .value
        .playMode;
    switch (playMode) {
      case PlayMode.single:
        return Icon(
          Icons.repeat_one,
          color: color,
        );
      case PlayMode.sequence:
        return Icon(
          Icons.repeat,
          color: color,
        );
      case PlayMode.shuffle:
        return Icon(
          Icons.shuffle,
          color: color,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryIconTheme.color;
    var state =
        PlayerState.of(context, aspect: PlayerStateAspect.playbackState).value;

    final iconPlayPause = IndexedStack(
      index: state.isPlaying ? 0 : state.isBuffering ? 2 : 1,
      children: <Widget>[
        IconButton(
            tooltip: "暂停",
            iconSize: 40,
            icon: Icon(
              Icons.pause_circle_outline,
              color: color,
            ),
            onPressed: () {
              quiet.pause();
            }),
        IconButton(
            tooltip: "播放",
            iconSize: 40,
            icon: Icon(
              Icons.play_circle_outline,
              color: color,
            ),
            onPressed: () {
              quiet.play();
            }),
        Container(
          height: 56,
          width: 56,
          child: Center(
            child: Container(
                height: 24, width: 24, child: CircularProgressIndicator()),
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
              icon: getPlayModeIcon(context, color),
              onPressed: () {
                quiet.changePlayMode();
              }),
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
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return PlayingListDialog();
                    });
              }),
        ],
      ),
    );
  }
}

///a seek bar for current position
class _DurationProgressBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DurationProgressBarState();
}

class _DurationProgressBarState extends State<_DurationProgressBar> {
  bool isUserTracking = false;

  double trackingPosition = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).primaryTextTheme;
    var state = PlayerState.of(context).value;

    Widget progressIndicator;

    String durationText;
    String positionText;

    if (state.initialized) {
      var duration = state.duration.inMilliseconds;
      var position = isUserTracking
          ? trackingPosition.round()
          : state.position.inMilliseconds;

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
            value: position.toDouble().clamp(0.0, duration.toDouble()),
            min: 0.0,
            activeColor: theme.body1.color.withOpacity(0.75),
            inactiveColor: theme.caption.color.withOpacity(0.3),
            max: duration.toDouble(),
            onChangeStart: (value) {
              setState(() {
                isUserTracking = true;
                trackingPosition = value;
              });
            },
            onChanged: (value) {
              setState(() {
                trackingPosition = value;
              });
            },
            onChangeEnd: (value) async {
              isUserTracking = false;
              quiet.seekTo(value.round());
              if (!quiet.value.playWhenReady) {
                quiet.play();
              }
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

    var music = quiet.value.current;

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
            onPressed: () {
              if (music == null) {
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CommentPage(
                  threadId: CommentThreadId(music.id, CommentType.song,
                      playload: CommentThreadPayload.music(music)),
                );
              }));
            }),
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
  final Music music;

  const _CenterSection({Key key, @required this.music}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CenterSectionState();
}

class _CenterSectionState extends State<_CenterSection> {
  bool showLyric = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedCrossFade(
        crossFadeState:
            showLyric ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild,
            Key bottomChildKey) {
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
              showLyric = !showLyric;
            });
          },
          child: _AlbumCover(),
        ),
        secondChild: _CloudLyric(
          music: widget.music,
          onTap: () {
            setState(() {
              showLyric = !showLyric;
            });
          },
        ),
      ),
    );
  }
}

class _CloudLyric extends StatefulWidget {
  final VoidCallback onTap;

  final Music music;

  const _CloudLyric({Key key, this.onTap, @required this.music})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CloudLyricState();
}

class _CloudLyricState extends State<_CloudLyric> {
  ValueNotifier<int> position = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    quiet.addListener(_onMusicStateChanged);
    _onMusicStateChanged();
  }

  void _onMusicStateChanged() {
    position.value = quiet.value.position.inMilliseconds;
  }

  @override
  void dispose() {
    quiet.removeListener(_onMusicStateChanged);
    position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context)
        .textTheme
        .body1
        .copyWith(height: 1.5, fontSize: 16, color: Colors.white);

    return Loader<LyricContent>(
        key: Key("lyric_${widget.music.id}"),
        loadTask: () async {
          final str = await neteaseRepository.lyric(widget.music.id);
          if (str == null) {
            throw "暂无歌词";
          }
          return LyricContent.from(str);
        },
        failedWidgetBuilder: (context, result, msg) {
          if (!(msg is String)) {
            msg = "加载歌词出错";
          }
          return Container(
            child: Center(
              child: Text(msg, style: style),
            ),
          );
        },
        builder: (context, result) {
          return LayoutBuilder(builder: (context, constraints) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Lyric(
                lyric: result,
                lyricLineStyle:
                    style.copyWith(color: style.color.withOpacity(0.7)),
                highlight: style.color,
                position: position,
                onTap: widget.onTap,
                size: Size(
                    constraints.maxWidth,
                    constraints.maxHeight == double.infinity
                        ? 0
                        : constraints.maxHeight),
              ),
            );
          });
        });
  }
}

class _AlbumCover extends StatefulWidget {
  @override
  State createState() => _AlbumCoverState();
}

class _AlbumCoverState extends State<_AlbumCover>
    with TickerProviderStateMixin {
  //cover needle controller
  AnimationController _needleController;

  //cover needle in and out animation
  Animation<double> _needleAnimation;

  ///music change transition animation;
  AnimationController _translateController;

  bool _needleAttachCover = false;

  bool _coverRotating = false;

  ///专辑封面X偏移量
  ///[-screenWidth/2,screenWidth/2]
  double _coverTranslateX = 0;

  bool _beDragging = false;

  ///滑动切换音乐效果上一个封面
  Music _previous;

  ///当前播放中的音乐
  Music _current;

  ///滑动切换音乐效果下一个封面
  Music _next;

  @override
  void initState() {
    super.initState();

    bool attachToCover = quiet.value.playWhenReady &&
        (quiet.value.isPlaying || quiet.value.isBuffering);
    _needleController = AnimationController(
        /*preset need position*/
        value: attachToCover ? 1.0 : 0.0,
        vsync: this,
        duration: Duration(milliseconds: 500),
        animationBehavior: AnimationBehavior.normal);
    _needleAnimation = Tween<double>(begin: -1 / 12, end: 0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_needleController);

    quiet.addListener(_onMusicStateChanged);
    _current = quiet.value.current;
  }

  @override
  void didUpdateWidget(_AlbumCover oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _onMusicStateChanged() {
    var state = quiet.value;

    if (_current != state.current) {
      setState(() {
        _current = state.current;
      });
    }

    //handle album cover animation
    var _isPlaying = state.isPlaying;
    setState(() {
      _coverRotating = _isPlaying && _needleAttachCover;
    });

    bool attachToCover = state.playWhenReady &&
        (state.isPlaying || state.isBuffering) &&
        !_beDragging &&
        _translateController == null;
    _rotateNeedle(attachToCover);
  }

  ///rotate needle to (un)attach to cover image
  void _rotateNeedle(bool attachToCover) {
    if (_needleAttachCover == attachToCover) {
      return;
    }
    _needleAttachCover = attachToCover;
    if (attachToCover) {
      _needleController.forward(from: _needleController.value);
    } else {
      _needleController.reverse(from: _needleController.value);
    }
  }

  @override
  void dispose() {
    quiet.removeListener(_onMusicStateChanged);
    _needleController.dispose();
    super.dispose();
  }

  static const double HEIGHT_SPACE_ALBUM_TOP = 100;

  void _animateCoverTranslateTo(double des, {void onCompleted()}) {
    _translateController?.dispose();
    _translateController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    final animation =
        Tween(begin: _coverTranslateX, end: des).animate(_translateController);
    animation.addListener(() {
      setState(() {
        _coverTranslateX = animation.value;
      });
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _translateController?.dispose();
        _translateController = null;
        if (onCompleted != null) {
          onCompleted();
        }
      }
    });
    _translateController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onHorizontalDragStart: (detail) {
            _beDragging = true;
            _rotateNeedle(false);
          },
          onHorizontalDragUpdate: (detail) {
            if (_beDragging) {
              setState(() {
                _coverTranslateX += detail.primaryDelta;
              });
            }
          },
          onHorizontalDragEnd: (detail) {
            _beDragging = false;
            if (_coverTranslateX.abs() >
                MediaQuery.of(context).size.width / 2) {
              var des = MediaQuery.of(context).size.width;
              if (_coverTranslateX < 0) {
                des = -des;
              }
              _animateCoverTranslateTo(des, onCompleted: () {
                //reset translateX to 0 when animation complete
                _coverTranslateX = 0;
                if (des < 0) {
                  quiet.playPrevious();
                } else {
                  quiet.playNext();
                }
              });
            } else {
              //animate [_coverTranslateX] to 0
              _animateCoverTranslateTo(0);
            }
          },
          child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(
                  left: 64, right: 64, top: HEIGHT_SPACE_ALBUM_TOP),
              child: Stack(
                children: <Widget>[
                  Transform.translate(
                    offset: Offset(
                        _coverTranslateX - MediaQuery.of(context).size.width,
                        0),
                    child:
                        _RotationCoverImage(rotating: false, music: _previous),
                  ),
                  Transform.translate(
                    offset: Offset(_coverTranslateX, 0),
                    child: _RotationCoverImage(
                        rotating: _coverRotating && !_beDragging,
                        music: _current),
                  ),
                  Transform.translate(
                    offset: Offset(
                        _coverTranslateX + MediaQuery.of(context).size.width,
                        0),
                    child: _RotationCoverImage(rotating: false, music: _next),
                  ),
                ],
              )),
        ),
        ClipRect(
          child: Container(
            child: Align(
              alignment: Alignment(0, -1),
              child: Transform.translate(
                offset: Offset(40, -15),
                child: RotationTransition(
                  turns: _needleAnimation,
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

class _RotationCoverImage extends StatefulWidget {
  final bool rotating;
  final Music music;

  const _RotationCoverImage(
      {Key key, @required this.rotating, @required this.music})
      : assert(rotating != null),
        super(key: key);

  @override
  _RotationCoverImageState createState() => _RotationCoverImageState();
}

class _RotationCoverImageState extends State<_RotationCoverImage>
    with SingleTickerProviderStateMixin {
  //album cover rotation
  double rotation = 0;

  //album cover rotation animation
  AnimationController controller;

  @override
  void didUpdateWidget(_RotationCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rotating) {
      controller.forward(from: controller.value);
    } else {
      controller.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 20),
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
//    if (widget.rotating) {
//      controller.forward(from: controller.value);
//    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider image;
    if (widget.music == null || widget.music.album.coverImageUrl == null) {
      image = AssetImage("assets/playing_page_disc.png");
    } else {
      image = NeteaseImage(widget.music.album.coverImageUrl);
    }
    return Transform.rotate(
      angle: rotation,
      child: Material(
        elevation: 3,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(500),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            foregroundDecoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/playing_page_disc.png"))),
            padding: EdgeInsets.all(30),
            child: ClipOval(
              child: Image(
                image: image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BlurBackground extends StatelessWidget {
  final Music music;

  const _BlurBackground({Key key, @required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NeteaseImage(music.album.coverImageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.black54,
          Colors.black26,
          Colors.black45,
        ])),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
          child: Container(
            color: Colors.black87.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}

class _PlayingTitle extends StatelessWidget {
  final Music music;

  const _PlayingTitle({Key key, @required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
