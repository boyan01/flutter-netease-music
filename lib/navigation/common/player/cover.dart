import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../media/tracks/tracks_player.dart';
import '../../../providers/player_provider.dart';
import '../../../repository/cached_image.dart';
import '../../../repository/data/track.dart';

///播放页面歌曲封面
class AlbumCover extends ConsumerStatefulWidget {
  const AlbumCover({super.key, required this.music});

  final Track music;

  @override
  ConsumerState createState() => _AlbumCoverState();
}

class _AlbumCoverState extends ConsumerState<AlbumCover>
    with TickerProviderStateMixin {
  //cover needle controller
  late AnimationController _needleController;

  //cover needle in and out animation
  late Animation<double> _needleAnimation;

  ///music change transition animation;
  AnimationController? _translateController;

  bool _needleAttachCover = false;

  bool _coverRotating = false;

  ///专辑封面X偏移量
  ///[-screenWidth/2,screenWidth/2]
  /// 0 表示当前播放音乐封面
  /// -screenWidth/2 - 0 表示向左滑动 |_coverTranslateX| 距离，即滑动显示后一首歌曲的封面
  double _coverTranslateX = 0;

  bool _beDragging = false;

  bool _previousNextDirty = true;

  ///滑动切换音乐效果上一个封面
  Track? _previous;

  ///当前播放中的音乐
  Track? _current;

  ///滑动切换音乐效果下一个封面
  Track? _next;

  late TracksPlayer _player;

  RemoveListener? _removeListener;

  @override
  void initState() {
    super.initState();
    // TODO(@bin): remove this.
    _player = ref.read(playerProvider);
    _needleAttachCover = _player.isPlaying;
    _needleController = AnimationController(
      /*preset need position*/
      value: _needleAttachCover ? 1.0 : 0.0,
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _needleAnimation = Tween<double>(begin: -1 / 12, end: 0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_needleController);

    _current = widget.music;
    _invalidatePn();
    _removeListener = _player.addListener((_) => _checkNeedleAndCoverStatus());
  }

  /// invalidate previous and next music cover...
  /// TODO should invalidate on playMode change.
  Future<void> _invalidatePn() async {
    if (!_previousNextDirty) {
      return;
    }
    _previousNextDirty = false;
    _previous = await _player.getPreviousTrack();
    _next = await _player.getNextTrack();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(AlbumCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_current == widget.music) {
      _invalidatePn();
      return;
    }
    var offset = 0.0;
    if (widget.music == _previous) {
      offset = MediaQuery.of(context).size.width;
    } else if (widget.music == _next) {
      offset = -MediaQuery.of(context).size.width;
    }
    _animateCoverTranslateTo(
      offset,
      onCompleted: () {
        setState(() {
          _coverTranslateX = 0;
          _current = widget.music;
          _invalidatePn();
        });
      },
    );
  }

  // update needle and cover for current player state
  void _checkNeedleAndCoverStatus() {
    // needle is should attach to cover
    final attachToCover =
        _player.isPlaying && !_beDragging && _translateController == null;
    _rotateNeedle(attachToCover);

    //handle album cover animation
    final isPlaying = _player.isPlaying;
    setState(() {
      _coverRotating = isPlaying && _needleAttachCover;
    });
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
    _removeListener?.call();
    _needleController.dispose();
    _translateController?.dispose();
    _translateController = null;
    super.dispose();
  }

  static const double kHeightSpaceAlbumTop = 100;

  void _animateCoverTranslateTo(double des, {void Function()? onCompleted}) {
    _translateController?.dispose();
    _translateController = null;
    _translateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final animation =
        Tween(begin: _coverTranslateX, end: des).animate(_translateController!);
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
    _translateController!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        assert(
          constraints.maxWidth.isFinite,
          'the width of cover layout should be constrained!',
        );
        return ClipRect(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _build(context, constraints.maxWidth),
          ),
        );
      },
    );
  }

  Widget _build(BuildContext context, double layoutWidth) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onHorizontalDragStart: (detail) {
            _beDragging = true;
            _checkNeedleAndCoverStatus();
          },
          onHorizontalDragUpdate: (detail) {
            if (_beDragging) {
              setState(() {
                _coverTranslateX += detail.primaryDelta!;
              });
            }
          },
          onHorizontalDragEnd: (detail) {
            _beDragging = false;

            //左右切换封面滚动速度阈值
            final vThreshold =
                1.0 / (0.050 * MediaQuery.of(context).devicePixelRatio);

            final sameDirection =
                (_coverTranslateX > 0 && detail.primaryVelocity! > 0) ||
                    (_coverTranslateX < 0 && detail.primaryVelocity! < 0);
            if (_coverTranslateX.abs() > layoutWidth / 2 ||
                (sameDirection && detail.primaryVelocity!.abs() > vThreshold)) {
              var des = MediaQuery.of(context).size.width;
              if (_coverTranslateX < 0) {
                des = -des;
              }
              _animateCoverTranslateTo(
                des,
                onCompleted: () {
                  setState(() {
                    //reset translateX to 0 when animation complete
                    _coverTranslateX = 0;
                    if (des > 0) {
                      _current = _previous;
                      ref.read(playerProvider).skipToPrevious();
                    } else {
                      _current = _next;
                      ref.read(playerProvider).skipToNext();
                    }
                    _previousNextDirty = true;
                  });
                },
              );
            } else {
              //animate [_coverTranslateX] to 0
              _animateCoverTranslateTo(
                0,
                onCompleted: _checkNeedleAndCoverStatus,
              );
            }
          },
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.only(
              left: 64,
              right: 64,
              top: kHeightSpaceAlbumTop,
            ),
            child: Stack(
              children: <Widget>[
                Transform.scale(
                  scale: 1.035,
                  child: const AspectRatio(
                    aspectRatio: 1,
                    child: ClipOval(
                      child: ColoredBox(
                        color: Colors.white10,
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(_coverTranslateX - layoutWidth, 0),
                  child: _RotationCoverImage(rotating: false, music: _previous),
                ),
                Transform.translate(
                  offset: Offset(_coverTranslateX, 0),
                  child: _RotationCoverImage(
                    rotating: _coverRotating && !_beDragging,
                    music: _current,
                  ),
                ),
                Transform.translate(
                  offset: Offset(_coverTranslateX + layoutWidth, 0),
                  child: _RotationCoverImage(rotating: false, music: _next),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: const Offset(40, -15),
              child: RotationTransition(
                turns: _needleAnimation,
                alignment:
                    //44,37 是针尾的圆形的中心点像素坐标, 273,402是playing_page_needle.png的宽高
                    //所以对此计算旋转中心点的偏移,以保重旋转动画的中心在针尾圆形的中点
                    const Alignment(-1 + 44 * 2 / 273, -1 + 37 * 2 / 402),
                child: Image.asset(
                  'assets/playing_page_needle.png',
                  height: kHeightSpaceAlbumTop * 1.8,
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
  const _RotationCoverImage({
    super.key,
    required this.rotating,
    required this.music,
  });

  final bool rotating;
  final Track? music;

  @override
  _RotationCoverImageState createState() => _RotationCoverImageState();
}

class _RotationCoverImageState extends State<_RotationCoverImage>
    with SingleTickerProviderStateMixin {
  //album cover rotation
  double rotation = 0;

  //album cover rotation animation
  late AnimationController controller;

  @override
  void didUpdateWidget(_RotationCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rotating) {
      controller.forward(from: controller.value);
    } else {
      controller.stop();
    }
    if (widget.music != oldWidget.music) {
      controller.value = 0;
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )
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
    if (widget.rotating) {
      controller.forward(from: controller.value);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider image;
    if (widget.music == null || widget.music!.imageUrl == null) {
      image = const AssetImage('assets/playing_page_disc.png');
    } else {
      image = CachedImage(widget.music!.imageUrl.toString());
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
            foregroundDecoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/playing_page_disc.png'),
              ),
            ),
            padding: const EdgeInsets.all(30),
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
