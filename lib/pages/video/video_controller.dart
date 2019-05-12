import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';

import 'video_player_model.dart';

typedef void MvControllerChangeCallback(bool show);

///祖先节点必须存在 [VideoPlayerModel]
///[top] 从顶部滑出
///[center] 更改透明度浮现
///[bottom] 从底部滑出
class AnimatedMvController extends StatefulWidget {
  final Widget top;
  final Widget bottom;
  final Widget center;

  ///当 controller 隐藏的是否是否显示底部的播放进度条
  final bool showBottomIndicator;

  final MvControllerChangeCallback beforeChange;
  final MvControllerChangeCallback afterChange;

  const AnimatedMvController(
      {Key key,
      @required this.top,
      @required this.bottom,
      @required this.center,
      this.beforeChange,
      this.afterChange,
      this.showBottomIndicator = false})
      : super(key: key);

  @override
  _AnimatedMvControllerState createState() => _AnimatedMvControllerState();
}

class _AnimatedMvControllerState extends State<AnimatedMvController>
    with SingleTickerProviderStateMixin {
  ///ui显示和隐藏的动画,lowerBound代表隐藏
  AnimationController _controller;

  CancelableOperation _hideOperation;

  //完全显示
  bool get _show => _controller.status == AnimationStatus.completed;

  //完全隐藏
  bool get _hide => _controller.status == AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.afterChange != null) widget.afterChange(true);
        _hideDelay();
      } else if (status == AnimationStatus.dismissed) {
        if (widget.afterChange != null) widget.afterChange(false);
      }
    });
    _controller.forward(from: 0);
  }

  void _setUiVisibility(bool show) {
    if (show) {
      if (widget.beforeChange != null) widget.beforeChange(true);
      _controller.forward(from: _controller.value);
    } else {
      if (widget.beforeChange != null) widget.beforeChange(false);
      _controller.reverse(from: _controller.value);
    }
  }

  ///当控制器可见时，3s后隐藏
  void _hideDelay() {
    if (_controller.status == AnimationStatus.dismissed) {
      //already hidden
      return;
    }
    _hideOperation?.cancel();
    _hideOperation = CancelableOperation.fromFuture(
        Future.delayed(const Duration(seconds: 3)))
      ..value.whenComplete(() {
        _setUiVisibility(false);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideOperation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) {
          _hideDelay();
        },
        onDoubleTap: () {
          final controller = VideoPlayerModel.of(context).videoPlayerController;
          final value = controller.value;
          if (value.initialized) {
            if (value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
          }
        },
        onTap: () {
          if (_show) {
            _setUiVisibility(false);
          } else if (_hide) {
            _setUiVisibility(true);
          }
        },
        child: ClipRect(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  FractionalTranslation(
                      child: widget.top,
                      translation: Offset(0, _controller.value - 1)),
                  Expanded(
                    child: IgnorePointer(
                      ignoring: _controller.value <= 0.1,
                      child: Opacity(
                          opacity: _controller.value,
                          child: Center(child: widget.center)),
                    ),
                  ),
                  FractionalTranslation(
                      child: widget.bottom,
                      translation: Offset(0, 1 - _controller.value))
                ],
              ),
              _buildBottomIndicator(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIndicator(BuildContext context) {
    double progress;
    final playerValue = VideoPlayerModel.of(context).playerValue;
    if (playerValue.initialized) {
      progress = playerValue.position.inMilliseconds /
          playerValue.duration.inMilliseconds;
    }

    return Visibility(
      visible: widget.showBottomIndicator &&
          _controller.status == AnimationStatus.dismissed,
      child: Column(
        children: <Widget>[
          Spacer(),
          Container(
            height: 4,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
