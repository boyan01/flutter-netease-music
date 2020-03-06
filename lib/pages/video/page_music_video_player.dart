import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/material/button.dart';
import 'package:quiet/pages/artists/page_artist_detail.dart';
import 'package:quiet/pages/comments/comments.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:video_player/video_player.dart';

import 'music_video_datail.dart';
import 'page_music_video_player_fullscreen.dart';
import 'video_controller.dart';
import 'video_player_model.dart';

///MV详情页面
///顶部是视频播放
///下方显示评论
class MusicVideoPlayerPage extends StatelessWidget {
  final int mvId;

  MusicVideoPlayerPage(this.mvId, {Key key})
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
  VideoPlayerModel _model;

  bool _pausedPlayingMusic = false;

  @override
  void initState() {
    super.initState();
    _model = VideoPlayerModel(MusicVideoDetail.fromJsonMap(widget.result['data']), subscribed: widget.result['subed']);
    _model.videoPlayerController.play();
    //TODO audio focus
    if (context.player.playbackState.isPlaying) {
      context.transportControls.pause();
      _pausedPlayingMusic = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _model.videoPlayerController.dispose();
    //try to resume paused music
    if (_pausedPlayingMusic) {
      context.transportControls.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentId = CommentThreadId(_model.data.id, CommentType.mv);
    return ScopedModel<VideoPlayerModel>(
      model: _model,
      child: ScopedModel<CommentList>(
        model: CommentList(commentId),
        child: Column(
          children: <Widget>[
            _SimpleMusicVideo(),
            Expanded(child: ScopedModelDescendant<CommentList>(
              builder: (context, child, model) {
                List data = [];
                data.addAll(MusicVideoFloor.values);
                data.addAll(model.items);

                return NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) {
                    model.loadMore(notification: notification);
                    return false;
                  },
                  child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: model.createBuilder(data, builder: (context, index) {
                        final item = data[index];
                        switch (item) {
                          case MusicVideoFloor.title:
                            return _InformationSection();
                          case MusicVideoFloor.actions:
                            return _ActionsSection();
                          case MusicVideoFloor.artists:
                            return _ArtistSection();
                        }
                        assert(false, "error to build($index) for $item ");
                        return Container();
                      })),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}

enum MusicVideoFloor {
  title,
  actions,
  artists,
}

class _SimpleMusicVideo extends StatelessWidget {
  static const double _defaultVideoAspect = 16 / 10;

  @override
  Widget build(BuildContext context) {
    final model = VideoPlayerModel.of(context);
    double aspect;
    if (model.playerValue.size != null && model.playerValue.size != Size.zero) {
      aspect = model.playerValue.aspectRatio;
    } else {
      aspect = _defaultVideoAspect;
    }
    return Container(
      child: AspectRatio(
        aspectRatio: _defaultVideoAspect,
        child: Container(
          color: Colors.black,
          child: Stack(children: <Widget>[
            Center(child: AspectRatio(aspectRatio: aspect, child: VideoPlayer(model.videoPlayerController))),
            _SimpleVideoController(),
          ]),
        ),
      ),
    );
  }
}

///小屏幕下的mv控制栏
class _SimpleVideoController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<VideoPlayerModel>(context);
    final data = model.data;
    return AnimatedMvController(
        showBottomIndicator: true,
        top: Container(
          decoration: const BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
            Colors.black38,
            Colors.black26,
            Colors.transparent,
          ])),
          child: AppBar(elevation: 0, titleSpacing: 0, backgroundColor: Colors.transparent, title: Text(data.name)),
        ),
        bottom: _buildBottom(context),
        center: MvPlayPauseButton());
  }

  Widget _buildBottom(BuildContext context) {
    final value = VideoPlayerModel.of(context).playerValue;

    final position = value.position.inMilliseconds;
    final duration = value.duration?.inMilliseconds ?? 0;
    return Container(
      decoration: const BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
        Colors.transparent,
        Colors.black26,
        Colors.black38,
      ])),
      child: Row(
        children: <Widget>[
          SizedBox(width: 8),
          Text.rich(
            TextSpan(children: <TextSpan>[
              TextSpan(text: getTimeStamp(position), style: TextStyle(color: Colors.white)),
              TextSpan(text: ' / ', style: TextStyle(color: Colors.white70)),
              TextSpan(text: getTimeStamp(duration), style: TextStyle(color: Colors.white70)),
            ]),
            style: TextStyle(fontSize: 13),
          ),
          Expanded(
              child: Slider(
                  max: duration.toDouble(),
                  value: position.clamp(0, duration).toDouble(),
                  onChanged: (v) async {
                    VideoPlayerModel.of(context).videoPlayerController
                      ..seekTo(Duration(milliseconds: v.toInt()))
                      ..play();
                  })),
          InkWell(
              splashColor: Colors.white,
              child: Padding(padding: const EdgeInsets.all(8), child: Icon(Icons.fullscreen, color: Colors.white)),
              onTap: () async {
                final route = MaterialPageRoute(
                    builder: (_) => ScopedModel<VideoPlayerModel>(
                        model: ScopedModel.of<VideoPlayerModel>(context), child: FullScreenMvPlayer()));
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
    final controller = VideoPlayerModel.of(context).videoPlayerController;

    final reachEnd = controller.value.initialized && controller.value.position >= controller.value.duration;
    final isPlaying = controller.value.isPlaying && !reachEnd;

    return Center(
      child: GestureDetector(
        child: ClipOval(
          child: Material(
            color: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 56),
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

/// title
class _InformationSection extends StatefulWidget {
  const _InformationSection({Key key}) : super(key: key);

  @override
  _InformationSectionState createState() => _InformationSectionState();
}

class _InformationSectionState extends State<_InformationSection> {
  static bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final data = VideoPlayerModel.of(context).data;

    Widget description;
    if (_expanded && data.desc != null) {
      description = Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          data.desc,
          maxLines: 6,
        ),
      );
    } else {
      description = Container();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data.name,
                      style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.bold),
                    ),
                    DefaultTextStyle(
                      style: TextStyle(color: Colors.grey),
                      child: Row(
                        children: <Widget>[
                          Text('发布: ${data.publishTime}'),
                          VerticalDivider(color: Theme.of(context).dividerColor),
                          Text('播放: ${getFormattedNumber(data.playCount)}')
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: data.desc != null,
                child: IconButton(
                  icon: Icon(_expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              )
            ],
          ),
          description,
        ],
      ),
    );
  }
}

///mv 点赞/收藏/评论/分享
class _ActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = VideoPlayerModel.of(context).data;
    return DividerWrapper(
      child: ButtonTheme(
        textTheme: ButtonTextTheme.accent,
        colorScheme: ColorScheme.light(secondary: Colors.black54),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                      Text('${data.likeCount}'),
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
                      Text('${data.commentCount}'),
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
                      Text('${data.shareCount}'),
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
    final model = VideoPlayerModel.of(context);
    return FlatButton(
        onPressed: () => subscribeOrUnSubscribeMv(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 4.0),
            Icon(model.subscribed ? Icons.check_box : Icons.add_box),
            const SizedBox(height: 4.0),
            Text('${model.data.subCount}'),
          ],
        ));
  }
}

class _ArtistSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = VideoPlayerModel.of(context).data;

    Widget widget;
    if (data.artists == null || data.artists.isEmpty) {
      widget = Container();
    } else {
      widget = _buildArtistTile(context, data.artists);
    }

    return Column(children: [
      widget,
      Container(
        color: Theme.of(context).dividerColor,
        height: 8,
      )
    ]);
  }

  Widget _buildArtistTile(BuildContext context, List<Artist> artist) {
    return InkWell(
      onTap: () {
        launchArtistDetailPage(context, artist);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: <Widget>[
            ClipOval(
              //TODO add artist image
              child: SizedBox(
                width: 36,
                height: 36,
                child: Container(color: Theme.of(context).disabledColor),
              ),
            ),
            SizedBox(width: 12),
            Text(artist.map((ar) => ar.name).join('/')),
            Spacer(),
            ButtonTheme(
              minWidth: 30,
              height: 32,
              padding: EdgeInsets.all(0),
              child: RaisedButtonWithIcon(
                onPressed: () {
                  toast('收藏');
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textColor: Theme.of(context).primaryTextTheme.bodyText2.color,
                icon: Icon(Icons.add, size: 18),
                label: Text('收藏', style: TextStyle(fontSize: 12)),
                color: Theme.of(context).primaryColor,
                labelSpacing: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
