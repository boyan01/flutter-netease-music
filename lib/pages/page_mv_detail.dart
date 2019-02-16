import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiet/pages/page_comment.dart';
import 'package:quiet/part/mv/mv_foreground_controller.dart';
import 'package:quiet/part/mv/mv_player_model.dart';
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
            color: Colors.black,
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

  bool _pausedPlayingMusic = false;

  @override
  void initState() {
    super.initState();
    _model = MvPlayerModel(widget.result['data'],
        subscribed: widget.result['subed']);
    _model.videoPlayerController.play();
    if (quiet.value.isPlaying) {
      quiet.pause();
      _pausedPlayingMusic = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _model.videoPlayerController.dispose();
    //try to resume paused music
    if (_pausedPlayingMusic) {
      quiet.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentId = CommentThreadId(_model.mvData['id'], CommentType.mv);
    return ScopedModel<MvPlayerModel>(
      model: _model,
      child: Column(
        children: <Widget>[
          _SimpleMvScreen(),
          Expanded(
            child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverFixedExtentList(
                        delegate: SliverChildListDelegate([
                          _MvInformationSection(data: widget.result['data'])
                        ]),
                        itemExtent: _MvInformationSection.height),
                    SliverFixedExtentList(
                        delegate: SliverChildListDelegate([
                          _MvActionsSection(),
                        ]),
                        itemExtent: _MvActionsSection.height),
                  ];
                },
                body: Loader(
                    loadTask: () => neteaseRepository.getComments(commentId),
                    builder: (context, result) {
                      return CommentList(threadId: commentId, comments: result);
                    })),
          ),
        ],
      ),
    );
  }
}

class _SimpleMvScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = MvPlayerModel.of(context);
    return Container(
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          color: Colors.black,
          child: Stack(children: <Widget>[
            Center(
                child: AspectRatio(
                    aspectRatio: model.playerValue.initialized
                        ? model.playerValue.aspectRatio
                        : 16 / 10,
                    child: VideoPlayer(model.videoPlayerController))),
            _SimpleMvScreenForeground(),
          ]),
        ),
      ),
    );
  }
}

///小屏幕下的mv控制栏
class _SimpleMvScreenForeground extends StatelessWidget {
  static const closeDelay = const Duration(seconds: 5);

  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<MvPlayerModel>(context);
    final data = model.mvData;
    return AnimatedMvController(
        showBottomIndicator: true,
        top: Container(
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
        bottom: _buildBottom(context),
        center: MvPlayPauseButton());
  }

  Widget _buildBottom(BuildContext context) {
    final value = MvPlayerModel.of(context).playerValue;

    final position = value.position.inMilliseconds;
    final duration = value.duration?.inMilliseconds ?? 0;
    return Container(
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
                  text: getTimeStamp(position),
                  style: TextStyle(color: Colors.white)),
              TextSpan(text: ' / ', style: TextStyle(color: Colors.white70)),
              TextSpan(
                  text: getTimeStamp(duration),
                  style: TextStyle(color: Colors.white70)),
            ]),
            style: TextStyle(fontSize: 13),
          ),
          Expanded(
              child: Slider(
                  max: duration.toDouble(),
                  value: position.clamp(0, duration).toDouble(),
                  onChanged: (v) async {
                    MvPlayerModel.of(context).videoPlayerController
                      ..seekTo(Duration(milliseconds: v.toInt()))
                      ..play();
                  })),
          InkWell(
              splashColor: Colors.white,
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.fullscreen, color: Colors.white)),
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
    );
  }
}

class MvPlayPauseButton extends StatelessWidget {
  final VoidCallback onInteracted;

  const MvPlayPauseButton({Key key, this.onInteracted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = MvPlayerModel.of(context).videoPlayerController;

    final reachEnd = controller.value.initialized &&
        controller.value.position >= controller.value.duration;
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

  static const double height = 70;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
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
      ),
    );
  }
}

///mv 点赞/收藏/评论/分享
class _MvActionsSection extends StatelessWidget {
  static final double height = 72;

  @override
  Widget build(BuildContext context) {
    final data = MvPlayerModel.of(context).mvData;
    return DividerWrapper(
      child: ButtonTheme(
        textTheme: ButtonTextTheme.accent,
        colorScheme: ColorScheme.light(secondary: Colors.black54),
        child: Container(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                  onPressed: () => notImplemented(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 4.0),
                      Icon(Icons.thumb_up),
                      const SizedBox(height: 4.0),
                      Text('${data['likeCount']}'),
                    ],
                  )),
              _SubscribeButton(),
              FlatButton(
                  onPressed: () => notImplemented(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 4.0),
                      Icon(Icons.comment),
                      const SizedBox(height: 4.0),
                      Text('${data['commentCount']}'),
                    ],
                  )),
              FlatButton(
                  onPressed: () => notImplemented(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 4.0),
                      Icon(Icons.share),
                      const SizedBox(height: 4.0),
                      Text('${data['shareCount']}'),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = MvPlayerModel.of(context);
    return FlatButton(
        onPressed: () => subscribeOrUnSubscribeMv(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 4.0),
            Icon(model.subscribed ? Icons.check_box : Icons.add_box),
            const SizedBox(height: 4.0),
            Text('${model.mvData['subCount']}'),
          ],
        ));
  }
}
