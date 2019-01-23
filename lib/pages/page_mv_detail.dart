import 'package:async/async.dart';

import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:video_player/video_player.dart';

///MV详情页面
///顶部是视频播放
///下方显示评论
class MvDetailPage extends StatelessWidget {
  final int mvId;

  const MvDetailPage(this.mvId, {Key key})
      : assert(mvId != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).padding.top,
            color: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Loader(
                  resultVerify: neteaseRepository.responseVerify,
                  loadTask: () => neteaseRepository.mvDetail(mvId),
                  builder: (context, result) {
                    return MvPlayer(
                      data: result['data'],
                      subscribed: false,
                      child: ListView(
                        children: <Widget>[
                          _SimpleMvScreen(data: result['data']),
                          _MvInformationSection(data: result['data']),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}

class MvPlayer extends StatefulWidget {
  final Widget child;

  final Map data;
  final bool subscribed;

  const MvPlayer(
      {Key key, @required this.data, @required this.subscribed, this.child})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => MvPlayerState();
}

class MvPlayerState extends State<MvPlayer> {
  VideoPlayerController videoPlayerController;

  List<String> imageResolutions;

  String currentImageResolution;

  VideoPlayerValue playerValue = VideoPlayerValue.uninitialized();

  @override
  void didUpdateWidget(MvPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data['id'] != oldWidget.data['id']) {
      _doInit();
    }
  }

  void _doInit() {
    final Map brs = widget.data['brs'];
    assert(brs != null && brs.isNotEmpty);
    imageResolutions = brs.keys.toList();
    currentImageResolution = imageResolutions.last;
    videoPlayerController?.dispose();
    videoPlayerController =
        VideoPlayerController.network(brs[currentImageResolution]);
    videoPlayerController.initialize();
//    videoPlayerController.play();
    videoPlayerController.addListener(() {
      setState(() {
        playerValue = videoPlayerController.value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _doInit();
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MvPlayerValue(widget.data['id'],
        videoPlayerController: videoPlayerController,
        imageResolutions: imageResolutions,
        currentImageResolution: currentImageResolution,
        playerValue: playerValue,
        child: widget.child);
  }
}

class MvPlayerValue extends InheritedWidget {
  final VideoPlayerController videoPlayerController;
  final List<String> imageResolutions;
  final String currentImageResolution;
  final int mvId;
  final VideoPlayerValue playerValue;

  const MvPlayerValue(
    this.mvId, {
    @required this.videoPlayerController,
    @required this.imageResolutions,
    @required this.currentImageResolution,
    @required this.playerValue,
    Key key,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  static MvPlayerValue of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MvPlayerValue) as MvPlayerValue;
  }

  static VideoPlayerValue value(BuildContext context) {
    return of(context).playerValue;
  }

  @override
  bool updateShouldNotify(MvPlayerValue old) {
    return currentImageResolution != old.currentImageResolution ||
        mvId != old.mvId ||
        playerValue != old.playerValue;
  }
}

class _SimpleMvScreen extends StatelessWidget {
  ///mv data
  final Map data;

  const _SimpleMvScreen({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          color: Colors.black87,
          child: Stack(children: <Widget>[
            VideoPlayer(MvPlayerValue.of(context).videoPlayerController),
            _SimpleMvScreenForeground(data: data),
          ]),
        ),
      ),
    );
  }
}

///
class _SimpleMvScreenForeground extends StatefulWidget {
  ///mv data
  final Map data;

  static const closeDelay = const Duration(seconds: 5);

  const _SimpleMvScreenForeground({Key key, @required this.data})
      : super(key: key);

  @override
  _SimpleMvScreenForegroundState createState() =>
      _SimpleMvScreenForegroundState();
}

class _SimpleMvScreenForegroundState extends State<_SimpleMvScreenForeground>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  ///true 在视频上显示控制栏和标题栏,但是[closeDelay]时间段后会自动关闭
  ///false 关闭控制栏的显示
  bool _show = true;

  CancelableOperation _hideOperation;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _hideDelay();
  }

  void _hideDelay() {
    if (!_show) {
      return;
    }
    _hideOperation?.cancel();
    _hideOperation = CancelableOperation.fromFuture(
        Future.delayed(_SimpleMvScreenForeground.closeDelay))
      ..value.whenComplete(() {
        setState(() {
          _show = false;
        });
      });
  }

  @override
  void didUpdateWidget(_SimpleMvScreenForeground oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideOperation.cancel();
    super.dispose();
  }

  Widget _buildControllerWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        AppBar(
            backgroundColor: Colors.transparent,
            title: Text(widget.data['name'])),
        Expanded(child: _PlayPauseButton(onInteracted: _hideDelay)),
        Row(
          children: <Widget>[
            SizedBox(width: 8),
            Text.rich(
              TextSpan(children: <TextSpan>[
                TextSpan(
                    text: getTimeStamp(
                        MvPlayerValue.value(context).position.inMilliseconds)),
                TextSpan(text: ' / ', style: TextStyle(color: Colors.white70)),
                TextSpan(
                    text: getTimeStamp(
                        MvPlayerValue.value(context).duration.inMilliseconds),
                    style: TextStyle(color: Colors.white70)),
              ]),
              style: Theme.of(context).primaryTextTheme.body1,
            ),
            Spacer(),
            IconButton(icon: Icon(Icons.fullscreen), onPressed: () {})
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!MvPlayerValue.value(context).initialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    Widget result;
    if (!_show) {
      result = SizedBox.expand();
    } else {
      result = _buildControllerWidget(context);
    }
    result = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          _hideDelay();
        },
        onTap: () {
          setState(() {
            _show = !_show;
            _hideDelay();
          });
        },
        child: result);
    result = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: result),
        Transform.translate(
          transformHitTests: true,
          offset: Offset(0, 16),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Slider(
                max: MvPlayerValue.value(context)
                    .duration
                    .inMilliseconds
                    .toDouble(),
                value: MvPlayerValue.value(context)
                    .position
                    .inMilliseconds
                    .toDouble(),
                onChanged: (v) async {
                  await MvPlayerValue.of(context)
                      .videoPlayerController
                      .seekTo(Duration(milliseconds: v.toInt()));
                  MvPlayerValue.of(context).videoPlayerController.play();
                }),
          ),
        ),
      ],
    );
    return result;
  }
}

class _PlayPauseButton extends StatelessWidget {
  final VoidCallback onInteracted;

  const _PlayPauseButton({Key key, this.onInteracted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = MvPlayerValue.of(context).videoPlayerController;
    return Center(
      child: GestureDetector(
        child: ClipOval(
          child: Material(
            color: Colors.black38,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 56),
            ),
          ),
        ),
        onTap: () {
          if (onInteracted != null) onInteracted();
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        },
      ),
    );
  }
}

class _MvInformationSection extends StatelessWidget {
  ///mv data
  final Map data;

  const _MvInformationSection({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(data['name'],
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(fontWeight: FontWeight.bold)),
          DefaultTextStyle(
            style: TextStyle(color: Colors.grey),
            child: Row(
              children: <Widget>[
                Text('发布: ${data['publishTime']}'),
                VerticalDivider(color: Theme.of(context).dividerColor),
                Text('播放: ${getFormattedNumber(data['playCount'])}')
              ],
            ),
          )
        ],
      ),
    );
  }
}
