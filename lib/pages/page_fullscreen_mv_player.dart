import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiet/part/mv/mv_player_model.dart';
import 'package:quiet/part/part.dart';
import 'package:video_player/video_player.dart';

import 'page_mv_detail.dart';

///全屏播放界面
class FullScreenMvPlayer extends StatefulWidget {
  FullScreenMvPlayer({Key key}) : super(key: key);

  @override
  FullScreenMvPlayerState createState() {
    return new FullScreenMvPlayerState();
  }
}

class FullScreenMvPlayerState extends State<FullScreenMvPlayer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final value = MvPlayerModel.of(context).playerValue;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
                aspectRatio: value.initialized ? value.aspectRatio : 1,
                child: VideoPlayer(
                    MvPlayerModel.of(context).videoPlayerController)),
          ),
          _FullScreenController(),
        ],
      ),
    );
  }
}

///控制页面
class _FullScreenController extends StatefulWidget {
  @override
  _FullScreenControllerState createState() {
    return new _FullScreenControllerState();
  }
}

class _FullScreenControllerState extends State<_FullScreenController>
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
        _hideDelay();
      }
    });
    _controller.forward(from: 0);
  }

  void _setUiVisibility(bool show) {
    if (show) {
      _controller.forward(from: _controller.value);
      SystemChrome.setEnabledSystemUIOverlays(
          const [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    } else {
      _controller.reverse(from: _controller.value).then((_) {
        SystemChrome.setEnabledSystemUIOverlays(const []);
      });
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
    SystemChrome.setEnabledSystemUIOverlays(
        const [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
              child: _buildTop(context),
              translation: Offset(0, _controller.value - 1)),
          Expanded(
            child: IgnorePointer(
              ignoring: _controller.value <= 0.1,
              child: Opacity(
                  opacity: _controller.value,
                  child: Center(
                      child: MvPlayPauseButton(onInteracted: _hideDelay))),
            ),
          ),
          FractionalTranslation(
              child: _buildBottom(context),
              translation: Offset(0, 1 - _controller.value))
        ],
      ),
    );
  }

  Widget _buildTop(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [Colors.black87, Colors.black12])),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Text(MvPlayerModel.of(context).mvData['name']),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.thumb_up),
            onPressed: () => notImplemented(context),
          ),
          IconButton(
            icon: Icon(Icons.add_box),
            onPressed: () => notImplemented(context),
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => notImplemented(context),
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => notImplemented(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    final value = MvPlayerModel.of(context).playerValue;

    final position = value.position.inMilliseconds;
    final duration = value.duration?.inMilliseconds ?? 0;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [Colors.black12, Colors.black87])),
        child: DefaultTextStyle(
          style: Theme.of(context).primaryTextTheme.body1,
          child: Row(
            children: <Widget>[
              Text(getTimeStamp(position)),
              Expanded(
                child: Slider(
                    value: position.clamp(0, duration).toDouble(),
                    max: duration.toDouble(),
                    onChanged: value.initialized
                        ? (v) {
                            MvPlayerModel.of(context).videoPlayerController
                              ..seekTo(Duration(milliseconds: v.toInt()))
                              ..play();
                          }
                        : null),
              ),
              Text(getTimeStamp(duration)),
              SizedBox(width: 4),
              PopupMenuButton<String>(
                  itemBuilder: (context) {
                    return MvPlayerModel.of(context)
                        .imageResolutions
                        .map((str) => PopupMenuItem<String>(
                              value: str,
                              child: Container(child: Text('${str}P')),
                            ))
                        .toList();
                  },
                  onSelected: (v) =>
                      MvPlayerModel.of(context).currentImageResolution = v,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Text(
                        '${MvPlayerModel.of(context).currentImageResolution}P'),
                  )),
              IconButton(
                  icon: Icon(Icons.fullscreen_exit, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
