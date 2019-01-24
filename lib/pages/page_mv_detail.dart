import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiet/part/mv/mv_player_controller.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';
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
                    return _MvDetailPage(result: result);
                  }),
            ),
          ),
        ],
      ),
    );
  }
}

class _MvDetailPage extends StatefulWidget {
  ///response of [NeteaseRepository.mvDetail]
  final Map result;

  const _MvDetailPage({Key key, this.result}) : super(key: key);

  @override
  _MvDetailPageState createState() {
    return new _MvDetailPageState();
  }
}

class _MvDetailPageState extends State<_MvDetailPage> {
  MvPlayerModel _model;

  @override
  void initState() {
    super.initState();
    _model = MvPlayerModel(widget.result['data'], subscribed: false);
    _model.videoPlayerController.play();
  }

  @override
  void dispose() {
    super.dispose();
    _model.videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MvPlayerModel>(
      model: _model,
      child: ListView(
        children: <Widget>[
          _SimpleMvScreen(),
          _MvInformationSection(data: widget.result['data']),
        ],
      ),
    );
  }
}

class MvPlayerModel extends Model {
  static MvPlayerModel of(BuildContext context, {bool rebuildOnChange = true}) {
    return ScopedModel.of<MvPlayerModel>(context,
        rebuildOnChange: rebuildOnChange);
  }

  MvPlayerModel(this.mvData, {this.subscribed = false}) {
    final Map brs = mvData['brs'];
    assert(brs != null && brs.isNotEmpty);
    _imageResolutions = brs.keys.toList();
    _initPlayerController(imageResolutions.first);
  }

  ///根据分辨率初始化播放器
  void _initPlayerController(String imageResolution) {
    final Map brs = mvData['brs'];
    _currentImageResolution = imageResolution;

    Duration moment = Duration.zero;
    bool play = false;
    if (_videoPlayerController != null) {
      moment = _videoPlayerController.value.position;
      play = _videoPlayerController.value.isPlaying;
      _videoPlayerController.dispose();
    }

    //之所以使用MvPlayerController,是因为原有的VideoPlayerController并未对disposed状态做保护处理
    //VideoPlayerController被 dispose 后,有可能会被 VideoPlayer 调用 removeListener 方法,从而引发错误
    //所以包裹了一层保护
    _videoPlayerController = MvPlayerController.network(brs[imageResolution]);
    _videoPlayerController.initialize().then((_) {
      _videoPlayerController.seekTo(moment);
      if (play) _videoPlayerController.play();
    });

    _videoPlayerController.addListener(() {
      notifyListeners();
    });
  }

  ///mv数据
  final Map mvData;

  bool subscribed;

  VideoPlayerController _videoPlayerController;

  VideoPlayerController get videoPlayerController => _videoPlayerController;

  VideoPlayerValue get playerValue => videoPlayerController.value;

  ///分辨率
  List<String> _imageResolutions;

  List<String> get imageResolutions => _imageResolutions;

  ///当前的分辨率
  String _currentImageResolution;

  String get currentImageResolution => _currentImageResolution;

  set currentImageResolution(String value) {
    _initPlayerController(value);
  }
}

class _SimpleMvScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = MvPlayerModel.of(context);
    return Container(
      child: AspectRatio(
        aspectRatio: model.playerValue.initialized
            ? model.playerValue.aspectRatio
            : 16 / 10,
        child: Container(
          color: Colors.black87,
          child: Stack(children: <Widget>[
            VideoPlayer(model.videoPlayerController),
            _SimpleMvScreenForeground(),
          ]),
        ),
      ),
    );
  }
}

///小屏幕下的mv控制栏
class _SimpleMvScreenForeground extends StatefulWidget {
  static const closeDelay = const Duration(seconds: 5);

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
    final model = ScopedModel.of<MvPlayerModel>(context);
    final data = model.mvData;
    return Material(
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Colors.black38,
                  Colors.black26,
                  Colors.transparent,
                ])),
            child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: Text(data['name'])),
          ),
          Expanded(child: MvPlayPauseButton(onInteracted: _hideDelay)),
          Container(
            decoration: const BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Colors.transparent,
                  Colors.black26,
                  Colors.black38,
                ])),
            child: Row(
              children: <Widget>[
                SizedBox(width: 8),
                Text.rich(
                  TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: getTimeStamp(
                            model.playerValue.position.inMilliseconds),
                        style: TextStyle(color: Colors.white)),
                    TextSpan(
                        text: ' / ', style: TextStyle(color: Colors.white70)),
                    TextSpan(
                        text: getTimeStamp(
                            model.playerValue.duration.inMilliseconds),
                        style: TextStyle(color: Colors.white70)),
                  ]),
                  style: TextStyle(fontSize: 13),
                ),
                Expanded(
                    child: Slider(
                        max: model.playerValue.duration.inMilliseconds
                            .toDouble(),
                        value: model.playerValue.position.inMilliseconds
                            .toDouble()
                            .clamp(
                                0,
                                model.playerValue.duration.inMilliseconds
                                    .toDouble()),
                        onChanged: (v) async {
                          await model.videoPlayerController
                              .seekTo(Duration(milliseconds: v.toInt()));
                          model.videoPlayerController.play();
                        })),
                InkWell(
                    splashColor: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.fullscreen)),
                    onTap: () async {
                      final route = MaterialPageRoute(
                          builder: (_) => ScopedModel<MvPlayerModel>(
                              model: ScopedModel.of<MvPlayerModel>(context),
                              child: FullScreenMvPlayer()));
                      SystemChrome.setPreferredOrientations(const [
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                      await Navigator.push(context, route);
                      SystemChrome.setPreferredOrientations(const [
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                    }),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!MvPlayerModel.of(context).playerValue.initialized) {
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
    return result;
  }
}

class MvPlayPauseButton extends StatelessWidget {
  final VoidCallback onInteracted;

  const MvPlayPauseButton({Key key, this.onInteracted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = MvPlayerModel.of(context).videoPlayerController;

    final reachEnd = controller.value.position >= controller.value.duration;
    final isPlaying = controller.value.isPlaying && !reachEnd;

    return Center(
      child: GestureDetector(
        child: ClipOval(
          child: Material(
            color: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white, size: 56),
            ),
          ),
        ),
        onTap: () async {
          if (onInteracted != null) onInteracted();
          if (isPlaying) {
            controller.pause();
          } else {
            if (reachEnd) {
              await controller.seekTo(Duration.zero);
            }
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
