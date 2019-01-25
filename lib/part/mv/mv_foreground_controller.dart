import 'package:async/async.dart';
import 'package:flutter/material.dart';

typedef void MvControllerChangeCallback(bool show);

class AnimatedMvController extends StatefulWidget {
  final Widget top;
  final Widget bottom;
  final Widget center;

  final MvControllerChangeCallback beforeChange;
  final MvControllerChangeCallback afterChange;

  const AnimatedMvController(
      {Key key,
      @required this.top,
      @required this.bottom,
      @required this.center,
      this.beforeChange,
      this.afterChange})
      : super(key: key);

  @override
  _AnimatedMvControllerState createState() => _AnimatedMvControllerState();
}

class _AnimatedMvControllerState extends State<AnimatedMvController>
    with SingleTickerProviderStateMixin {
  ///ui显示和隐藏的动画,lowerBound代表隐藏
  AnimationController _controller;

  CancelableOperation _hideOperation;

  bool get _show => _controller.status == AnimationStatus.completed;

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
    return ClipRect(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          debugPrint("on tap");
          if (_show) {
            _setUiVisibility(false);
          } else if (_hide) {
            _setUiVisibility(true);
          }
          _hideDelay();
        },
        child: Column(
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
      ),
    );
  }
}
